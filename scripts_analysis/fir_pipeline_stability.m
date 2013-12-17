% Run a STABILITY-FIR analysis with different levels of added structured
% noise.
%
% SYNTAX:
% Just type in FIR_PIPELINE_STABILITY_STD_NOISE
%
% _________________________________________________________________________
% OUTPUT
%
% _________________________________________________________________________
% COMMENTS
%
% NOTE 1
% This script will clear the workspace !!
%
% _________________________________________________________________________
% Copyright (c) Pierre Bellec, Montreal Neurological Institute, 2008-2010.
%               Centre de recherche de l'institut de Gériatrie de Montréal
%               Département d'informatique et de recherche opérationnelle
%               Université de Montréal, 2010-2011.
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : BASC, FIR, ROIs

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

clear

%% Setting input/output files 
path_data = '/home/pbellec/database/BASC_FIR/';
files_in = niak_grab_fir([path_data 'fir_rois' filesep 'rois' filesep]);

%% Options
opt.grid_scales = [2:50 60:10:300]; % Search in the range 2-300 clusters
opt.scales_maps = [2 2 2; 5 5 5; 10 10 10; 25 25 25; 50 50 50; 100 100 100; 200 200 200]; % The scales that will be used to generate the maps of brain clusters and stability
opt.stability_fir.nb_samps_bias = 100; % Number of bootstrap samples at the individual level
opt.stability_fir.nb_samps = 1000;      % Number of bootstrap samples at the individual level
opt.stability_group.nb_samps = 1000;    % Number of bootstrap samples at the group level 

%% FIR estimation options
opt.fir.type_norm     = 'fir_shape';
opt.fir.time_norm     = 1;
opt.fir.time_window   = 20;
opt.fir.time_sampling = 1;

%% FDR estimation
opt.nb_samps_fdr = 10000; 

%% Run the pipeline
opt.flag_ind = false;   % Do not generate individual stability maps & FIR estimates
opt.flag_mixed = false; % Do not generate mixed level stability maps & FIR estimates
opt.flag_test = true;
pipeline = struct();
list_std_noise = [0 2 4];
for num_std = 1:length(list_std_noise)
    opt.stability_fir.std_noise = list_std_noise(num_std);
    opt.folder_out = [path_data 'stability_fir' filesep 'std_' num2str(list_std_noise(num_std)) filesep]; % Where to store the results
    [pipeline_std,opt] = niak_pipeline_stability_fir(files_in,opt);
    pipeline = psom_merge_pipeline(pipeline,pipeline_std,['std_' num2str(list_std_noise(num_std)) '_']);
end 
opt.psom.path_logs = [path_data 'stability_fir' filesep 'logs' filesep];
