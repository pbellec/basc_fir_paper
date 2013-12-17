function [files_in,files_out,opt] = niak_brick_tmaps_rois(files_in,files_out,opt)
% Build t-maps of the modulation of functional connectivity from seeds
%
% SYNTAX:
% [FILES_IN,FILES_OUT,OPT] = NIAK_BRICK_TMAPS_ROIS(FILES_IN,FILES_OUT,OPT)
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
%           (string) The name of a .mat file with one variable VEC which is 
%           a vector. The variables VEC need to have the same length for 
%           all subjects.
%
%   ATOMS
%       (string) a 3D volume defining the space.
%
%   SEEDS
%       (string) the file name of a 3D volume, containing the seeds (seed
%       number I is filled with Is.
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
%   (structure) with the following fields:
%
%   TTEST
%       (string) the file name of a 4D dataset. VOL(:,:,:,n) is the t-stat map
%       corresponding the the specified test on the average functional connectivity
%       in the n-th seed region in FILES_IN.SEEDS.
%
%   EFFECT
%       (string) the file name of a 4D dataset. VOL(:,:,:,n) is the effect map
%       corresponding the the specified test on the average functional connectivity
%       in the n-th seed region in FILES_IN.SEEDS (the effect if a the combination
%       defined by the contrast on the effects of the covariates of the model).
%
%   STD
%       (string) the file name of a 4D dataset. VOL(:,:,:,n) is the map of
%       standard deviation of the effect in the specified test on the average
%       functional connectivity in the n-th seed region in FILES_IN.SEEDS (the
%       effect if a the combination defined by the contrast on the effects of the
%       covariates of the model).
%
%   FDR_VOL
%       (string) the file name of a 4D dataset. VOL(:,:,:,n) is the t-stat map
%       corresponding the the specified test on the average functional connectivity
%       in the n-th seed region in FILES_IN.SEEDS. All the t-values associated 
%       with a false-discovery rate below OPT.FDR_THRESHOLD are put to zero.
%
%   FDR_TEST
%       (string) a .mat file with one variable FDR_TEST, which is a structure. See
%       NIAK_BHT for more informations on the fields of this structure.
%
% OPT
%   (structure) with the following fields:
%
%   FDR_THRESOLD
%       (scalar, default 0.1) the minimal acceptable false-discovery rate.
%
%   NB_SAMPS_CDF
%       (integer, default 100) the number of bootstrap samples used to estimate the CDF.
%       See NIAK_BHT.
%
%   NB_SAMPS_FDR
%       (integer, default 100) the number of bootstrap samples used to estimate the FDR.
%       See NIAK_BHT.
%
%   FLAG_CORRECT_INTRA
%       (boolean, default true) if OPT.FLAG_CORRECT_INTRA is true, the average 
%       connectivity map is divided by the square root of the average connectivity 
%       inside the seed. For functional connectivity matrices, this is equivalent 
%       to use the average time series inside the seed to build a functional 
%       connectivity map.
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
% NIAK_PIPELINE_STABILITY, NIAK_PIPELINE_STABILITY_GLM, NIAK_BHT
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
% Keywords : GLM, functional connectivity

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialization and syntax checks %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Syntax
if ~exist('files_in','var')|~exist('files_out','var')|~exist('opt','var')
    error('niak:brick','syntax: [FILES_IN,FILES_OUT,OPT] = NIAK_BRICK_TMAPS_ROIS(FILES_IN,FILES_OUT,OPT).\n Type ''help niak_brick_tmaps_rois'' for more info.')
end

%% Files in
list_fields   = {'data' , 'model' , 'seeds' , 'atoms' };
list_defaults = {NaN    , NaN     , NaN     , NaN     };
files_in = psom_struct_defaults(files_in,list_fields,list_defaults);

if ~isstruct(files_in.data)
    error('FILES_IN.DATA should be a structure');
end

if ~ischar(files_in.atoms)
    error('FILES_IN.ATOMS should be a string')
end

if ~ischar(files_in.model)
    error('FILES_IN.MODEL should be a string')
end

if ~ischar(files_in.seeds)
    error('FILES_IN.SEEDS should be a cell of strings !')
end

%% Files out
list_fields   = { 'ttest'           , 'effect'          , 'std'             , 'fdr_vol'         , 'fdr_test'        };
list_defaults = { 'gb_niak_omitted' , 'gb_niak_omitted' , 'gb_niak_omitted' , 'gb_niak_omitted' , 'gb_niak_omitted' };
files_out = psom_struct_defaults(files_out,list_fields,list_defaults);

%% Options
list_fields   = { 'fdr_threshold' , 'nb_samps_cdf' , 'nb_samps_fdr' , 'flag_correct_intra' , 'test' , 'flag_verbose' , 'flag_test'  };
list_defaults = { 0.1             , 100            , 100            , true                 , NaN    , true           , false        };
opt = psom_struct_defaults(opt,list_fields,list_defaults);

list_fields   = {'label' , 'contrast' , 'projection' , 'flag_normalize' , 'flag_intercept' , 'type_normalization' };
list_defaults = {NaN     , NaN        , struct()     , true             , true             , 'none'               };
opt.test = psom_struct_defaults(opt.test,list_fields,list_defaults);

%% If the test flag is true, stop here !
if opt.flag_test == 1
    return
end

%% Reorganize files_in
model      = files_in.model;
file_atoms = files_in.atoms;
file_seeds = files_in.seeds;
list_subject = fieldnames(files_in.data);
nb_subject = length(list_subject);

%% Verbose ...
if opt.flag_verbose
    msg = sprintf('t-maps of modulation of functional connectivity');
    stars = repmat('*',[length(msg) 1]);
    fprintf('\n%s\n%s\n%s\n',stars,msg,stars);
end

%% Reading model
if opt.flag_verbose
    fprintf('Reading model ...\n')
end
opt_m.labels_x   = list_subject;
opt_m.labels_y   = fieldnames(opt.test.contrast);
opt_m.projection = opt.test.projection;
opt_m.contrast   = opt.test.contrast;
[model,labels_subject,labels_covariate,contrast_vec] = niak_read_model(model,opt_m);

%% Read the individual connectivity matrices
if opt.flag_verbose
    fprintf('Reading the individual connectomes ...\n');
end
%% Averge connectomes in each seed
[hdr,atoms] = niak_read_vol(file_atoms);
[hdr,seed]  = niak_read_vol(file_seeds);
list_seed = unique(seed(:));
list_seed = list_seed(list_seed~=0);
list_seed = list_seed(:)';
nb_seed = length(list_seed);
max_seed = max(list_seed);

for num_e = 1:length(labels_subject);
    if opt.flag_verbose
        fprintf('    %s\n',files_in.data.(labels_subject{num_e}));
    end
    data_subj = load(files_in.data.(labels_subject{num_e}));
    for num_seed = 1:nb_seed
        ind = unique(atoms(seed == list_seed(num_seed)));
        ind = ind(ind~=0);        
        mat_subj = niak_vec2mat(data_subj.mat_r);
        if (num_e == 1)&&(num_seed==1)            
            mat_seed = zeros([length(labels_subject) size(mat_subj,1) nb_seed]);
        end
        if isempty(ind)
            error('The seed number %i does not intersect with any atom',list_seed(num_m))
        end
        if opt.flag_correct_intra            
            mat_seed(num_e,:,num_seed) = mean(mat_subj(:,ind),2)/sqrt(mean(mean(mat_subj(ind,ind))));
        else
            mat_seed(num_e,:,num_seed) = mean(mat_subj(:,ind),2);
        end
    end
    switch opt.test.type_normalization
        case 'none'
                
        case 'med_mad'
            mat_seed(num_e,:,:) = (mat_seed(num_e,:,:) - median(data_subj.mat_r)) / niak_mad(data_subj.mat_r);
        case 'z_med_mad'
            data_subj.mat_r = niak_fisher(data_subj.mat_r);
            mat_seed(num_e,:,:) = (niak_fisher(mat_seed(num_e,:,:)) - median(data_subj.mat_r)) / niak_mad(data_subj.mat_r);
        case 'mean_var'
            mat(num_e,:,:) = niak_normalize_tseries(squeeze(mat_seed(num_e,:,:)));
        otherwise
            error('%s is an unknown normalization method',opt.test.type_normalization)
    end
end


%% Derive FDR estimates
data.x    = model;
data.y    = reshape(mat_seed,[size(mat_seed,1) size(mat_seed,2)*size(mat_seed,3)]);
data.c    = contrast_vec;
opt_bht.bootstrap.name_boot = 'niak_stability_glm_null';
opt_bht.measure.name_mes = 'niak_stability_glm_ttest';
opt_bht.cdf.nb_samps = opt.nb_samps_cdf;
opt_bht.cdf.flag_pooled = true;
opt_bht.cdf.limits= [-10 ; 10];
opt_bht.cdf.nb_bins = 500;
opt_bht.cdf.valx = [-10 ; 10];
opt_bht.cdf.valy = [0 ; 1];
opt_bht.fdr.nb_samps = opt.nb_samps_fdr;
opt_bht.side = 'two-sided';
fdr_test = niak_bht(data,opt_bht);

% Reformat the outputs of the FDR tests
fdr_test.pce = reshape(fdr_test.pce,[size(mat_seed,2) size(mat_seed,3)]);
fdr_test.plugin = reshape(fdr_test.plugin,[size(mat_seed,2) size(mat_seed,3)]);
fdr_test.mean = reshape(fdr_test.mean,[size(mat_seed,2) size(mat_seed,3)]);
fdr_test.std = reshape(fdr_test.std,[size(mat_seed,2) size(mat_seed,3)]);
fdr_test.fdr = reshape(fdr_test.fdr,[size(mat_seed,2) size(mat_seed,3)]);
fdr_test.list_seed = list_seed;

%% Building the t-map
if opt.flag_verbose
        fprintf('Building effect/std/t-test maps for each seed : ')
end
t_maps   = zeros([size(atoms) max_seed]);
fdr_maps   = zeros([size(atoms) max_seed]);
eff_maps = zeros([size(atoms) max_seed]);
std_maps = zeros([size(atoms) max_seed]);

for num_seed = 1:nb_seed
    if opt.flag_verbose
        fprintf('%i - ',num_seed);
    end
    num_m = list_seed(num_seed);
    [beta,E,std_noise,ttest] = niak_lse(mat_seed(:,:,num_seed),model,contrast_vec,false);
    d = sqrt(contrast_vec'*(model'*model)^(-1)*contrast_vec);
    eff = contrast_vec'*beta;
    std_e = std_noise*d;    
    t_maps(:,:,:,num_m)   = niak_part2vol(ttest,atoms);
    eff_maps(:,:,:,num_m) = niak_part2vol(eff,atoms);
    std_maps(:,:,:,num_m) = niak_part2vol(std_e,atoms);
    ttest(abs(fdr_test.fdr)>opt.fdr_threshold) = 0;
    fdr_maps(:,:,:,num_m) = niak_part2vol(ttest,atoms);
end

%% Writing results
if opt.flag_verbose
    fprintf('\nWriting results ...\n')
end

% t-test maps
if ~strcmp(files_out.ttest,'gb_niak_omitted')
    hdr.file_name = files_out.ttest;
    niak_write_vol(hdr,t_maps);
end

% FDR-thresholded t-test maps
if ~strcmp(files_out.fdr_vol,'gb_niak_omitted')
    hdr.file_name = files_out.fdr_vol;
    niak_write_vol(hdr,fdr_maps);
end

% effect maps
if ~strcmp(files_out.effect,'gb_niak_omitted')
    hdr.file_name = files_out.effect;
    niak_write_vol(hdr,eff_maps);
end

% std maps
if ~strcmp(files_out.std,'gb_niak_omitted')
    hdr.file_name = files_out.std;
    niak_write_vol(hdr,std_maps);
end

% FDR test
if ~strcmp(files_out.fdr_test,'gb_niak_omitted')
    save(files_out.fdr_test,fdr_test)
end

if opt.flag_verbose
    fprintf('Done !\n')
end

