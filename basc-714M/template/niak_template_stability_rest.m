% This is a template to run BASC on resting-state fMRI.
%
% The file names used here do not correspond to actual files and were used 
% for illustration purposes only. To actually run a demo of the 
% preprocessing data, please see NIAK_DEMO_PIPELINE_STABILITY_REST
%
% Copyright (c) Pierre Bellec, Montreal Neurological Institute, 2008-2010.
%               Centre de recherche de l'institut de Gériatrie de Montréal
%               Département d'informatique et de recherche opérationnelle
%               Université de Montréal, 2010-2011.
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : fMRI, resting-state, clustering, BASC

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setting input/output files %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Subject 1
files_in.data.subject1{1} = '/data/func_motor_subject1_a_mc_f_p_res_s.nii.gz';  % fMRI run 1 (motor)
files_in.data.subject1{2} = '/data/func_rest_subject1_a_mc_f_p_res_s.nii.gz';   % fMRI run 2 (resting-state)

%% Subject 2
files_in.data.subject2{1} = '/data/func_motor_subject2_a_mc_f_p_res_s.nii.gz';  % fMRI run 1 (motor)
files_in.data.subject2{2} = '/data/func_rest_subject2_a_mc_f_p_res_s.nii.gz';   % fMRI run 2 (resting-state)

%% Extra infos 
files_in.infos = '/data/infos.csv'; % A file of comma-separeted values describing additional information on the subjects

%% Functional mask
files_in.mask = '/data/func_mask_group_stereonl.nii.gz'; % That's a mask for the analysis. It can be a mask of the brain common to all subjects, or a mask of a specific brain area, e.g. the thalami.

%% Functional areas
files_in.areas = '/data/roi_aal.nii.gz'; % That's a mask a brain areas that is used to save memory space in the region-growing algorithm. Different brain areas are treated independently at this step of the analysis. If the mask is small enough, this may not be necessary. In this case, use the same file as MASK here.

%%%%%%%%%%%%%
%% Options %%
%%%%%%%%%%%%%

opt.folder_out = '/data/basc/'; % Where to store the results
opt.grid_scales = [5 7 9 11 13 15 17 20 23 26 30]; % Search in the range 5-30 clusters
opt.scales_maps = [2 2 2 ; 5 5 5 ; 10 10 10]; % The scales that will be used to generate the maps of brain clusters and stability
opt.region_growing.thre_size = 1000; % The atoms are about 1000 mm3
opt.nb_samps_ind = [30 100]; % Go fast in the first pass and be accurate in the second pass. 
opt.stability_tseries.nb_samps = 100; % Number of bootstrap samples at the individual level
opt.stability_group.nb_samps = 100; % Number of bootstrap samples at the group level 

%%%%%%%%%%%
%% PSOM  %%
%%%%%%%%%%%
opt.psom.mode = 'batch'; % Run the jobs in batch mode
opt.psom.max_queued = 2; % Use up to two computing threads simultaneously
opt.psom.mode_pipeline_manager = 'session'; % Run the pipeline from the current session;

%%%%%%%%%%%%%%%%%%%%%%
%% Run the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%

pipeline = niak_pipeline_stability_rest(files_in,opt); 