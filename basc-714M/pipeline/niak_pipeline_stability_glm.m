function [pipeline,opt] = niak_pipeline_stability_glm(files_in,opt)
% Analysis of stable clusters in a connectivity-based GLM
%
% SYNTAX:
% [PIPELINE,OPT] = NIAK_PIPELINE_STABILITY_GLM(FILES_IN,OPT)
%
% _________________________________________________________________________
% INPUTS
%
% FILES_IN  
%   (structure) with the following fields : 
%
%   DATA
%       (structure) with the following fields :
%
%       <SUBJECT>
%           (cell of strings) a list of fMRI datasets, acquired for the 
%           same subject. The field names <SUBJECT> can be any arbitrary 
%           strings.  Note that time series can be specified directly as
%           variables in a .mat file. The file FILES_IN.ATOMS needs to be
%           specified in that instance.
%
%   MODEL
%       (string) the name of a CSV file. Example :
%                 , SEX , HANDENESS
%       <SUBJECT> , 0   , 0 
%       This type of file can be generated with Excel (save under CSV, no 
%	    dstring delimiter).
%       Each column defines a covariate that can be used in a linear model.
%       See OPT.CONTRASTS below.
%
%   AREAS
%       (string, default AAL template from NIAK) the name of the brain 
%       parcelation template that will be used to constrain the region 
%       growing.
%
%   MASK
%       (string) a file name of a binary mask common to all subjects and 
%       runs. it will be ignored if FILES_IN.ATOMS is specified.
%
%   ATOMS
%       (string, optional) a file name of a mask of brain regions (region I
%       is filled with Is, 0 is for the background). The analysis will be
%       done at the level of these atomic regions. This means that the fMRI
%       time series will be averaged in each region, and the stability
%       analysis will be carried on these regional time series. If
%       unspecified, the regions will be built using a region growing
%       approach. It is also possible to enter directly regional time series
%       in the analysis (see FILES_IN.DATA), and ATOMS needs to be specified
%       in that instance.
%
%   SEEDS
%       (structure, optional) with arbitrary fields:
%  
%           <LABEL_SEEDS>
%               (string, optionnal) a file name of a mask of brain regions 
%               (region I is filled with Is, 0 is for the background). The 
%               regions do not need to be spatially connected. These regions 
%               will be used as a priori targets to generate effect maps 
%               (and t-stats) for all tests.
%
% OPT
%   (structure) with the following fields : 
%
%   FOLDER_OUT 
%       (string) where to write the results of the pipeline. 
%
%   TEST
%       (stucture) with multiple entries and the following fields :
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
%              'none' : no normalizaton, i.e. regular functional connectivity
%              'med_mad' : correct for zero median and unit variance using a 
%                median absolute deviation to the median estimate.
%
%   GRID_SCALES
%       (vector) GRID_SCALES(K) is the number of clusters for test number K.
%
%   SCALES_MAPS
%       (array, default []) SCALES_MAPS(K,:) is the list of scales that will
%       be used to generate stability and t-test maps:
%           SCALES_MAPS(K,1) is the number of group clusters
%           SCALES_MAPS(K,2) is the number of final clusters
%       Usually the pipeline runs a first time to get the results of the MSTEPS
%       selection, and then the scale parameters selected by MSTEPS are used to
%       set SCALES_MAPS.
%
%   STRATA
%       (structure, optional) with multiple entries, each one with the
%       following fields :
%
%       LABEL
%           (string) the name of a covariate.
%
%       NB_STRATA
%           (integer) the subjects will be partitioned into close-to-even
%           strata based on the distribution of the covariate OPT.LABEL.
%
%   FLAG_ROI
%       (boolean, default false) if the flag is true, the pipeline is only
%       going to perform the region growing.
%
%   REGION_GROWING
%       (structure, optional) see the OPT argument of
%       NIAK_PIPELINE_REGION_GROWING. The default parameters may work.
%
%   NB_SAMPS
%       (integer, default 25) the number of samples to use in the
%       bootstrap Monte-Carlo approximation of stability per cores
%       (see OPT.NB_CORES below).
%
%   NB_SAMPS_BIAS
%	(integer, default 100) the number of samples used in the bootstrap
%       estimation of the bias on mahalanobis distance.
%
%   PERC
%       (scalar, default 0.1) the percentage of brain regions that are used 
%       to guide the clustering.
%
%   NB_CORES
%       (integer, default 40) the number of "cores" in the stability
%       estimation. The effective number of bootstrap samples is
%       OPT.NB_SAMPS times OPT.NB_CORES.
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
%   FLAG_RAND
%       (boolean, default 0) If the flag is true, the seed of the random
%       number generator is set based on the clock with PSOM_SET_RAND_SEED
%       (the results will be slightly different due to random variations
%       in bootstrap sampling if the pipeline is executed twice).
%       Otherwise, some fixed seeds are used for each estimation of
%       the stability, and the results of the pipeline are reproducible.
%
%   CONSENSUS
%       (structure, optional) This structure describes
%       the clustering algorithm used to estimate a consensus clustering on
%       each stability matrix, with the following fields :
%
%       TYPE
%           (string, default 'hierarchical') the clustering algorithm
%           Available options : 'hierarchical'
%
%       OPT
%           (structure, default see NIAK_HIERARCHICAL_CLUSTERING) options
%           that will be  sent to the  clustering command. The exact list
%           of options depends on CLUSTERING.TYPE:
%              'hierarchical' : see NIAK_HIERARCHICAL_CLUSTERING
%
%
%   NEIGH
%       (vector, default [0.7 0.1 1.3]) defines the local neighbourhood of
%       a number of clusters to derive local maxima in contrast
%       functions and explore the scales. For each scale L, all scales in
%       ceil(neigh*L) will be tested. A number of clusters L will be defined as
%       local maximum if the associated summary measure of stability is higher
%       or equal than for any other scale in [NEIGH(1)*L NEIGH(end)*L].
%
%   PARAM
%       (scalar, default 0.05) if PARAM is comprised between 0 and 1, it is
%       the percentage of multiscale residual squares unexplained by the subset
%       of critical scales selected by the MSTEPS procedure.
%       If PARAM is larger than 1, it is assumed to be an integer, which is
%       used directly to set the number of scales in MSTEPS.
%
%   STABILITY_MAPS
%       (structure) the options that will be passed to
%       NIAK_BRICK_STABILITY_MAPS
%
%   STABILITY_FIGURE
%       (structure) the options that will be passed to
%       NIAK_BRICK_STABILITY_FIGURE
%
%   PSOM
%       (structure, optional) the options of the pipeline manager. See the
%       OPT argument of PSOM_RUN_PIPELINE. Default values can be used here.
%       Note that the field PSOM.PATH_LOGS will be set up by the pipeline.
%
%   FLAG_TEST
%       (boolean, default false) If FLAG_TEST is true, the pipeline will
%       just produce a pipeline structure, and will not actually process
%       the data. Otherwise, PSOM_RUN_PIPELINE will be used to process the
%       data.
%
%   FLAG_VERBOSE
%       (boolean, default true) Print some advancement infos.
%
% _________________________________________________________________________
% OUTPUTS : 
%
% PIPELINE 
%   (structure) describe all jobs that need to be performed in the 
%   pipeline. This structure is meant to be use in the function
%   PSOM_RUN_PIPELINE.
%
% OPT
%   (structure) same as input, but updated for default values.
%
% _________________________________________________________________________
% COMMENTS:
%
% This pipeline assumes fully preprocessed fMRI data in stereotaxic space
% as inputs. See NIAK_PIPELINE_FMRI_PREPROCESS.
%
% _________________________________________________________________________
% Copyright (c) Pierre Bellec 
%               Centre de recherche de l'institut de Gériatrie de Montréal
%               Département d'informatique et de recherche opérationnelle
%               Université de Montréal, 2010-2011.
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : pipeline, GLM, fMRI, functional connectivity, clustering, stability

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

%% Syntax
if ~exist('files_in','var')||~exist('opt','var')
    error('niak:pipeline','syntax: PIPELINE = NIAK_PIPELINE_STABILITY_GLM(FILES_IN,OPT).\n Type ''help niak_pipeline_stability_glm'' for more info.')
end

%% Checking that FILES_IN is in the correct format
list_fields   = {'atoms'           , 'data' , 'model' , 'mask'            , 'areas'           , 'seeds'           };
list_defaults = {'gb_niak_omitted' , NaN    , NaN     , 'gb_niak_omitted' , 'gb_niak_omitted' , 'gb_niak_omitted' };
files_in      = psom_struct_defaults(files_in,list_fields,list_defaults);

file_atoms = files_in.atoms;
model      = files_in.model;
mask       = files_in.mask;
areas      = files_in.areas;
seeds      = files_in.seeds;
files_in   = files_in.data;

list_subject = fieldnames(files_in);
nb_subject   = length(list_subject);

for num_s = 1:nb_subject    
    subject = list_subject{num_s};    
    if ~iscellstr(files_in.(subject))
        error('FILES_IN.DATA.%s is not a cell of strings!',upper(subject));
    end    
end
[path_f,name_f,ext_f] = niak_fileparts(files_in.(list_subject{num_s}){1});

%% Options
opt_clustering.type  = 'hierarchical';
opt_clustering.opt   = struct();
opt_consensus.type   = 'hierarchical';
list_fields   = { 'perc' , 'strata' , 'nb_samps_bias' ,  'param' , 'nb_samps' , 'nb_cores' , 'clustering'   , 'consensus'   , 'neigh'      , 'flag_rand' , 'flag_tseries' , 'flag_roi' , 'psom'   , 'folder_out' , 'test'   , 'flag_verbose' , 'grid_scales' , 'scales_maps' , 'flag_test' , 'region_growing' , 'stability_maps' , 'stability_figure' };
list_defaults = { 0.1    , struct() , 100             ,  0.05    , 25         , 40         , opt_clustering , opt_consensus , 0.7:0.1:1.3  , 0           , []             , false      , struct() , NaN          , NaN      , true           , NaN           , NaN           , false       , struct()         , struct()         , struct()           };
opt = psom_struct_defaults(opt,list_fields,list_defaults);
if ~strcmp(opt.folder_out(end),filesep)
    opt.folder_out = [opt.folder_out filesep];
end

if isempty(opt.flag_tseries)
    opt.flag_tseries = strcmp(ext_f,'.mat');
end
if isempty(opt.grid_scales)&&~opt.flag_roi
    error('Please specify OPT.GRID_SCALES')
end
opt.psom.path_logs = [opt.folder_out 'logs' filesep];

% converts the list of fmri runs into a cell
cell_fmri = cell([nb_subject 1]);
subj_fmri = cell([nb_subject 1]);
run_fmri  = cell([nb_subject 1]);

for num_s = nb_subject:-1:1
    name_subject = list_subject{num_s};
    cell_fmri{num_s} = files_in.(name_subject)(:)';
    subj_fmri{num_s} = repmat({name_subject},size(cell_fmri{num_s}));
    run_fmri{num_s} = 1:length(cell_fmri{num_s});
end
cell_fmri = [cell_fmri{:}];
subj_fmri = [subj_fmri{:}];
run_fmri  = [run_fmri{:}];
nb_files  = length(cell_fmri);
labels_file = cell([nb_files 1]);
for num_f = 1:nb_files
    labels_file{num_f} = [subj_fmri{num_f} '_run' num2str(run_fmri(num_f))];
end
pipeline = struct();

%% Region growing
if strcmp(file_atoms,'gb_niak_omitted')
    clear job_in job_out job_opt
    job_in.fmri           = cell_fmri;
    job_in.areas          = areas;
    job_in.mask           = mask;
    job_opt                     = opt.region_growing;
    job_opt.folder_out          = opt.folder_out;
    job_opt.flag_test           = 1;
    job_opt.flag_tseries        = false;
    job_opt.labels              = labels_file;
    pipeline = niak_pipeline_region_growing(job_in,job_opt);
    file_atoms = pipeline.merge_part.files_out.space;
else % Copy the atoms
    [path_f,name_f,ext_f] = niak_fileparts(file_atoms);
    pipeline.brain_atoms.command   = 'system([''cp '' files_in '' '' files_out]);';
    pipeline.brain_atoms.files_in  = file_atoms;
    pipeline.brain_atoms.files_out = [opt.folder_out 'rois' filesep 'brain_atoms' ext_f];
end

%% Extract time series
files_tseries = cell([nb_subject 1]);
if ~opt.flag_tseries
    for num_s = 1:nb_subject
        subject = list_subject{num_s};
        clear job_in job_out job_opt
        list_runs = files_in.(subject);
        job_opt.flag_all = false;
        job_opt.flag_std = false;
        job_opt.type_correction = 'mean_var';
        files_tseries{num_s} = cell([length(list_runs) 1]);
        for num_r = 1:length(list_runs)
            name_job = ['tseries_atoms_' subject '_run' num2str(num_r)];
            job_in.fmri = list_runs(num_r);
            job_in.mask = file_atoms;
            job_out.tseries{1} = [opt.folder_out 'rois' filesep 'tseries_rois_' subject '_run' num2str(num_r) '.mat'];
            pipeline = psom_add_job(pipeline,name_job,'niak_brick_tseries',job_in,job_out,job_opt,false);
            files_tseries{num_s}{num_r} = job_out.tseries{1};
        end
    end
else
    for num_s = 1:nb_subject
        files_tseries{num_s} = files_in.(list_subject{num_s});
    end
end

%% Individual correlation matrices
cell_corr = cell([nb_subject 1]);
for num_s = 1:nb_subject
    subject = list_subject{num_s};
    clear job_in job_out job_opt
    job_in.fmri    = files_tseries{num_s};
    job_out        = [opt.folder_out 'connectomes' filesep 'correlation_' subject '_roi.mat'];
    job_opt.flag_vec     = true;
    job_opt.flag_tseries = false;
    job_opt.flag_verbose = true;
    job_opt.flag_test    = false;
    job_opt.folder_out   = opt.folder_out;
    cell_corr{num_s}     = job_out;
    pipeline = psom_add_job(pipeline,['correlation_subject_' subject],'niak_brick_correlation_rois',job_in,job_out,job_opt,false);
end

%% Run GLM estimation as well as bias estimation on the Mahalanobis distance under the null
clear job_in job_out job_opt
for num_s = 1:nb_subject
    subject = list_subject{num_s};
    job_in.data.(subject) = cell_corr{num_s};
end
job_in.model = model;
for num_c = 1:length(opt.test)
    test = opt.test(num_c).label;
    job_opt.test = opt.test(num_c);
    job_opt.nb_samps_bias = opt.nb_samps_bias;
    job_opt.perc = opt.perc;
    if ~opt.flag_rand
        job_opt.rand_seed = 0;
    else
        job_opt.rand_seed = [];
    end
    job_out = [opt.folder_out test filesep 'glm_' test '.mat'];
    pipeline = psom_add_job(pipeline,['glm_' test],'niak_brick_glm_connectome',job_in,job_out,job_opt);
end

%% the stability analysis
for num_c = 1:length(opt.test) % Loop over the tests

    % Start all cores
    cell_cores = cell([opt.nb_cores 1]);
    clear job_in job_out job_opt
    test    = opt.test(num_c).label;
    job_in  = pipeline.(['glm_' test]).files_in;
    job_in.bias = pipeline.(['glm_' test]).files_out;
    job_opt.nb_classes = opt.grid_scales;
    job_opt.nb_samps   = opt.nb_samps;
    job_opt.clustering = opt.clustering;
    job_opt.strata = opt.strata;
    job_opt.test = opt.test(num_c);
    for num_b = 1:opt.nb_cores
        if ~opt.flag_rand
            job_opt.rand_seed = round(1000*(1/(num_b+1)).^((2:25).^(-1)));
        else
            job_opt.rand_seed = [];
        end
        job_out = [opt.folder_out test filesep 'stability_' test '_core' num2str(num_b) '.mat'];
        cell_cores{num_b} = job_out;
        pipeline = psom_add_job(pipeline,['stability_' test '_core' num2str(num_b)],'niak_brick_stability_glm_cores',job_in,job_out,job_opt);
    end

    % Merge the results of all cores
    clear job_in job_out job_opt
    job_in = cell_cores;
    job_out = [opt.folder_out test filesep 'stability_' test '.mat'];
    job_opt.consensus = opt.consensus;
    pipeline = psom_add_job(pipeline,['stability_' test '_consensus'],'niak_brick_stability_glm',job_in,job_out,job_opt);

    % Clean the intermediate "core" results
    pipeline = psom_add_clean(pipeline,['clean_stability_' test '_cores'],cell_cores);

    %% summary of average individual-level stability
    clear job_in job_out job_opt
    job_in{1} = pipeline.(['stability_' test '_consensus']).files_out;
    job_out.sil_all        = [opt.folder_out test filesep 'summary_stab_' test '.mat'];
    job_out.figure_sil_max = [opt.folder_out test filesep 'summary_stab_' test '.pdf'];
    job_out.table_sil_max  = [opt.folder_out test filesep 'summary_stab_' test '.csv'];
    job_opt.nb_classes   = opt.grid_scales;
    job_opt.neigh        = opt.neigh;
    job_opt.flag_verbose = opt.flag_verbose;
    pipeline = psom_add_job(pipeline,['summary_stability_' test],'niak_brick_stability_summary_ind',job_in,job_out,job_opt);

    %% MSTEPS
    clear job_in job_out job_opt
    job_in               = pipeline.(['stability_' test '_consensus']).files_out;
    job_out.msteps       = [opt.folder_out test filesep 'msteps_' test '.mat'];
    job_out.table        = [opt.folder_out test filesep 'msteps_' test '.csv'];
    if opt.flag_rand
        job_opt.rand_seed = [];
    else
        job_opt.rand_seed = 0;
    end
    job_opt.neigh        = opt.neigh;
    job_opt.param        = opt.param;
    job_opt.flag_verbose = opt.flag_verbose;
    pipeline = psom_add_job(pipeline,['msteps_' test],'niak_brick_msteps',job_in,job_out,job_opt);

    if ~isempty(opt.scales_maps)
        %% Stability maps
        clear job_in job_out job_opt
        job_in.stability = pipeline.(['stability_' test '_consensus']).files_out;
        job_in.hierarchy = pipeline.(['stability_' test '_consensus']).files_out;
        job_in.atoms = file_atoms;
        for num_sc = 1:size(opt.scales_maps,1)
            nb_cluster = opt.scales_maps(num_sc,end);
            label_scale = ['sci' num2str(opt.scales_maps(num_sc,1)) '_scf' num2str(opt.scales_maps(num_sc,end))];
            job_out.partition_consensus{num_sc}  = [opt.folder_out test filesep label_scale filesep 'brain_partition_consensus_' test '_' label_scale ext_f];
            job_out.partition_core{num_sc}       = [opt.folder_out test filesep label_scale filesep 'brain_partition_core_'      test '_' label_scale ext_f];
            job_out.partition_adjusted{num_sc}   = [opt.folder_out test filesep label_scale filesep 'brain_partition_adjusted_'  test '_' label_scale ext_f];
            job_out.partition_threshold{num_sc}  = [opt.folder_out test filesep label_scale filesep 'brain_partition_threshold_' test '_' label_scale ext_f];
            job_out.stability_map_all{num_sc}    = [opt.folder_out test filesep label_scale filesep 'compound_stability_map_'    test '_' label_scale ext_f];
            job_out.stability_maps{num_sc}       = [opt.folder_out test filesep label_scale filesep 'stability_maps_'            test '_' label_scale ext_f];
        end
        job_opt = opt.stability_maps;
        job_opt.scales_maps = opt.scales_maps(:,[1 1 size(opt.scales_maps,2)]);
        pipeline = psom_add_job(pipeline,['stability_maps_' test],'niak_brick_stability_maps',job_in,job_out,job_opt);

        % Figures
        clear job_in job_out job_opt
        job_in.stability    = pipeline.(['stability_' test '_consensus']).files_out;
        job_in.hierarchy    = pipeline.(['stability_' test '_consensus']).files_out;
        job_opt             = opt.stability_figure;
        job_opt.scales_maps = opt.scales_maps(:,[1 size(opt.scales_maps,2)]);
        for num_sc = 1:size(opt.scales_maps,1)
            label_scale            = ['sci' num2str(opt.scales_maps(num_sc,1)) '_scf' num2str(opt.scales_maps(num_sc,end))];
            job_out{num_sc}  = [opt.folder_out test filesep label_scale filesep 'stability_figure_' test '_' label_scale '.pdf'];
            job_opt.labels{num_sc} = ['sci' num2str(opt.scales_maps(num_sc,1)) ' scf' num2str(opt.scales_maps(num_sc,end))];
        end
        pipeline = psom_add_job(pipeline,['figure_stability_' test],'niak_brick_stability_figure',job_in,job_out,job_opt);

        %% Generate t-stat maps
        clear job_in job_out job_opt
        for num_s = 1:nb_subject
            job_in.data.(list_subject{num_s}) = cell_corr{num_s};
        end
        job_in.model = model;
        job_in.atoms = file_atoms;
        for num_sc = 1:size(opt.scales_maps,1)
            nb_cluster = opt.scales_maps(num_sc,end);
            label_scale = ['sci' num2str(opt.scales_maps(num_sc,1)) '_scf' num2str(opt.scales_maps(num_sc,end))];
            job_in.seeds         = pipeline.(['stability_maps_' test]).files_out.partition_core{num_sc};
            job_out.ttest        = [opt.folder_out test filesep label_scale filesep 'ttest_' test '_' label_scale ext_f];
            job_out.effect       = [opt.folder_out test filesep label_scale filesep 'effect_' test '_' label_scale ext_f];
            job_out.std          = [opt.folder_out test filesep label_scale filesep 'std_' test '_' label_scale ext_f];
            job_opt.test         = opt.test(num_c);
            job_opt.flag_verbose = opt.flag_verbose;
            pipeline = psom_add_job(pipeline,['tmaps_' test  '_' label_scale],'niak_brick_tmaps_rois',job_in,job_out,job_opt);
        end
    end
    
    if ~strcmp(seeds,'gb_niak_omitted')
        list_seeds = fieldnames(seeds);
        for num_seed = 1:length(list_seeds)
            label_seeds = list_seeds{num_seed};
            %% Generate t-stat maps for the seeds
            clear job_in job_out job_opt
            for num_s = 1:nb_subject
                job_in.data.(list_subject{num_s}) = cell_corr{num_s};
            end
            job_in.model     = model;
            job_in.atoms     = file_atoms;
            job_in.seeds     = seeds.(label_seeds);
            job_out.ttest    = [opt.folder_out test filesep 'seeds' filesep 'ttest_' test '_' label_seeds ext_f];
            job_out.fdr_vol  = [opt.folder_out test filesep 'seeds' filesep 'fdr_' test '_' label_seeds ext_f];
            job_out.fdr_test = [opt.folder_out test filesep 'seeds' filesep 'fdr_' test '_' label_seeds '.mat'];
            job_out.effect   = [opt.folder_out test filesep 'seeds' filesep 'effect_' test '_' label_seeds ext_f];
            job_out.std      = [opt.folder_out test filesep 'seeds' filesep 'std_' test '_' label_seeds ext_f];
            job_opt.test         = opt.test(num_c);
            job_opt.flag_verbose = opt.flag_verbose;
            pipeline = psom_add_job(pipeline,['tmaps_' test  '_' label_seeds],'niak_brick_tmaps_rois',job_in,job_out,job_opt);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%
%% Run the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%
if ~opt.flag_test
    psom_run_pipeline(pipeline,opt.psom);
end
