function [ovlp_mat,ovlp_max,ind_max,ovlp,ovlp_clust,ovlp_map] = niak_overlap_clusters(clust1,clust2)
%
% _________________________________________________________________________
% SUMMARY NIAK_OVERLAP_CLUSTERS
%
% This is a dummy .m files to show how to format a command function in
% NIAK.
%
% SYNTAX :
% [OVLP,OVLP_CLUST,OVLP_MAP] = NIAK_OVERLAP_CLUSTERS(CLUST1,CLUST2)
%
% _________________________________________________________________________
% INPUTS :
%
% CLUST1
%       (vector or array) A clustering. The ith cluster is full of i's.
%       Note that zeros are ignored.
%
% CLUST2
%       (vector or array) A clustering. The ith cluster is full of i's.
%       Note that zeros are ignored. Must be in the same space as CLUST1.
%
% _________________________________________________________________________
% OUTPUTS :
%
% OVLP_MAT
%       (matrix) OVLP_MAT(I,J) is the overlap between clusters I of CLUST1
%       and J from CLUST2 relative on the size of clusters in CLUST1.
%
% OVLP_MAX
%       (vector) OVLP_MAX1(I) is the maximal relative overlap between
%       cluster I in CLUST1 and any cluster in CLUST2.
%       
% IND_MAX
%       (vector) Cluster I in CLUSTER1 has maximal relative overlap with
%       IND_MAX(I)th cluster of CLUST2.
%
% OVLP
%       (scalar) the average relative overlap of clusters in CLUST1 and
%       CLUST2 (see the COMMENTS section below).
%
% OVLP_CLUST
%       (vector) OVLP_CLUST(I) is the average relative overlap of the ith
%       cluster in CLUST1 and clusters in CLUST2 (see the COMMENTS section 
%       below).
%
% OVLP_MAP
%       (vector) OVLP_MAP(K) is the average relative overlap between CLUST1
%       and CLUST2 at position K (see the COMMENTS section below).
%
% _________________________________________________________________________
% SEE ALSO :
%
% _________________________________________________________________________
% COMMENTS
%
% Let K be a position in CLUST1, C(K) be the cluster K belongs to in CLUST1
% and D(K) be the cluster K belongs to in CLUST2.
% The overlap of CLUST1 and CLUST2 relative to CLUST1 at point K is defined
% as :
% OVLP_MAP(K) = #( C(K) & D(K) ) / #C(K),
% where # is the cardinal and & the intersection. Note that if D(K) = 0
% (the empty cluster), the OVLP_MAP(K) is zero. 
% These values can be averaged within each cluster of CLUST1 (the
% OVLP_CLUST vector) or within all non-zero positions in CLUST1 (the global
% OVLP measure).
%
% Copyright (c) Pierre Bellec, Montreal Neurological Institute, 2008.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : NIAK, documentation, template, command

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
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

%% reshape clusterings as vectors
ovlp_map = zeros(size(clust1));
clust1 = clust1(:);
clust2 = clust2(:);

%% Extract cluster labels
list1 = unique(clust1);
list1 = list1(list1~=0);
nb_clust1 = length(list1);
list2 = unique(clust2);
list2 = list2(list2~=0);
nb_clust2 = length(list2);

%% Compute the relative overlap between clusters
ovlp_mat = zeros([nb_clust1,nb_clust2]);
siz_clust1 = zeros([nb_clust1 1]);

for ind1 = 1:nb_clust1
    num1 = list1(ind1);
    siz_clust1(ind1) = sum(clust1==num1);
    for ind2 = 1:nb_clust2
        num2 = list2(ind2);
        ovlp_mat(ind1,ind2) = sum((clust1==num1)&(clust2==num2))/siz_clust1(ind1);
        mask = (clust1==num1)&(clust2==num2);
        ovlp_map(mask) = ovlp_mat(ind1,ind2);
    end
end
ovlp_clust = sum(ovlp_mat.^2,2);
[ovlp_max,ind_max] = max(ovlp_mat,[],2);
ovlp = sum(ovlp_clust.*siz_clust1)/sum(siz_clust1);
