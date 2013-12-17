%
% _________________________________________________________________________
% SUMMARY NIAK_DEMO_DATA
%
% This is a script to demonstrate how to build data structures to apply
% bootstrap resampling of stratified group time series, as in
% NIAK_BOOTSTRAP_DATA.
%
% SYNTAX:
% Just type in NIAK_DEMO_DATA. 
%
% _________________________________________________________________________
% OUTPUT
%
% The script will generate a linear model with two networks with perfect
% reproducibility between subjects for 4 subjects (2 male, 2 females, 2
% right-handed, two left-handed), each subject having two runs (motor and
% rest).
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

mpart{2} = repmat(1:20,[5 1]);
mpart{2} = mpart{2}(:);

% %% 3 scales with a hierarchical organization
% mpart{1} = repmat(1:4,[200 1]);
% mpart{1} = mpart{1}(:);
% 
% mpart{2} = repmat(1:20,[40 1]);
% mpart{2} = mpart{2}(:);
% 
% mpart{3} = repmat(1:80,[10 1]);
% mpart{3} = mpart{3}(:);

%% Time parameters
opt.time.t = 100;
opt.time.tr = 3;
opt.time.rho = 0.8;

%% Space parameters
opt.space.mpart = mpart;
opt.space.variance{1} = 0.3;
opt.space.variance{2} = 0.3;
opt.space.variance{3} = 0.3;

%% Noise parameters
opt.noise.variance = 1;

tseries = niak_sample_mplm(opt);

return

nb_scales = length(nb_cluster);
size_space = 800;
for num_k = 1:nb_scales
    size_cluster(num_k) = size_space/nb_cluster(num_k);
end

for num_k = 1:nb_scales
    part{num_k} = zeros([nb_cluster(end)*size_cluster 1],'int32');
    for num_c = 1:nb_cluster(num_k)
        part{num_k}((1+(num_c-1)*size_cluster(num_k)):(num_c*size_cluster(num_k))) = num_c;
    end
end

for num_s = 1:12
    
    %% Temporal sources with controled spatial covariance
    S = eye(nb_cluster);
    opt_source.nt = 200;
    X{num_s} = niak_cov2source(S,opt_source);

    %% Spatial sources : mutually exclusive networks
    B{num_s} = zeros([nb_cluster length(part)]);
    for num_c = 1:nb_cluster
        list_ind = find(part == num_c)';
        for num_i = list_ind
            B{num_s}(num_c,num_i) = rand(1)>0;
        end
    end

    %% Noise : Gaussian i.i.d. with controlled variance
    opt_lm(num_s).noise = 'independent_space_time';
    opt_lm(num_s).par = 2; % SNR = 0
end

%% Build the dataset
num_e = 1;

data(num_e).subject = 'subj1';
data(num_e).gender = 'M';
data(num_e).age = 22;
data(num_e).hand = 'L';
data(num_e).condition = 'motor';
data(num_e).run = 'run1';
data(num_e).tseries = niak_sample_linear_model(X{num_e},B{num_e},opt_lm(num_e));
data(num_e).part = part;
num_e = num_e + 1;

data(num_e).subject = 'subj1';
data(num_e).gender = 'M';
data(num_e).age = 22;
data(num_e).hand = 'L';
data(num_e).condition = 'rest';
data(num_e).run = 'run2';
data(num_e).tseries = niak_sample_linear_model(X{num_e},B{num_e},opt_lm(num_e));
data(num_e).part = part;
num_e = num_e + 1;

data(num_e).subject = 'subj2';
data(num_e).gender = 'M';
data(num_e).age = 35;
data(num_e).hand = 'R';
data(num_e).condition = 'motor';
data(num_e).run = 'run1';
data(num_e).tseries = niak_sample_linear_model(X{num_e},B{num_e},opt_lm(num_e));
data(num_e).part = part;
num_e = num_e + 1;

data(num_e).subject = 'subj2';
data(num_e).gender = 'M';
data(num_e).age = 35;
data(num_e).hand = 'R';
data(num_e).condition = 'rest';
data(num_e).run = 'run2';
data(num_e).tseries = niak_sample_linear_model(X{num_e},B{num_e},opt_lm(num_e));
data(num_e).part = part;
num_e = num_e + 1;

data(num_e).subject = 'subj3';
data(num_e).gender = 'F';
data(num_e).age = 29;
data(num_e).hand = 'R';
data(num_e).condition = 'motor';
data(num_e).run = 'run1';
data(num_e).tseries = niak_sample_linear_model(X{num_e},B{num_e},opt_lm(num_e));
data(num_e).part = part;
num_e = num_e + 1;

data(num_e).subject = 'subj3';
data(num_e).gender = 'F';
data(num_e).age = 29;
data(num_e).hand = 'R';
data(num_e).condition = 'rest';
data(num_e).run = 'run2';
data(num_e).tseries = niak_sample_linear_model(X{num_e},B{num_e},opt_lm(num_e));
data(num_e).part = part;
num_e = num_e + 1;

data(num_e).subject = 'subj4';
data(num_e).gender = 'F';
data(num_e).age = 25;
data(num_e).hand = 'L';
data(num_e).condition = 'motor';
data(num_e).run = 'run1';
data(num_e).tseries = niak_sample_linear_model(X{num_e},B{num_e},opt_lm(num_e));
data(num_e).part = part;
num_e = num_e + 1;

data(num_e).subject = 'subj4';
data(num_e).gender = 'F';
data(num_e).age = 25;
data(num_e).hand = 'L';
data(num_e).condition = 'rest';
data(num_e).run = 'run2';
data(num_e).tseries = niak_sample_linear_model(X{num_e},B{num_e},opt_lm(num_e));
data(num_e).part = part;
num_e = num_e + 1;

data(num_e).subject = 'subj5';
data(num_e).gender = 'F';
data(num_e).age = 41;
data(num_e).hand = 'L';
data(num_e).condition = 'motor';
data(num_e).run = 'run1';
data(num_e).tseries = niak_sample_linear_model(X{num_e},B{num_e},opt_lm(num_e));
data(num_e).part = part;
num_e = num_e + 1;

data(num_e).subject = 'subj5';
data(num_e).gender = 'F';
data(num_e).age = 41;
data(num_e).hand = 'L';
data(num_e).condition = 'rest';
data(num_e).run = 'run2';
data(num_e).tseries = niak_sample_linear_model(X{num_e},B{num_e},opt_lm(num_e));
data(num_e).part = part;
num_e = num_e + 1;

data(num_e).subject = 'subj6';
data(num_e).gender = 'M';
data(num_e).age = 19;
data(num_e).hand = 'L';
data(num_e).condition = 'motor';
data(num_e).run = 'run1';
data(num_e).tseries = niak_sample_linear_model(X{num_e},B{num_e},opt_lm(num_e));
data(num_e).part = part;
num_e = num_e + 1;

data(num_e).subject = 'subj6';
data(num_e).gender = 'M';
data(num_e).age = 19;
data(num_e).hand = 'L';
data(num_e).condition = 'rest';
data(num_e).run = 'run2';
data(num_e).tseries = niak_sample_linear_model(X{num_e},B{num_e},opt_lm(num_e));
data(num_e).part = part;
num_e = num_e + 1;