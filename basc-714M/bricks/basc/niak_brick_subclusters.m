function [files_in,files_out,opt] = niak_brick_subclusters(files_in,files_out,opt)
% Establish a correspondance between clusters and subclusters
%
% SYNTAX:
% [FILES_IN,FILES_OUT,OPT] = NIAK_BRICK_SUBCLUSTERS(FILES_IN,FILES_OUT,OPT)
%
% _________________________________________________________________________
% INPUTS:
%
% FILES_IN        
%   (cell of strings, length 2) FILES_IN{1} is the first level of
%   clustering, and FILES_IN{2} is the subcluster level. To work well, this 
%   method of decomposition should be applied on a quasi-hierarchy, i.e. 
%   each of the subcluster is almost included in one of the first level 
%   clusters.
%
% FILES_OUT 
%   (structure) with the following fields : 
%       
%   SUBCLUSTER
%       (cell of strings, default <FOLDER_OUT>/<BASE_NAME>_clustI.<EXT>) 
%       SUBCLUSTER{I} it the file name to save the decomposition of cluster 
%       I into subclusters.
%
%   MATCHING
%       (string, default <FOLDER_OUT>/<BASE_NAME>_matching.mat)
%       a mat file with the following variable :
%   
%       MATCHING
%           (cell of vectors) MATCHING{I}(J) is the number associated in
%           FILES_IN{2} with the Jth subcluster of the Ith cluster of
%           FILES_IN{1}.
%
%       IND_OVLP
%           (vector) IND_OVLP(K) is the number of the cluster at scale
%           1 with maximal overlap with the subcluster K at scale 2.
%
%       SCORE_OVLP
%           (vector) SCORE_OVLP(K) is the relative overlap of cluster K
%           at scale 2 with cluster IND_OVLP(K) at scale 1.
%
%       NB_SUB
%           (vector) NB_SUB(I) is the number of subclusters for cluster
%           I at scale 1.
%
%   NOMATCH
%       (string, default <FOLDER_OUT>/<BASE_NAME>_clust0.<EXT>) 
%       the file name to save the subclusters which do not match to any
%       cluster.
%
% OPT           
%   (structure) with the following fields.  
%
%   PERC_OVERLAP
%       (real, default 0.2) The minimal relative overlap of a subcluster 
%       into a cluster to enable inclusion in the subcluster list.
%
%   FLAG_RAND
%       (boolean, default 0) If FLAG_RAND is true, the order of the
%       subclusters are randomized. This is useful if for some reason
%       the order of the cluster is related to their spatial proximity.
%       Randomizing the order allows to apply a regular colormap when
%       displaying the clusters and ensure that spatially close clusters 
%       will not have systematically similar colors.
%
%   FOLDER_OUT 
%       (string, default: path of FILES_IN) If present, all default 
%       outputs will be created in the folder FOLDER_OUT. The folder 
%       needs to be created beforehand.
%
%   FLAG_VERBOSE 
%       (boolean, default 1) if the flag is 1, then the function prints 
%       some infos during the processing.
%
%   FLAG_TEST 
%       (boolean, default 0) if FLAG_TEST equals 1, the brick does not do 
%       anything but update the default values in FILES_IN, FILES_OUT and 
%       OPT.
%           
% _________________________________________________________________________
% OUTPUTS:
%
% The structures FILES_IN, FILES_OUT and OPT are updated with default
% valued. If OPT.FLAG_TEST == 0, the specified outputs are written.
%              
% _________________________________________________________________________
% SEE ALSO:
%
% _________________________________________________________________________
% COMMENTS:
%
% For each subcluster, a percentage of overlap is computed with every
% clusters. The subcluster K is then assigned to the cluster IND_OVLP(K)
% with largest overlap SCORE_OVLP(K).
%
% _________________________________________________________________________
% Copyright (c) Pierre Bellec, 
% Centre de recherche de l'institut de Gériatrie de Montréal
% Département d'informatique et de recherche opérationnelle
% Université de Montréal, 2011
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : clustering, hierarchy, subclusters

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Seting up default arguments %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('files_in','var')|~exist('files_out','var')|~exist('opt','var')
    error('niak:brick','syntax: [FILES_IN,FILES_OUT,OPT] = NIAK_BRICK_SUBCLUSTERS(FILES_IN,FILES_OUT,OPT).\n Type ''help niak_brick_subclusters'' for more info.')
end

%% Options
gb_name_structure = 'opt';
gb_list_fields = {'flag_rand','perc_overlap','flag_verbose','flag_test','folder_out'};
gb_list_defaults = {1,0.2,1,0,''};
niak_set_defaults

%% Output files
gb_name_structure = 'files_out';
gb_list_fields    = {'subcluster'      , 'matching'        , 'nomatch'         };
gb_list_defaults  = {'gb_niak_omitted' , 'gb_niak_omitted' , 'gb_niak_omitted' };
niak_set_defaults

[path_f,name_f,ext_f] = niak_fileparts(files_in{1});

if strcmp(opt.folder_out,'')
    opt.folder_out = path_f;
end

%% Building default output names
if flag_test == 1 %% Because it is necessary to read the input to produce output names, the automatic generation of file names is disabled
    return
end

[hdr,vol1] = niak_read_vol(files_in{1}); 
vol1 = round(vol1);
[hdr2,vol2] = niak_read_vol(files_in{2});
vol2 = round(vol2);

nb_clust1 = max(vol1(:));
nb_clust2 = max(vol2(:));
if isempty(files_out.subcluster)
    for num_f = 1:nb_clust1
        files_out.subcluster{num_f} = cat(2,opt.folder_out,filesep,name_f,'_clust',num2str(num_f),ext_f);
    end
end

if isempty(files_out.nomatch)
    files_out.nomatch = cat(2,opt.folder_out,filesep,name_f,'_clust0',ext_f);
end

if isempty(files_out.matching)
    files_out.matching = cat(2,opt.folder_out,filesep,name_f,'_matching.mat');
end

if flag_verbose
    fprintf('Performing subcluster anaysis on two clusterings.\nReference clustering : %s\nSubclustering :%s\n',files_in{1},files_in{2});        
    fprintf('%i clusters found in the reference\n',nb_clust1);
    fprintf('%i clusters found in the subclustering\n',nb_clust2);
end

%% Compute a hierarchical correspondance between the two scales based on
%% maximal overlap
ind_ovlp = zeros([nb_clust2 1]);
score_ovlp = zeros([nb_clust2 1]);
matching = cell([nb_clust1 1]);
for num_c = 1:nb_clust2
    roi_ovlp = vol1(vol2==num_c);
    nb_vox = length(roi_ovlp);
    roi_ovlp = roi_ovlp(roi_ovlp~=zeros);
    if ~isempty(roi_ovlp)        
        ind_cand = unique(roi_ovlp);
        score_cand = zeros(size(ind_cand));
        for num_i = 1:length(ind_cand)
            score_cand(num_i) = sum(roi_ovlp==ind_cand(num_i))/nb_vox;
        end
        [val_max,ind_max] = max(score_cand);
        ind_ovlp(num_c) = ind_cand(ind_max(1));
        matching{ind_ovlp(num_c)}(end+1) = num_c;
        score_ovlp(num_c) = val_max(1);
    elseif nb_vox == 0
        ind_ovlp(num_c) = NaN;
        score_ovlp(num_c) = NaN;
    end
end
    
%% build subcluster maps
nb_sub = zeros([nb_clust1 1]);
ind_sub = cell(nb_clust1,1);
score_sub = cell(nb_clust1,1);
for num_c = 0:nb_clust1
    vol_sub = zeros(size(vol1));
    if num_c==0
        if ~strcmp(files_out.nomatch,'gb_niak_omitted')
            ind_tmp = find(ind_ovlp==0);
            for num_e = 1:length(ind_tmp)
                vol_sub(vol2==ind_tmp(num_e)) = num_e;
            end
            hdr.file_name = files_out.nomatch;
            niak_write_vol(hdr,vol_sub);
        end
        if flag_verbose
            fprintf('%i subclusters could not be associated with any cluster: %s\n',length(ind_tmp),files_out.nomatch);
        end
    else        
        nb_sub(num_c) = sum(ind_ovlp==num_c);
        ind_sub{num_c} = find(ind_ovlp==num_c);
        if flag_rand
            ind_sub{num_c} = ind_sub{num_c}(randperm(length(ind_sub{num_c})));
        end
        score_sub{num_c} = score_ovlp(ind_sub{num_c});
        
        for num_e = 1:length(ind_sub{num_c})
            vol_sub(vol2==ind_sub{num_c}(num_e)) = num_e;
        end
        if ~ischar(files_out.subcluster)
            hdr.file_name = files_out.subcluster{num_c};
        end
        niak_write_vol(hdr,vol_sub);
        if flag_verbose
            fprintf('Cluster number %i was decomposed into %i subclusters : %s\n',num_c,length(ind_sub{num_c}),files_out.subcluster{num_c});
        end
    end    
end

if ~strcmp(files_out.matching,'gb_niak_omitted')
    save(files_out.matching,'nb_sub','score_ovlp','ind_ovlp','matching');
end