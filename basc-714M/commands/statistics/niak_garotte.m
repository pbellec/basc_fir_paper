function [beta shrcf rss]=niak_garotte(x,y,s,flag_profile)
% Implementation of L. Breiman's non-negative garrote.
%
% function [beta shrcf rss]=nng_garotte(x,y,s)
% Implementation based on L. Breiman's original FORTRAN code.
%
% Parameters:
%   x     = regressor matrix [n x p]
%   y     = targets [n x v]
%   s     = garotte constraint parameter [1 x 1]
%
% Returns:
%   beta  = shrunken regression parameters [p x v]
%   shrcf = shrinkage coefficients [p x v]
%   rss   = residual sum of squares [1 x v]
%
% References:
%
% (1) Better Subset Regression Using the Nonnegative Garrote
% Leo Breiman
% Technometrics, Vol. 37, No. 4 (Nov., 1995), pp. 373-384 
%
% (2) A Tutorial on the SWEEP Operator
% James H. Goodnight
% The American Statistician, Vol. 33, No. 3 (Aug., 1979), pp. 149-158 
%
% (3) Solving Least Squares Problems
% Charles L. Lawson and Richard J. Hanson
% pp. 161
%
% Example:
% N = 100;
% V = 500;
% x = [ones([N 1]) (1:N)' ((1:N).^2)'];
% x(:,2:end) = niak_normalize_tseries (x(:,2:end));
% beta = [ones([1 V/2]) 1/2*ones([1 V/2]) ; ones([1 V/2]) 0*ones([1 V/2]) ; 0*ones([1 V/2]) ones([1 V/2])];
% y = x*beta + randn([N V]);
% [beta_c,E_c] = niak_lse(y,x);
% [beta_c2 shrcf rss]=niak_garotte(x,y,2.5);
%
% (c) Copyright Daniel F. Schmidt and Enes Makalic, 2008
% Vectorized by P. Bellec (added the possibility of v>1), 2011

if nargin < 4
    flag_profile = 0;
end

%% Initialise variables 
t0 = clock;
xx=x'*x;
xy=x'*y;
yy=sum(y.*y,1);
bols=x\y;

%% Solve sum_i c_i < s using the barrier method
con=1000;
tol=0.001;  

xy=bols .* xy / s;
tmp = zeros([size(xx) size(bols,2)]);
for num_m = 1:size(bols,1)
    for num_m2 = 1:num_m
        tmp(num_m,num_m2,:) = bols(num_m,:).*bols(num_m2,:);
	if num_m~=num_m2
            tmp(num_m2,num_m,:) = tmp(num_m,num_m2,:);
        end
    end
end
xx= repmat(xx,[1 1 size(bols,2)]).*tmp;
yy=yy/s^2;

done=false;
iters=1;

if flag_profile
    t1 = clock();
    elapsed_time = etime(t1,t0);
    fprintf('Initialization phase %1.4f secs\n',elapsed_time);
end

t = clock();
todo = true([1 size(xx,3)]);
shrcf = zeros([size(xx,1) size(xx,3)]);
while(~done && iters < 100)

    xy=xy + (con / s);
    xx=xx + (con / s);
    yy=yy + (con / s);

    % Lawson and Hansen algorithm for solving NNLS
    shrcf(:,todo)=niak_nnls(xx(:,:,todo),xy(:,todo),yy(todo),flag_profile);
    
    if flag_profile
        t1 = t;
        t = clock();
        fprintf('    Total iteration %i : %1.4f secs\n',iters,etime(t,t1))
    end
    ssum=sum(shrcf);
    todo = abs(ssum-1.0)>tol;
    if any(todo)
        con=10*con;
    else
        shrcf=s*shrcf;
        done=true;
    end;
    
    iters=iters+1;
end;

% Shrunken betas
beta=bols.*shrcf;

% RSS
rss=sum((y-x*beta).*(y-x*beta),1);

if flag_profile
    elapsed_time = etime(clock(),t0);
    fprintf('Total compution time %1.4f secs\n',elapsed_time);
end

%% Solve NNLS by the Lawson and Hansen algorithm
function bt=niak_nnls(xx,xy,yy,flag_profile)

t0 = clock;

%% Initialise variables
m=size(xx,1);
n=size(yy,2);
z=ones(m,n);
bt=zeros(m,n);
bs=zeros(m,n);
u=zeros(m+1,m+1,n);

%% Setup 'sweep' matrix
u(1:m,1:m,:)=xx;
u(1:m,m+1,:)=xy;
u(m+1,1:m,:)=xy;
u(m+1,m+1,:)=yy;

%% Main algorithm
done=false;

if flag_profile
    t1 = clock();
    fprintf('    NNLS init : %1.4f secs\n',etime(t1,t0));
end

t = clock();
mask_a = true([1 n]);

while(~done)
          
   %% Loop A    
    if any(mask_a)
        % Compute derivatives w.r.t. beta (Step 2)
	tmp = zeros(size(xy));
        for num_m = 1:m
            if size(xx,3) == 1
                tmp(num_m,:) = sum(squeeze(xx(num_m,:,:))'.*bt,1);
            else
                tmp(num_m,:) = sum(squeeze(xx(num_m,:,:)).*bt,1);
            end
        end
        w=xy-tmp;
        if flag_profile
            t1 = t;
            t = clock();
            fprintf('    Compute derivatives : %1.4f\n',etime(t,t1));
        end

        % If all remaining derivatives are less than zero (Step 3)
        mask = z==1;
        if(sum(z(:)) == 0 || max(w(mask)) <= 0)
            return; % we are done
        end;

        % Find the next variable to enter (Step 4)
        tmp = w;
	tmp(~mask) = NaN;
        [val,wt]=max(tmp,[],1);
        todo = max(mask,[],1)>0;
        wt = wt(todo);
        
        % Move the index t from set Z (Step 5)
        z(sub2ind(size(z),wt,1:n))=0;
        t = clock();
        if any(todo)
            u(:,:,todo)=niak_sweep(u(:,:,todo),wt);
        end
        if flag_profile
            t1 = t;
            t = clock();
            fprintf('        Sweep loop A : %1.4f\n',etime(t,t1));
        end
    end;
    
    % Compute the LS solution (Step 6)
    mask = z==0;
    ut = squeeze(u(1:m,m+1,:));
    bs(mask)=ut(mask); 

    % If all coefficients are non-negative, betas are fine (Step 7)
    mask_a = bs;
    mask_a(~mask) = NaN;
    mask_a = min(mask_a,[],1)>0;
    bt(:,mask_a) = bs(:,mask_a);
    mask_b = ~mask_a;

    if any(mask_b)
        % (Step 8)
        g = zeros(size(bt));
        g(:,mask_b)=bt(:,mask_b) ./ (bt(:,mask_b) - bs(:,mask_b));
        mask=(bs<=0)&(z == 0);
        mask(:,mask_a) = false;

        % (Step 9)
        tmp = g;
        tmp(~mask) = NaN;
        [alpha,ind]=min(tmp,[],1);
        todo = max(mask,[],1)>0;
        alpha = alpha(todo);
        ind = ind(todo);

        % Fix for numerical problems (?)
        if min(alpha==0)==1
            return;
        end;
    
        % (Step 10)
        bt(:,todo)=bt(:,todo)+repmat(alpha,[m 1]).*(bs(:,todo)-bt(:,todo));

        % (Step 11)
        t = clock();
        u(:,:,todo)=niak_sweep(u(:,:,todo),ind);
        if flag_profile
            t1 = t;
            t = clock();
            fprintf('        Sweep loop B : %1.4f\n',etime(t,t1));
        end
    end
end;


function v=niak_sweep(v,k)

m=size(v,1);
n=size(v,3);
td=v(sub2ind_3d(size(v),k,k,1:n));

if(td < 1e-10)
    warning('Small');
end;

for num_m = 1:m
  it = sub2ind_3d(size(v),k,num_m*ones([1 n]),1:n);
  v(it)=v(it)./td;
end
for num_m=1:m
    k2 = k(k~=num_m);
    n2 = length(k2);
    if n2>0
       v2 = v(:,:,k~=num_m);
       it = sub2ind_3d(size(v2),num_m*ones([1 n2]),k2,1:n2);
       ct=v2(it);
       tmp = zeros([m n2]);
       for num_m2 = 1:m
          it = sub2ind_3d(size(v2),k2,num_m2*ones([1 n2]),1:n2);
          tmp(num_m2,:)=v2(it);
       end
       tmp = repmat(ct,[m 1]).*tmp;
       tmp = tmp(:)';
       it = repmat(1:n2,[m 1]);
       jt = sub2ind_3d(size(v2),num_m*ones([1 m*n2]),repmat(1:m,[1 n2]),it(:)');
       v2(jt)=v2(jt)-tmp;
       v2(sub2ind_3d(size(v2),num_m*ones([1 n2]),k2,1:n2))=-ct./td(k~=num_m);
       v(:,:,k~=num_m) = v2;
    end
end
v(sub2ind_3d(size(v),k,k,1:n))=1./td;

function ind = sub2ind_3d(siz,subx,suby,subz)
% Convert 3D coordinates into linear indices
% *much* faster than Matlab's sub2ind because it does not check 
% for dimensions.
% Copyright (c) Pierre Bellec, Montreal Neurological Institute, 2008.

if nargin == 2
    ind = subx(:,1) + (subx(:,2)-1)*siz(1) + (subx(:,3)-1)*siz(1)*siz(2);
else
    ind = subx + (suby-1)*siz(1) + (subz-1)*siz(1)*siz(2);
end