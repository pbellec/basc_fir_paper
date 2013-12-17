function [pipeline,opt] = niak_pipeline_stability_fir(files_in,opt)
% Analysis of stable clusters using finite-impulse response (FIR) in fMRI
%
% SYNTAX:
% [PIPELINE,OPT] = NIAK_PIPELINE_STABILITY_FIR(FILES_IN,OPT)
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
%       <SUBJECT>.FMRI
%           (cell of strings) a list of fMRI datasets, acquired for the 
%           same subject. The field names <SUBJECT> can be any arbitrary 
%           strings.  Note that FIR estimates can be specified directly as
%           variables in a .mat file. See FILES_IN.ATOMS and
%           OPT.FLAG_FIR below.
%
%       <SUBJECT>.TIMING
%       	(cell of strings) a list of .mat files. TIMING{I} contains two 
%           variables :
%           
%           TIME_FRAMES
%               (vector) a list of times corresponding to each volume of 
%               FMRI{I}
%
%           TIME_EVENTS
%               (vector) a list of event time that will be used to derive 
%               the FIR estimation for fMRI{I}.
%
%   INFOS
%       (string) the name of a CSV file. Example :
%                 , SEX , HANDENESS
%       <SUBJECT> , 0   , 0 
%       This type of file can be generated with Excel (save under CSV).
%       The infos will be used to "stratify" the data, i.e. resampling of
%       the data will be restricted within groups of subjects that share 
%       identical infos. All strata will be given equal weights to build
%       the consensus across subjects.
%
%   AREAS
%       (string, default AAL template from NIAK) the name of the brain 
%       parcelation template that will be used to constrain the region 
%       growing.
%
%   MASK
%       (string) a file name of a binary mask common to all subjects and 
%       runs.
%
%   ATOMS
%       (string) a file name of a mask of brain regions (region I is filled 
%       with Is, 0 is for the background). The analysis will be done at the 
%       level of these atomic regions. This means that the fMRI time series
%       will be averaged in each region, and the stability analysis will be
%       carried on these regional time series. If unspecified, the regions
%       will be built using a region growing approach.
%
% OPT   
%   (structure) with the following fields : 
%       
%   FOLDER_OUT 
%       (string) where to write the results of the pipeline. 
%
%   GRID_SCALES
%       (vector) GRID_SCALES describes the grid of scale parameters that
%       will be investigated. GRID_SCALES(K) is more specifically the number
%       of individual clusters for test number K. Some combinations of scales
%       will be investigated at the individual and group levels. Basically
%       the group scales located in a neighbourhood of each individual scale
%       (see OPT.NEIGH below) will be tested, as well as all possible final
%       number of clusters, whether it be at the individual or the group levels.
%
%   SCALES_MAPS
%       (array, default []) SCALES_MAPS(K,:) is the list of scales that will
%       be used to generate stability maps (individual, group and mixed
%       levels, depending on the flags described below):
%           SCALES_MAPS(K,1) is the number of individual clusters
%           SCALES_MAPS(K,2) is the number of group clusters
%           SCALES_MAPS(K,3) is the number of final clusters
%       Usually the pipeline runs a first time to get the results of the MSTEPS
%       selection, and then the scale parameters selected by MSTEPS are used to
%       set SCALES_MAPS.
%
%   NEIGH
%       (vector, default [0.7 0.1 1.3]) defines the local neighbourhood of
%       a number of group clusters to derive local maxima in contrast
%       functions and explore the individual/group scales. More
%       specifically, for each group scale L, all scales in ceil(neigh*L)
%       will be tested. A number of clusters L will be defined as local
%       maximum if the associated summary measure of stability is higher
%       or equal than for any other scale in [NEIGH(1)*L NEIGH(end)*L].
%
%   PARAM
%       (scalar, default 0.05) if PARAM is comprised between 0 and 1, it is
%       the percentage of multiscale residual squares unexplained by the subset
%       of critical scales selected by the MSTEPS procedure.
%       If PARAM is larger than 1, it is assumed to be an integer, which is
%       used directly to set the number of scales in MSTEPS.
%
%   NB_SAMPS_FDR 
%       (integer, default 1000) the number of bootstrap samples used to derive 
%       the FDR tests.
%
%   FLAG_ROI
%       (boolean, default false) if the flag is true, the pipeline is only 
%       going to perform the region growing.
%
%   FLAG_IND
%       (boolean, default true) if the flag is true, build the individual stable
%       clusters, stable cores, adjusted clusters as well as associated stability
%       maps.
%
%   FLAG_GROUP
%       (boolean, default true) if the flag is true, perform the group level
%       analysis. This includes the analysis of stability, the generation of
%       group stable clusters, stable cores, adjusted clusters as well as
%       associated stability maps.
%
%   FLAG_MIXED
%       (boolean, default true) if the flag is true, generate the mixed stability maps,
%       which are based on the stable cores of the group-level clusters when evaluated for
%       the individual stability matrices. The adjusted clusters are generated as well.
%
%   FLAG_FIR
%       (boolean, default true if the extension of the FILES_IN.DATA.SUBJECT{1} 
%       is .mat for the first SUBJECT, false otherwise) If the flag is true, 
%       FILES_IN.DATA is assumed to directly contain FIR estimates in .mat files, 
%       rather than fMRI datasets. Note that this option can only be used if the
%       FILES_IN.ATOMS associated with the FIR are specified.
%
%   FIR
%       (structure) see the OPT argument of NIAK_BRICK_FIR. The default
%       parameters may work. This option is also used in
%       NIAK_BRICK_FIR_TSERIES.
%
%   REGION_GROWING
%       (structure) see the OPT argument of NIAK_PIPELINE_REGION_GROWING. 
%       The default parameters may work.
%
%   STABILITY_FIR
%       (structure, with 2 entries) see NIAK_BRICK_STABILITY_FIR. The 
%       default parameters may work.
%
%   STABILITY_GROUP
%       (structure, with 2 entries) see NIAK_BRICK_STABILITY_GROUP. The
%       default parameters may work.
%
%   STABILITY_MAPS
%       (structure) the options that will be passed to
%       NIAK_BRICK_STABILITY_MAPS
% 
%   STABILITY_FIGURE
%       (structure) the options that will be passed to
%       NIAK_BRICK_STABILITY_FIGURE
%
%   RAND_SEED
%       (scalar, default 0) The specified value is used to seed the random
%       number generator with PSOM_SET_RAND_SEED for each job. If left empty,
%       the generator is initialized based on the clock (the results will be
%       slightly different due to random variations in bootstrap sampling if
%       the pipeline is executed twice).
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
% NOTE 1:
% The steps of the pipeline are the following :
%  
%   1. Masking the brain in functional data
%   2. Extracting the time series and estimated FIR in each area 
%   3. Performing region growing in each area independently based on FIR
%      estimates.
%   4. Merging all regions of all areas into one mask of regions, along
%   with the corresponding time series for each functional run.
%   5. Individual-level stability analysis of FIR estimates.
%      See NIAK_PIPELINE_STABILITY_MULTI
%   6. Group-level stability analysis
%      See NIAK_PIPELINE_STABILITY_MULTI
%
% NOTE 2:
% This pipeline assumes fully preprocessed fMRI data in stereotaxic space
% as inputs. See NIAK_PIPELINE_FMRI_PREPROCESS.
%
% _________________________________________________________________________
% Copyright (c) Pierre Bellec, 
%               Centre de recherche de l'institut de Gériatrie de Montréal
%               Département d'informatique et de recherche opérationnelle
%               Université de Montréal, 2010-2011
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : pipeline, FIR, fMRI, clustering, stability

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
    error('niak:pipeline','syntax: PIPELINE = NIAK_PIPELINE_STABILITY_FIR(FILES_IN,OPT).\n Type ''help niak_pipeline_stability_fir'' for more info.')
end

%% Checking that FILES_IN is in the correct format
list_fields   = {'atoms'           , 'data' , 'mask'            , 'areas'           , 'infos'           };
list_defaults = {'gb_niak_omitted' , NaN    , 'gb_niak_omitted' , 'gb_niak_omitted' , 'gb_niak_omitted' };
files_in      = psom_struct_defaults(files_in,list_fields,list_defaults);

file_atoms = files_in.atoms;
infos      = files_in.infos;
mask       = files_in.mask;
areas      = files_in.areas;
files_in   = files_in.data;

list_subject = fieldnames(files_in);
nb_subject   = length(list_subject);

for num_s = 1:nb_subject    
    if ~iscellstr(files_in.(list_subject{num_s}).fmri)
        error('FILES_IN.%s is not a cell of strings!',upper(subject));
    end
end
[path_f,name_f,ext_f] = niak_fileparts(files_in.(list_subject{num_s}).fmri{1});

%% Options
list_fields   = {'nb_samps_fdr' , 'folder_out' , 'grid_scales' , 'scales_maps' , 'neigh'       , 'param' , 'flag_mixed' , 'flag_group' , 'flag_ind' , 'flag_fir' , 'flag_roi' , 'fir'    , 'region_growing' , 'stability_fir' , 'stability_group' , 'stability_maps' , 'stability_figure' , 'rand_seed' , 'psom'   , 'flag_test' , 'flag_verbose' };
list_defaults = {1000           , NaN          , []            , []            , [0.7 0.1 1.3] , 0.05    , true         , true         , true       , []         , false      , struct() , struct()         , struct()        , struct()          , struct()         , struct()           , 0           , struct() , false       , true           };
opt = psom_struct_defaults(opt,list_fields,list_defaults);
if ~strcmp(opt.folder_out(end),filesep)
    opt.folder_out = [opt.folder_out filesep];
end
opt.psom.path_logs = [opt.folder_out 'logs' filesep];
if isempty(opt.flag_fir)
    opt.flag_fir = strcmp(ext_f,'.mat');
end

list_fields    = {'type_norm' , 'time_norm' , 'time_sampling' };
list_defaults  = {'fir_shape' , 1           , 0.5             };
opt.fir = psom_struct_defaults(opt.fir,list_fields,list_defaults,false);

opt.stability_fir.normalize.type = opt.fir.type_norm;
opt.stability_fir.normalize.time_norm = opt.fir.time_norm;


%% converts the list of fmri runs into a cell
cell_fmri = cell([nb_subject 1]);
subj_fmri = cell([nb_subject 1]);
run_fmri  = cell([nb_subject 1]);

for num_s = nb_subject:-1:1
    name_subject = list_subject{num_s};
    cell_fmri{num_s} = files_in.(name_subject).fmri(:)';
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

if strcmp(file_atoms,'gb_niak_omitted')
    %% Initial FIR estimation for building ROI
    pipeline = struct();
    [path_f,name_f,ext_f] = niak_fileparts(cell_fmri{1});
    cell_fir = cell([nb_subject 1]);
    for num_s = 1:nb_subject
        subject = list_subject{num_s};
        clear job_in job_out job_opt
        job_in.fmri    = files_in.(subject).fmri;
        job_in.mask    = mask;
        job_in.timing  = files_in.(subject).timing;
        job_out        = [opt.folder_out 'rois' filesep 'fir_' subject ext_f];
        cell_fir{num_s}      = job_out;
        job_opt              = opt.fir;
        job_opt.flag_test    = true;
        pipeline = psom_add_job(pipeline,['fir_subject_' subject],'niak_brick_fir',job_in,job_out,job_opt);
    end
    
    %% Region growing
    clear job_in job_out job_opt
    job_in.fmri           = cell_fir;
    job_in.areas          = areas;
    job_in.mask           = mask;
    job_opt                     = opt.region_growing;
    job_opt.correction_ind.type = 'none';
    job_opt.folder_out          = opt.folder_out;
    job_opt.flag_test           = 1;
    job_opt.flag_tseries        = false;
    job_opt.labels              = labels_file;
    pipeline = psom_merge_pipeline(pipeline,niak_pipeline_region_growing(job_in,job_opt));
    file_atoms = pipeline.merge_part.files_out.space;
else
    [path_f,name_f,ext_f] = niak_fileparts(file_atoms);
    pipeline.brain_atoms.command   = 'system([''cp '' files_in '' '' files_out]);';
    pipeline.brain_atoms.files_in  = file_atoms;
    pipeline.brain_atoms.files_out = [opt.folder_out 'atoms' filesep 'brain_atoms' ext_f];
end

%% Response estimate at the ROI level
files_tseries = cell([nb_subject 1]);
if ~opt.flag_fir        
    for num_s = 1:nb_subject
        subject = list_subject{num_s};
        clear job_in job_out job_opt
        job_in.fmri    = files_in.(subject).fmri;
        job_in.mask    = file_atoms;
        job_in.timing  = files_in.(subject).timing;
        job_out        = [opt.folder_out 'rois' filesep 'fir_tseries_' subject '_roi.mat'];
        job_opt        = opt.fir;
        files_tseries{num_s}  = job_out;
        pipeline = psom_add_job(pipeline,['roi_tseries_subject_' subject],'niak_brick_fir_tseries',job_in,job_out,job_opt);
    end    
else
    for num_s = 1:nb_subject
        files_tseries{num_s} = files_in.(list_subject{num_s}).fmri{1};
    end
end

%% Run the stability analysis 
if ~opt.flag_roi
    clear job_in job_out job_opt
    for num_s = 1:nb_subject
        job_in.data.(list_subject{num_s}) = files_tseries{num_s};
    end
    job_in.atoms               = file_atoms;
    job_in.infos               = infos;
    job_opt.folder_out               = opt.folder_out;
    job_opt.grid_scales              = opt.grid_scales;
    job_opt.scales_maps              = opt.scales_maps;
    job_opt.flag_ind                 = opt.flag_ind;
    job_opt.flag_group               = opt.flag_group;
    job_opt.flag_mixed               = opt.flag_mixed;
    job_opt.name_brick_stability_ind = 'niak_brick_stability_fir';
    job_opt.neigh                    = opt.neigh;
    job_opt.param                    = opt.param;
    job_opt.stability_ind            = opt.stability_fir;
    job_opt.stability_group          = opt.stability_group;
    job_opt.stability_maps           = opt.stability_maps;
    job_opt.stability_figure         = opt.stability_figure;
    job_opt.rand_seed                = opt.rand_seed;
    job_opt.flag_test                = true;
    job_opt.flag_verbose             = opt.flag_verbose;
    pipeline = psom_merge_pipeline(pipeline,niak_pipeline_stability_multi(job_in,job_opt));
end

%% Build individual FIR based on individual clusters along with FDR tests
nb_scales = size(opt.scales_maps,1);
if opt.flag_ind&&~opt.flag_roi
    for num_s = 1:nb_subject
        clear job_in job_out job_opt
        job_in.fir_all = files_tseries{num_s};
        job_in.atoms = file_atoms;
        job_opt.nb_samps = opt.nb_samps_fdr;
        job_opt.normalize = opt.stability_fir.normalize;
        job_opt.rand_seed = opt.rand_seed;
        for num_sc = 1:nb_scales
            job_in.partition = pipeline.(['stability_maps_ind_' list_subject{num_s}]).files_out.partition_core{num_sc};
            label_scale = ['sci' num2str(opt.scales_maps(num_sc,1)) '_scf' num2str(opt.scales_maps(num_sc,end))];
            job_out.fdr = [opt.folder_out 'stability_ind' filesep list_subject{num_s} filesep label_scale filesep 'fdr_ind_' list_subject{num_s} '_' label_scale '.mat'];
            pipeline = psom_add_job(pipeline,['fdr_ind_' list_subject{num_s} '_' label_scale],'niak_brick_fdr_fir',job_in,job_out,job_opt,false);
        end
    end
end

%% Build individual FIR based on group clusters
if opt.flag_group&&~opt.flag_roi
    for num_s = 1:nb_subject
        clear job_in job_out job_opt
        job_in.fir_all = files_tseries{num_s};
        job_in.atoms = file_atoms;
        job_opt.nb_samps = opt.nb_samps_fdr;
        job_opt.normalize = opt.stability_fir.normalize;
        job_opt.rand_seed = opt.rand_seed;
        for num_sc = 1:nb_scales
            label_scale = ['sci' num2str(opt.scales_maps(num_sc,1)) '_scg' num2str(opt.scales_maps(num_sc,2)) '_scf' num2str(opt.scales_maps(num_sc,end))];
            job_in.partition = pipeline.(['stability_maps_group_' label_scale]).files_out.partition_core{1};
            job_out.fdr = [opt.folder_out 'stability_group' filesep list_subject{num_s} filesep label_scale filesep 'fdr_group_' list_subject{num_s} '_' label_scale '.mat'];
            pipeline = psom_add_job(pipeline,['fdr_group_' list_subject{num_s} '_' label_scale],'niak_brick_fdr_fir',job_in,job_out,job_opt,false);
        end
    end

    clear job_in job_out job_opt
    job_in.fir_all = files_tseries;
    job_in.atoms = file_atoms;
    job_opt.nb_samps = opt.nb_samps_fdr;
    job_opt.normalize = opt.stability_fir.normalize;
    job_opt.rand_seed = opt.rand_seed;
    for num_sc = 1:nb_scales
        label_scale = ['sci' num2str(opt.scales_maps(num_sc,1)) '_scg' num2str(opt.scales_maps(num_sc,2)) '_scf' num2str(opt.scales_maps(num_sc,end))];
        job_in.partition = pipeline.(['stability_maps_group_' label_scale]).files_out.partition_core{1};
        job_out.fdr = [opt.folder_out 'stability_group' filesep label_scale filesep 'fdr_group_average_' label_scale '.mat'];
        pipeline = psom_add_job(pipeline,['fdr_group_average_' label_scale],'niak_brick_fdr_fir',job_in,job_out,job_opt,false);
    end
end

%% Build individual FIR based on mixed clusters
if opt.flag_mixed&&~opt.flag_roi
    for num_s = 1:nb_subject
        clear job_in job_out job_opt
        job_in.fir_all = files_tseries{num_s};
        job_in.atoms = file_atoms;
        job_opt.nb_samps = opt.nb_samps_fdr;
        job_opt.normalize = opt.stability_fir.normalize;
        job_opt.rand_seed = opt.rand_seed;
        for num_sc = 1:nb_scales
            job_in.partition = pipeline.(['stability_maps_mixed_' list_subject{num_s}]).files_out.partition_core{num_sc};
            label_scale = ['sci' num2str(opt.scales_maps(num_sc,1)) '_scf' num2str(opt.scales_maps(num_sc,end))];
            job_out.fdr = [opt.folder_out 'stability_mixed' filesep list_subject{num_s} filesep label_scale filesep 'fdr_mixed_' list_subject{num_s} '_' label_scale '.mat'];
            pipeline = psom_add_job(pipeline,['fdr_mixed_' list_subject{num_s} '_' label_scale],'niak_brick_fdr_fir',job_in,job_out,job_opt,false);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%
%% Run the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%
if ~opt.flag_test
    psom_run_pipeline(pipeline,opt.psom);
end
