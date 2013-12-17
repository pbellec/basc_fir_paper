function [files_in,files_out,opt] = niak_brick_stability_glm_cores(files_in,files_out,opt)
% Estimate the stability of a clustering on linear model coefficients.
%
% SYNTAX:
% [FILES_IN,FILES_OUT,OPT] = NIAK_BRICK_STABILITY_GLM_CORES(FILES_IN,FILES_OUT,OPT)
%
% _________________________________________________________________________
% INPUTS:
%
% FILES_IN 
%   (structure) with the following fields :
%
%   DATA
%       (structure) with arbitrary fields :
%
%       <SUBJECT>
%           (string) The name of a .mat file with one variable MAT_R which is 
%           a vector. The variables MAT_R need to have the same length for 
%           all subjects.
%
%   MODEL
%       (string) the name of a CSV file. Example :
%                 , SEX , HANDENESS
%       <SUBJECT> , 0   , 0
%       This type of file can be generated with Excel (save under CSV).
%       Each column defines a covariate that can be used in a linear model.
%       See OPT.CONTRASTS below.
%
%   BIAS
%       (string) the name of a .mat file with two variables MEAN_BIAS and 
%       STD_BIAS which quantify the bias on the Mahalanobis distance.
%
% FILES_OUT
%   (string) A .mat file which contains the following variables :
%
%   STAB
%       (array) STAB(:,s) is the vectorized version of the stability matrix
%       associated with OPT.NB_CLASSES(s) clusters.
%
%   NB_CLASSES
%       (vector) Identical to OPT.NB_CLASSES (see below).
%
%   NB_SAMPS
%       (integer) Identical to OPT.NB_SAMPS (see below).
%
% OPT
%   (structure) with the following fields:
%
%   NB_CLASSES
%       (vector of integer) the number of clusters (or classes) that will
%       be investigated. This parameter will overide the parameters
%       specified in CLUSTERING.OPT_CLUST
%
%   NB_SAMPS
%       (integer, default 100) the number of samples to use in the
%       bootstrap Monte-Carlo approximation of stability.
%
%   CLUSTERING
%       (structure, optional) with the following fields :
%
%       TYPE
%           (string, default 'spectral') the clustering algorithm
%           Available options : 'spectral', 'hierarchical'
%
%       OPT
%           (structure, optional) options that will be  sent to the
%           clustering command. The exact list of options depends on
%           CLUSTERING.TYPE:
%               'spectral' : see OPT in NIAK_SPECTRAL_CLUSTERING
%               'hierarchical' : see OPT in NIAK_HIERARCHICAL_CLUSTERING
%
%    STRATA
%        (structure, optional) with multiple entries, each one with the
%        following fields :
%
%        LABEL
%            (string) the name of a covariate.
%
%        NB_STRATA
%            (integer) the subjects will be partitioned into close-to-even
%            strata based on the distribution of the covariate OPT.LABEL.
%
%   TEST
%       (stucture) with one entry and the following fields :
%
%       LABEL
%           (string) a label for the test.
%
%       CONTRAST
%           (structure, with arbitray fields <NAME>, which needs to
%           correspond to the label of one column in the file
%           FILES_IN.MODEL)
%
%           <NAME>
%               (scalar) the weight of the covariate NAME in the
%               contrast.
%
%       PROJECTION
%           (structure, optional) with multiple entries and the following
%           fields :
%
%           SPACE
%              (cell of strings) a list of the covariates that define the
%              space to project out from (i.e. the covariates in ORTHO, see
%              below, will be projected in the space orthogonal to SPACE).
%
%           ORTHO
%              (cell of strings) a list of the covariates to project in
%              the space orthogonal to SPACE (see above).
%
%       FLAG_INTERCEPT
%           (boolean, default true) if FLAG_INTERCEPT is true, a constant
%           covariate will be added to the model.
%
%       FLAG_NORMALIZE
%           (boolean, default true) if FLAG_NORMALIZE is true, the covariates
%           will be normalized to a zero mean and unit variance.
%
%       TYPE_NORMALIZATION
%           (string, default 'none') the type of normalization applied on 
%           individual connectomes :
%           'none' : no normalizaton, i.e. regular functional connectivity
%           'med_mad' : correct for zero median and unit variance using a 
%                median absolute deviation to the median estimate.
%
%   RAND_SEED
%       (scalar, default []) The specified value is used to seed the random
%       number generator with PSOM_SET_RAND_SEED. If left empty, no action
%       is taken.
%
%   FLAG_TEST
%       (boolean, default 0) if the flag is 1, then the function does not
%       do anything but update the defaults of FILES_IN, FILES_OUT and OPT.
%
%   FLAG_VERBOSE 
%       (boolean, default 1) if the flag is 1, then the function prints 
%       some infos during the processing.
%
% _________________________________________________________________________
% OUTPUTS:
%
% The structures FILES_IN, FILES_OUT and OPT are updated with default
% valued. If OPT.FLAG_TEST == 0, the specified outputs are written.
%
% _________________________________________________________________________
% SEE ALSO:
% NIAK_PIPELINE_STABILITY_GLM
%
% _________________________________________________________________________
% COMMENTS:
%
% For more details, see the description of the stability analysis on a
% individual fMRI time series in the following reference :
%
% P. Bellec; P. Rosa-Neto; O.C. Lyttelton; H. Benalib; A.C. Evans,
% Multi-level bootstrap analysis of stable clusters in resting-State fMRI. 
% Neuroimage 51 (2010), pp. 1126-1139 
%
% Copyright (c) Pierre Bellec, Centre de recherche de l'institut de 
% Gériatrie de Montréal, Département d'informatique et de recherche 
% opérationnelle, Université de Montréal, 2010.
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : clustering, stability, GLM, functional connectivity

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialization and syntax checks %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Syntax
if ~exist('files_in','var')|~exist('files_out','var')|~exist('opt','var')
    error('niak:brick','syntax: [FILES_IN,FILES_OUT,OPT] = NIAK_BRICK_STABILITY_GLM(FILES_IN,FILES_OUT,OPT).\n Type ''help niak_brick_stability_glm'' for more info.')
end

%% Files in
list_fields   = { 'data' , 'model' , 'bias' };
list_defaults = { NaN    , NaN     , NaN    };
files_in = psom_struct_defaults(files_in,list_fields,list_defaults);

if ~isstruct(files_in.data)
    error('FILES_IN.DATA should be a structure');
end

if ~ischar(files_in.model)
    error('MODEL should be a string')
end

if ~ischar(files_in.bias)
    error('BIAS should be a string')
end

%% Files out
if ~ischar(files_out)
    error('FILES_OUT should be a string!')
end

%% Options
opt_clustering.type  = 'hierarchical';
opt_clustering.opt   = struct();

list_fields   = { 'test' , 'strata' , 'clustering'   , 'rand_seed' , 'nb_samps' , 'nb_classes' , 'flag_verbose' , 'flag_test'  };
list_defaults = { NaN    , struct() , opt_clustering , []          , 100        , NaN          , true           , false        };
opt = psom_struct_defaults(opt,list_fields,list_defaults);

list_fields   = { 'type_normalization' , 'label' , 'contrast' , 'projection' , 'flag_normalize' , 'flag_intercept' };
list_defaults = { 'none'               , NaN     , NaN        , struct()     , true             , true             };
opt.test = psom_struct_defaults(opt.test,list_fields,list_defaults);

nb_samps   = opt.nb_samps;
nb_classes = opt.nb_classes;

%% If the test flag is true, stop here !
if opt.flag_test == 1
    return
end

%% Seed the random generator
if ~isempty(opt.rand_seed)
    psom_set_rand_seed(opt.rand_seed);
end

%% Reading model
if opt.flag_verbose
    fprintf('Reading model ...\n')
end
opt_m.labels_x   = fieldnames(files_in.data);
opt_m.labels_y   = fieldnames(opt.test.contrast);
opt_m.projection = opt.test.projection;
opt_m.contrast   = opt.test.contrast;
[model,labels_subject,labels_covariate,contrast_vec] = niak_read_model(files_in.model,opt_m);

%% Build the strata
mask_strata = niak_stability_glm_strata(model,labels_covariate,opt.strata);
nb_strata = max(mask_strata)
size_strata = niak_build_size_roi(mask_strata);

%% Read the individual connectivity matrices
if opt.flag_verbose
    fprintf('Reading (and normalizing) the individual connectomes ...\n');
end
list_read = 1:length(labels_subject);
list_read = list_read(randperm(length(list_read)));
for num_s = list_read
    if opt.flag_verbose
        fprintf('    %s\n',files_in.data.(labels_subject{num_s}));
    end
    data_subj = load(files_in.data.(labels_subject{num_s}));
    if num_s == list_read(1)
        mat = zeros([length(labels_subject) length(data_subj.mat_r)]);
    end
    switch opt.test.type_normalization
        case 'none'
            mat(num_s,:) = (data_subj.mat_r)';
        case 'med_mad'
            mat(num_s,:) = ((data_subj.mat_r)'-median(data_subj.mat_r))/niak_mad(data_subj.mat_r);
        case 'z_med_mad'
            data_subj.mat_r = niak_fisher(data_subj.mat_r);
            mat(num_s,:) = ((data_subj.mat_r)'-median(data_subj.mat_r))/niak_mad(data_subj.mat_r);
        case 'mean_var'
            mat(num_s,:) = niak_normalize_tseries(data_subj.mat_r(:));
        otherwise
            error('%s is an unknown normalization method',opt.test.type_normalization)
    end
end

%% Read the bias
bias = load(files_in.bias,'mean_bias','std_bias','target');

%% Generate samples
if opt.flag_verbose
    fprintf('Estimation of the stability matrix ...\n     Percentage done : ');
    curr_perc = -1;
end
stab = zeros([size(mat,2) length(opt.nb_classes)]); % Initialize the stability matrix
        
for num_s = 1:nb_samps

    if opt.flag_verbose
        new_perc = 5*floor(20*num_s/opt.nb_samps);
        if curr_perc~=new_perc
            fprintf(' %1.0f',new_perc);
            curr_perc = new_perc;
        end
    end
    dist = NaN;
    while any(isnan(dist))

        % Stratified bootstrap
        ind_boot = zeros([length(mask_strata) 1]);
        nb_ind = 0;
        for num_st = 1:max(mask_strata)
            list = find(mask_strata == num_st);
            list = list(1+floor(length(list)*rand([length(list) 1])));
            ind_boot((1+nb_ind):(length(list)+nb_ind)) = list;
            nb_ind = nb_ind+length(list);
        end
        data_boot.x    = model(ind_boot,:);
        data_boot.y    = mat(ind_boot,:);
        data_boot.c    = contrast_vec;
        
        %% Mahalanobis distance        
        dist = niak_stability_glm_distance(data_boot);
        dist = (dist-bias.mean_bias)./bias.std_bias;

        if any(isnan(dist))
           warning('Huho, the bootstrap model seems to be poorly conditioned, trying another sample ...\n')
        end
    end
    %% Clustering
    switch opt.clustering.type
        case 'hierarchical'
            opt.clustering.opt.flag_verbose = false;
            hier = niak_hierarchical_clustering(-dist,opt.clustering.opt);
            opt_t.thresh = opt.nb_classes;
            part = niak_threshold_hierarchy(hier,opt_t);
        otherwise
            error('%s is an unknown type of clustering',opt.clustering.type)
    end

    %% Update stability the matrix
    for num_sc = 1:length(opt.nb_classes)
        stab(:,num_sc) = stab(:,num_sc) + niak_mat2vec(niak_part2mat(part(:,num_sc),true));
    end
end
stab = stab / nb_samps;

if opt.flag_verbose
    fprintf('\n');
end

%% Save outputs
if opt.flag_verbose
    fprintf('Save outputs ...\n');
end
save(files_out,'stab','nb_classes','nb_samps')
