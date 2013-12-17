function [files_in,files_out,opt] = niak_brick_glm_connectome(files_in,files_out,opt)
% Estimate a group-level GLM on an ensemble of connectomes.
%
% SYNTAX:
% [FILES_IN,FILES_OUT,OPT] = NIAK_BRICK_GLM_CONNECTOME(FILES_IN,FILES_OUT,OPT)
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
% FILES_OUT
%   (string) a .mat file with the following matlab variables:
%
%   MODEL
%       (matrix N*K) each column is a covariate of the model
%
%   LABELS_SUBJECT
%       (cell of strings) LABELS_SUBJECT{N} is the label of
%       the subject associated with MODEL(N,:)
%
%   LABELS_COVARIATE
%       (cell of strings) LABELS_COVARIATE{K} is the label of
%       the subject associated with MODEL(:,K)
%
%   CONTRAST_VEC
%       (vector K*1) CONTRAST_VEC(K) is the weight of MODEL(:,K)
%       in the contrast.
%
%   BETA
%       (matrix K*S*(S-1)/2) BETA(K,:) is a vectorized version
%       of the S*S matrix of effects for each connection for
%       covariate MODEL(:,K). Note that a James-Stein correction
%       is applied on BETA if the number of covariates is greater
%       or equal to 3, and OPT.FLAG_JAMES_STEIN is true (see below)
%
%   STD_NOISE
%       (matrix S*S) estimate of the standard deviation of noise
%       at each connection
%
%   TTEST
%       (matrix S*S) A t-test for the significance of the contrast
%       at each connection.
%
% OPT
%   (structure) with the following fields:
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
%   PERC
%       (scalar, default 0.1) the percentage of brain regions that are used 
%       to guide the clustering.
%
%   NB_SAMPS_BIAS
%       (integer, default 100) the number of samples used in the bootstrap
%       estimation of the bias on mahalanobis distance.
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
% opérationnelle, Université de Montréal, 2010-2011.
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : GLM, functional connectivity, connectome

% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%mode
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

%% Syntax
if ~exist('files_in','var')|~exist('files_out','var')|~exist('opt','var')
    error('niak:brick','syntax: [FILES_IN,FILES_OUT,OPT] = NIAK_BRICK_GLM_CONNECTOME(FILES_IN,FILES_OUT,OPT).\n Type ''help niak_brick_glm_connectome'' for more info.')
end

%% Files in
list_fields   = { 'data' , 'model' };
list_defaults = { NaN    , NaN     };
files_in = psom_struct_defaults(files_in,list_fields,list_defaults);

if ~isstruct(files_in.data)
    error('FILES_IN.DATA should be a structure');
end

if ~ischar(files_in.model)
    error('MODEL should be a string')
end

%% Files out
if ~ischar(files_out)
    error('FILES_OUT should be a string!')
end

%% Options
list_fields   = { 'rand_seed' , 'nb_samps_bias' , 'perc' , 'test' , 'flag_verbose' , 'flag_test'  };
list_defaults = { []          , 100             , 0.1    , NaN    , true           , false        };
opt = psom_struct_defaults(opt,list_fields,list_defaults);

list_fields   = { 'type_normalization' , 'label' , 'contrast' , 'projection' , 'flag_normalize' , 'flag_intercept' };
list_defaults = { 'none'               , NaN     , NaN        , struct()     , true             , true             };
opt.test = psom_struct_defaults(opt.test,list_fields,list_defaults);

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

%% Read the individual connectivity matrices
if opt.flag_verbose
    fprintf('Reading (and normalizing) the individual connectomes ...\n');
end

for num_s = 1:length(labels_subject);
    if opt.flag_verbose
        fprintf('    %s\n',files_in.data.(labels_subject{num_s}));
    end
    data_subj = load(files_in.data.(labels_subject{num_s}));
    if num_s == 1
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

%% Estimate the model
if opt.flag_verbose
    fprintf('Estimate model ...\n')
end
[beta,E,std_noise,ttest] = niak_lse(mat,model,contrast_vec);

%% Estimate the bias on distance between effect maps  
data.x    = model;
data.y    = mat;
data.c    = contrast_vec;
[dist,target] = niak_stability_glm_distance(data);

bootstrap.name_boot = 'niak_stability_glm_null';
measure.name_mes = 'niak_stability_glm_distance';
measure.opt_mes = 0;
cdf.nb_samps = opt.nb_samps_bias;
cdf.flag_mean_std = true;
[tmp1,tmp2,mean_bias,std_bias] = niak_build_cdf(data,bootstrap,measure,cdf);

%% Save outputs
save(files_out,'beta','std_noise','ttest','model','labels_covariate','labels_subject','contrast_vec','mean_bias','std_bias','target','dist')
