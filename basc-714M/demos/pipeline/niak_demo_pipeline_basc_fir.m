function [pipeline,opt] = niak_demo_pipeline_basc_fir(path_demo,opt)
%
% _________________________________________________________________________
% SUMMARY NIAK_DEMO_PIPELINE_BASC_FIR
%
% This is a script to demonstrate the usage of :
% NIAK_PIPELINE_BASC_FIR
%
% SYNTAX:
% [PIPELINE,OPT] = NIAK_DEMO_PIPELINE_BASC_GROUP(PATH_DEMO,FLAG_TEST)
%
% _________________________________________________________________________
% INPUTS:
%
% PATH_DEMO
%       (string, default GB_NIAK_PATH_DEMO in the file NIAK_GB_VARS) 
%       the full path to the NIAK demo dataset in Talairach space. 
%       The dataset can be found in multiple file formats at the following 
%       address : 
%       http://www.bic.mni.mcgill.ca/users/pbellec/demo_niak_tal/
%
% OPT
%       (structure, optional) with the following fields : 
%
%       FLAG_TEST
%           (boolean, default false) if FLAG_TEST == true, the demo will 
%           just generate the PIPELINE and OPT structure, otherwise it will 
%           process the pipeline.
%
%       PSOM
%           (structure) the options of the pipeline manager. See the OPT
%           argument of PSOM_RUN_PIPELINE. Default values can be used here.
%           Note that the field PSOM.PATH_LOGS will be set up by the
%           pipeline.
%
% _________________________________________________________________________
% OUTPUT
%
% It will apply a boostrap analysis of stable clusters to two subjects,
% each one with a small resting-state and motor fMRI runs.
%
% _________________________________________________________________________
% COMMENTS
%
% NOTE 1
% This script will clear the workspace !!
%
% NOTE 2
% The demo database exists in multiple file formats. NIAK looks into the demo 
% path and is supposed to figure out which format you are intending to use 
% by himself. 
%
% _________________________________________________________________________
% Copyright (c) Pierre Bellec, Montreal Neurological Institute, 2008.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : medical imaging, slice timing, fMRI

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

niak_gb_vars

if ~exist('path_demo','var')
    path_demo = '';
end

if isempty(path_demo)
    path_demo = gb_niak_path_demo;
end

if ~strcmp(path_demo(end),filesep)
    path_demo = [path_demo filesep];
end

%% Set up defaults
gb_name_structure = 'opt';
default_psom.path_logs = '';
gb_list_fields = {'flag_test','psom'};
gb_list_defaults = {false,default_psom};
niak_set_defaults

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setting input/output files %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% In which format is the niak demo ?
format_demo = 'minc2';
if exist(cat(2,path_demo,'func_mask_group_stereonl.mnc'))
    format_demo = 'minc2';
elseif exist(cat(2,path_demo,'func_mask_group_stereonl.mnc.gz'))
    format_demo = 'minc1';
elseif exist(cat(2,path_demo,'func_mask_group_stereonl.nii.gz'))
    format_demo = 'nii';
end

switch format_demo
    
    case 'minc1' % If data are in minc1 format
        
        %% Subject 1

        % Extra infos : gender
        files_in.data.subject1.extra.gender = 'M'; % male

        % fMRI runs
        files_in.data.subject1.fmri{1} = cat(2,path_demo,filesep,'func_motor_subject1_a_mc_f_p_res_s.mnc.gz');
        files_in.data.subject1.fmri{2} = cat(2,path_demo,filesep,'func_rest_subject1_a_mc_f_p_res_s.mnc.gz');

        %% Subject 2

        % Extra infos : gender
        files_in.data.subject2.extra.gender = 'M'; % male

        % fMRI runs
        files_in.data.subject2.fmri{1} = cat(2,path_demo,filesep,'func_motor_subject2_a_mc_f_p_res_s.mnc.gz');
        files_in.data.subject2.fmri{2} = cat(2,path_demo,filesep,'func_rest_subject2_a_mc_f_p_res_s.mnc.gz');

        %% Functional mask
        files_in.mask = cat(2,path_demo,filesep,'func_mask_group_stereonl.mnc.gz');
        
    case 'minc2' % If data are in minc1 format
        
        %% Subject 1

        % Extra infos : gender
        files_in.data.subject1.extra.gender = 'M'; % male

        % fMRI runs
        files_in.data.subject1.fmri{1} = cat(2,path_demo,filesep,'func_motor_subject1_a_mc_f_p_res_s.mnc');
        files_in.data.subject1.fmri{2} = cat(2,path_demo,filesep,'func_rest_subject1_a_mc_f_p_res_s.mnc');

        %% Subject 2

        % Extra infos : gender
        files_in.data.subject2.extra.gender = 'M'; % male

        % fMRI runs
        files_in.data.subject2.fmri{1} = cat(2,path_demo,filesep,'func_motor_subject2_a_mc_f_p_res_s.mnc');
        files_in.data.subject2.fmri{2} = cat(2,path_demo,filesep,'func_rest_subject2_a_mc_f_p_res_s.mnc');

        %% Functional mask
        files_in.mask = cat(2,path_demo,filesep,'func_mask_group_stereonl.mnc');
        
    case 'nii' % If data are in nifti format
        
        %% Subject 1

        % Extra infos : gender
        files_in.data.subject1.extra.gender = 'M'; % male

        % fMRI runs
        files_in.data.subject1.fmri{1} = cat(2,path_demo,filesep,'func_motor_subject1_a_mc_f_p_res_s.nii.gz');
        files_in.data.subject1.fmri{2} = cat(2,path_demo,filesep,'func_rest_subject1_a_mc_f_p_res_s.nii.gz');

        %% Subject 2

        % Extra infos : gender
        files_in.data.subject2.extra.gender = 'M'; % male

        % fMRI runs
        files_in.data.subject2.fmri{1} = cat(2,path_demo,filesep,'func_motor_subject2_a_mc_f_p_res_s.nii.gz');
        files_in.data.subject2.fmri{2} = cat(2,path_demo,filesep,'func_rest_subject2_a_mc_f_p_res_s.nii.gz');
        
        %% Functional mask
        files_in.mask = cat(2,path_demo,filesep,'func_mask_group_stereonl.nii.gz');
        
        %% Functional areas
        files_in.areas = cat(2,path_demo,filesep,'roi_aal.nii.gz');
        
    otherwise 
        
        error('niak:demo','%s is an unsupported file format for this demo. See help to change that.',format_demo)
        
end

%%%%%%%%%%%%%%%%%%%%
%% Options : Misc %%
%%%%%%%%%%%%%%%%%%%%

opt.flag_test = false; 
opt.folder_out = [path_demo,filesep,'basc',filesep];

%%%%%%%%%%%%%%%%%%%%
%% Options : PSOM %%
%%%%%%%%%%%%%%%%%%%%

opt.psom.mode = 'session';
opt.psom.max_queued = 2;
opt.psom.mode_pipeline_manager = 'session';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Options : region growing %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opt.region_growing.thre_size = 800;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Options : individual stability %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Clustering options
clustering.type_clust = 'kmeans';
clustering.opt_clust.nb_iter = 5;
clustering.opt_clust.flag_verbose = 0;
clustering.opt_clust.type_init = 'random_point';
clustering.opt_clust.type_death = 'singleton';

list_nb_classes = [3 4 5 10];
for num_c = 1:length(list_nb_classes)
    opt.stability_ind.clustering(num_c) = clustering;
    opt.stability_ind.clustering(num_c).opt_clust.nb_classes = list_nb_classes(num_c);
end

%% Bootstrap options
opt.stability_ind.bootstrap.dgp = 'CBB';
opt.stability_ind.bootstrap.block_length = 10;
opt.stability_ind.bootstrap.independence = false;

%% Sampling option
opt.stability_ind.nb_samps_stab = [100 100];
opt.stability_ind.nb_samps_cdf = 1000;

%% Normalization option
opt.stability_ind.correction_ind.type = 'mean_var';
opt.stability_ind.correction_group.type = 'mean_var';

%%%%%%%%%%%%%%%%%%%%%
%% Group stability %%
%%%%%%%%%%%%%%%%%%%%%

%% Options : bootstrap

opt.stability_group.bootstrap.type = 'SB';
opt.stability_group.bootstrap.opt.strata = {'gender'};

%% Options : cdf
opt.stability_group.cdf.nb_samps = 10000;
opt.stability_group.cdf.flag_pooled = true;
opt.stability_group.cdf.flag_log = true;
opt.stability_group.cdf.type = 'interp';
opt.stability_group.cdf.limits = [0 ; 1];
opt.stability_group.cdf.nb_bins = 300;
opt.stability_group.cdf.valx = [0 1];
opt.stability_group.cdf.valy = [10^(-10) 1-10^(-10)];

%% Options : fdr

opt.stability_group.fdr.nb_samps = 500;
opt.stability_group.fdr.bins = Inf;

%%%%%%%%%%%%%%%%%%%%%%%%
%% Threshold pipeline %%
%%%%%%%%%%%%%%%%%%%%%%%%
opt.threshold_stability.avg_sim = 0.5;

%%%%%%%%%%%%%%%%%%%%%%
%% run the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%

[pipeline,opt] = niak_pipeline_basc_fir(files_in,opt);