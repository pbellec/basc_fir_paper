%
% _________________________________________________________________________
% SUMMARY NIAK_DEMO_BRICK_STABILITY_GROUP
%
% This is a script to demonstrate how to test the significance of 
% (2-)stability coefficients at the population level against a null 
% hypothesis of no shared clusters between subjects using
% NIAK_BRICK_STABILITY_GROUP.
%
% SYNTAX:
% Just type in NIAK_DEMO_BRICK_STABILITY_GROUP
%
% _________________________________________________________________________
% OUTPUT
%
% The script will load stability matrices in the folder 
% FOLDER_BASC/data_demo/stability/ and will generate a BHT structure in the
% same folder.
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
niak_gb_basc


%% Building input file names
list_num_subject = 1:6;

for num_s = list_num_subject

    files_in{num_s} = [gb_basc_demo_path 'stability' filesep 'stability_subj' num2str(num_s) '.mat'];

end

%% Building output file names

files_out = [gb_basc_demo_path 'stability' filesep 'stability_test_group.mat'];

%% Options : data

for num_s = 1:6
    opt.data(num_s).gender = data(num_s*2).gender;
    opt.data(num_s).hand = data(num_s*2).hand;
end

%% Options : bootstrap

opt.bootstrap.type = 'SB';
opt.bootstrap.opt.strata = {'gender','hand'};

%% Options : cdf

opt.cdf.nb_samps = 10000;
opt.cdf.flag_pooled = true;
opt.cdf.flag_log = true;
opt.cdf.type = 'interp';
opt.cdf.limits = [0 ; 1];
opt.cdf.nb_bins = 300;
opt.cdf.valx = [0 1];
opt.cdf.valy = [10^(-10) 1-10^(-10)];

%% Options : fdr

opt.fdr.nb_samps = 500;
opt.fdr.bins = Inf;

%% Run the group level stability analysis

niak_brick_stability_group(files_in,files_out,opt);