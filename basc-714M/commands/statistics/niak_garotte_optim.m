%% Leave-one out validation to select the parameter of the garotte estimator
% 
% function [beta,s,coeff,perror,grid]=niak_garotte_optim(x,y,sgridsize)
%
% Parameters:
%   x         = regressor matrix [n x p]
%   y         = targets [n x v]
%   sgridsize = Number of points in the search grid for s (Default=10)
%
% Returns:
%   beta   = shrunken regression parameters [p x v]
%   s      = estimated garotte constraint [1 x v]
%   coeff  = estimated shrinkage coefficients [p x v]
%   perror = estimated prediction error [sgridsize x v]
%   grid   = the grid of garotte constraints that have been tested [sgridsize x 1]
%
% References:
%
% Cross-Validatory Choice and Assessment of Statistical Predictions
% M. Stone
% Journal of the Royal Statistical Society. Series B (Methodological), Vol. 36, No. 2 (1974), pp. 111-147 
%
% (c) Copyright Enes Makalic and Daniel F. Schmidt, 2008
function [beta,s,coeff,perror,grid]=niak_garotte_optim(x,y,sgridsize)

% Default grid size
if nargin < 3
    sgridsize = 10;
end

% Data set size
[n,p]=size(x);
[n,v]=size(y);

% Grid
grid=linspace(1e-3,p,sgridsize);
perror=zeros(length(grid),v);

% Search grid space
fprintf('Testing parameters in the garotte algorithm ...\n    Percentage done : ')
for num_s=1:length(grid)  
    fprintf('%i -',floor(100*num_s/length(grid))); 
    perror(num_s,:)=sub_kcv(x,y,n,grid(num_s));
end;

% Select the best parameters
[val,ind] = min(perror,[],1);
s = grid(ind);

% Estimate the garotte regression coefficients with optimized parameters
list_s = unique(grid);
beta = zeros([p,v]);
coeff = zeros([p,v]);
fprintf('\nDeriving the garotte estimator for optimal parameters ...\n    Percentage done : ')
for num_s = 1:length(list_s)
    fprintf('%i -',floor(100*num_s/length(list_s)));
    todo = s==list_s(num_s);
    if any(todo)
        [beta(:,todo),coeff(:,todo)]=niak_garotte(x,y(:,todo),list_s(num_s));
    end
end
fprintf('\nDone!\n')

function err=sub_kcv(x,y,nfolds,s)
% Initialise variables
[n,p]=size(x);
ind=randperm(n);
f=ceil(n/nfolds);

% Main loop
q=1;
err=0;
for i=1:nfolds   
    % Extract test data    
    it=q:min(q+f-1,n);
    xts=x(ind(it),:);
    yts=y(ind(it),:);
    
    % Extract training data
    ix=setdiff(ind,it);
    xtr=x(ind(ix),:);
    ytr=y(ind(ix),:);
        
    % Fit model
    beta=niak_garotte(xtr,ytr,s);
    
    % Generalisation error   
    perror=sum((yts-xts*beta).*(yts-xts*beta),1);
    err=err+perror/length(it);    
    
    % Get the next block
    q = q+f;
end;

% Prediction error estimate
err=err/nfolds;
