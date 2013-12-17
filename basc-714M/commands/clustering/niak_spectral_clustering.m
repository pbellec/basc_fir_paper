function part = niak_spectral_clustering(data,opt);
% Spectral clustering
%
% SYNTAX :
% [PART,D] = NIAK_SPECTRAL_CLUSTERING(DATA,OPT);
%
% _________________________________________________________________________
% INPUTS:
%
% DATA
%   (2D array T*N) An array with units as columns OR a similarity 
%   (affinity) matrix.
%
% OPT
%   (structure) with the following fields (absent fields will be assigned 
%   a default value):
%
%   NB_CLASSES
%       (vector of integers, length C) numbers of classes
%
%   TYPE_CLUSTERING
%       (string, default 'kmeans') the clustering algorithm used 
%       after dimension reduction. Supported options :
%           'kmeans' : see NIAK_KMEANS_CLUSTERING
%
%   OPT_CLUSTERING
%       () the option of the clustering algorithm. If the clustering
%       algorithm is 'kmeans', note that the default for
%       OPT_CLUSTERING.TYPE_INIT is 'kmeans++' rather than
%       'random_partition' (which is the usual default in
%       NIAK_KMEANS_CLUSTERING).
%
%   TYPE_AFFINITY
%       (string, default 'ng') the affinitiy matrix. Available 
%       options :
%           'ng' : The affinity matrix used in (Ng et al., 2001). It 
%               is s_ij = exp(-norm2(DATA(:,i)-DATA(:,j))^2/(2*sigma^2))
%               where s_ij is the affinity between units i and j. The 
%               parameter sigma can be specified with OPT.SIGMA (below).
%
%           'manual' : DATA is assumed to define the affinity matrix.
%
%   SIGMA2
%       (scalar, default 1) it TYPE_AFFINITY is 'ng', SIGMA2 is the 
%       parameter used to define the affinity matrix.
%
%   FLAG_VERBOSE
%       (boolean, default 0) if the flag is 1, then the function prints
%       some infos during the processing.
%
% _________________________________________________________________________
% OUTPUTS:
%
% PART
%   (vector N*C) partition (find(part(:,C)==i) is the list of regions 
%   belonging to cluster i when applying a clustering with NB_CLASSES(C)
%   clusters.
%
% _________________________________________________________________________
% SEE ALSO:
% NIAK_KMEANS_CLUSTERING
%
% _________________________________________________________________________
% COMMENTS:
%
% This is an implementation of the algorithm described in :
% Andrew Y. Ng, Michael I. Jordan, Yair Weiss. On Spectral Clustering: 
% Analysis and an algorithm. In ADVANCES IN NEURAL INFORMATION 
% PROCESSING SYSTEMS , Vol. 14 (2001), pp. 849-856.  
%
% The only difference between this code and the paper by Ng and coll. is 
% that the data points are organized in columns rather than rows, for 
% consistency with the rest of the NIAK tools.
%
% Copyright (c) Pierre Bellec, Montreal Neurological Institute, 2011.
% Centre de recherche de l'institut de Gériatrie de Montréal
% Département d'informatique et de recherche opérationnelle
% Université de Montréal, 2010-2011
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : spectral clustering

% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESSED OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

%% Options
list_fields    = {'type_affinity' , 'nb_classes' , 'flag_verbose' , 'type_clustering' , 'opt_clustering' , 'sigma2' };
list_defaults  = {'ng'            , NaN          , 0              , 'kmeans'          , struct()         , 1        };
opt = psom_struct_defaults(opt,list_fields,list_defaults);

if strcmp(opt.type_clustering,'kmeans')
    list_fields   = {'type_init' };
    list_defaults = {'kmeans++'  };
    opt.opt_clustering = psom_struct_defaults(opt.opt_clustering,list_fields,list_defaults);
end

%% Derive the affinity matrix
[T,N] = size(data);
switch opt.type_affinity

    case 'ng'
        A = niak_build_distance(data,'norm2');
        A = exp(-A.^2/(2*opt.sigma2));
        
    case 'manual'
        A = data;

    otherwise
        error('%s is an unkown type of affinity',opt.type_affinity);
        
end

%% Spectral decomposition of the affinity matrix
D = diag(sum(A,1).^(-1/2));
L = D * A * D;
L = (L+L')/2; % force symmetry to avoid numerical imprecision
opt_eigs.disp = 0;
L = eye(size(L))-L;
[V,tmp] = eigs(L,max(opt.nb_classes),'sm',opt_eigs);
V = V';
V = V./repmat(sqrt(sum(V.^2,1)),[size(V,1) 1]);

%% Clustering in the subspace
part = zeros([N length(opt.nb_classes)]);

for num_c = 1:length(opt.nb_classes)
    switch opt.type_clustering        
        case 'kmeans'
            opt.opt_clustering.nb_classes = opt.nb_classes(num_c);
            part(:,num_c) = niak_kmeans_clustering(V,opt.opt_clustering);            
        otherwise
            error('%s is an unkown type of clustering',opt.type_clustering);
    end
end