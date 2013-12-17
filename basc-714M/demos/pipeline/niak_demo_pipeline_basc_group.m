function [pipeline,opt] = niak_demo_pipeline_basc_group(path_demo,opt)
%
% _________________________________________________________________________
% SUMMARY NIAK_DEMO_PIPELINE_BASC_GROUP
%
% This is a script to demonstrate the usage of :
% NIAK_PIPELINE_BASC_GROUP
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
% OUTPUT:
%
% PIPELINE
%       (structure) the pipeline structure.
%
% OPT
%       (structure) the updated OPT structure.
%
% _________________________________________________________________________
% COMMENTS
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
% Keywords : medical imaging, demo, clustering, stability, BASC, fMRI

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

%%%%%%%%%%%%%
%% Options %%
%%%%%%%%%%%%%

opt.size_rois = 2000; % A very small number of regions to speed up the process

opt.block_length = [2:5]; % The time series are only 48 volumes long

opt.nb_samps_ind = 30; % Use the same number of individual bootstrap samples in first and second pass

opt.nb_samps_group = 100; % Use the same number of individual bootstrap samples in first and second pass

opt.list_scales_pass1 = [2 5 10 14]; % The search grid on the number of clusters

opt.list_scales_pass2 = [2 2 2; 9 9 8]; % The final clustering parameters (individual, group and final)

opt.folder_out = [path_demo 'basc_group' filesep];

%%%%%%%%%%%%%%%%%%%%%%
%% run the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%

[pipeline,opt] = niak_pipeline_basc_group(files_in,opt);