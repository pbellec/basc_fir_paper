%
% _________________________________________________________________________
% SUMMARY NIAK_DEMO_DATA_1SCALE
%
% This is a script to demonstrate how to build spatial data with stable
% spatial clusters present at one spatial scale. 
%
% SYNTAX:
% Just type in NIAK_DEMO_DATA_1SCALE
%
% _________________________________________________________________________
% OUTPUT
%
% The script will generate a set of time series with 4 networks. The 
% network structure is imposed by adding a single time course to every 
% regions in the network.
%
% _________________________________________________________________________
% COMMENTS
%
% NOTE 1
% This script will clear the workspace !!
%
% _________________________________________________________________________
% Copyright (c) Pierre Bellec, Montreal Neurological Institute, 2008.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : 

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
rand('state',sum(100*clock))
randn('state',sum(100*clock))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Simulating a dataset using a linear mixture model %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Partition of regions into networks

%% 2 scales with a hierarchical organization
mpart{1} = repmat(1:4,[25 1]);
mpart{1} = mpart{1}(:);

%% Time parameters
opt.time.t = 100;
opt.time.tr = 3;
opt.time.rho = 0.8;

%% Space parameters
opt.space.mpart = mpart;
opt.space.variance{1} = 0.3;

%% Noise parameters
opt.noise.variance = 1;

tseries = niak_sample_mplm(opt);

