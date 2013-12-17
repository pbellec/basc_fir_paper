function [stab,tseries,opt] = niak_demo_stability(opt)
% This is a script to demonstrate the usage of NIAK_BUILD_STABILITY
%
% SYNTAX:
% [STAB,TSERIES,OPT] = NIAK_DEMO_STABILITY(OPT)
%
% _________________________________________________________________________
% INPUTS:
%
% PATH_DEMO
%       (string) The path where the demo will run. Please be aware that 
%       some files and folders will be created in that path.
%
% OPT
%       (structure, optional) with the following fields : 
%
%       FLAG_VERBOSE
%           (boolean, default true) if FLAG_VERBOSE == true, the demo will 
%           display advancement infos.
%
% _________________________________________________________________________
% OUTPUTS:
%
% STAB
%   (vector) the vectorized bootstrap estimation of the stability matrix. 
%
% TSERIES
%   (2D time*space array) the simulated time series.
%
% OPT
%   (structure) the options of NIAK_BUILD_STABILITY.
%
% _________________________________________________________________________
% COMMENTS:
%
% This demo will derive the bootstrap estimation of the stability matrix of
% simulated time series.
%
% _________________________________________________________________________
% Copyright (c) Pierre Bellec, Montreal Neurological Institute, 2008.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : clustering, stability, BASC, time series

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

%% Set up defaults
gb_name_structure = 'opt';
default_psom.path_logs = '';
gb_list_fields = {'flag_verbose'};
gb_list_defaults = {true};
niak_set_defaults

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate simulated data %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
k = 5;    % Number of networks
r = 10;   % Number of regions per network
snr = -5; % Signal-to-noise ratio

% Spatial partition
mpart{1} = repmat(1:k,[r 1]);
mpart{1} = mpart{1}(:);
opt_samp.space.mpart = mpart;

% Time parameters
opt_samp.time.t   = 200;
opt_samp.time.tr  = 3;
opt_samp.time.rho = 0.8;

% Variance parameters
opt_samp.space.variance{1} = 10^(snr/10);
opt_samp.noise.variance    = 1;

% Generate and save time series
tseries = niak_sample_mplm(opt_samp);

%%%%%%%%%%%%%
%% Options %%
%%%%%%%%%%%%%

% bootstrap
opt.sampling.command_samp = 'data_samp = niak_bootstrap_tseries(data,opt_samp);';
opt.sampling.opt_samp.dgp = 'CBB';
opt.sampling.opt_samp.block_length = [3 7];

% clustering
opt.clustering.command_clust = 'part = niak_kmeans_clustering(data_samp,opt_clust);';
opt.clustering.opt_clust.nb_classes = 5;

% Misc
opt.flag_vec = false;
opt.nb_samps_stab = 1000;

%%%%%%%%%%%%%%%%%%%%%%
%% run the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%

stab = niak_build_stability(tseries,opt);