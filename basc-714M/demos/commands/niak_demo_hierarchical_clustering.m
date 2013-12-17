%
% _________________________________________________________________________
% SUMMARY NIAK_DEMO_HIERARCHICAL_CLUSTERING
%
% This is a script to demonstrate how to perform a hierarchical clustering
%
% SYNTAX:
% Just type in NIAK_DEMO_hierarchical clustering
%
% _________________________________________________________________________
% OUTPUT
%
% The script will use NIAK_DEMO_DATA to generate an example dataset, and
% will perform a hierarchical clustering on the time series.
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

niak_demo_data
tseries = data(1).tseries;
clear data

%% Clustering options
opt_hier.type_distance = 'average';
opt_hier.other_distance = 'max';

%% Perform hierarchical clustering
R = niak_build_correlation(tseries);
D = sqrt(2-2*R)/2;
hier = niak_hierarchical_clustering(D,opt_hier);

%% Visualization
niak_visu_dendrogram(hier);

%% threshold partitions
opt_part.type = 'dist';
opt_part.thresh = 0.7;
opt_part.flag_other = true;
part = niak_threshold_hierarchy(hier,opt_part);