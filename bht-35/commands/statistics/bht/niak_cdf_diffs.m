function cdfs = niak_cdf_diffs(data,opt)

% Generate bootstrap estimates of the cumulative distribution function of 
% the difference in connectivity measures between two fMRI datasets.
% Some constraints can be added to the data-generating process in order to 
% conform to the null hypothesis of identical distributions of stochastic 
% processes in both datasets.
%
% This function is called by NIAK_TEST_DIFFS and is not meant to be used
% independently.
%
% Copyright (c) Pierre Bellec, McConnell Brain Imaging Center,Montreal 
%               Neurological Institute, McGill University, 2008.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : bootstrap, time series, hypothesis testing, functional
% connectivity

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

% SYNTAX:
% CDFS = NIAK_CDF_DIFFS(DATA,OPT)
%
% INPUTS:
% The inputs of NIAK_TEST_DIFFS will work here with slight differences:
%
% 1. all the differences listed in OPT.LIST_TEST will be considered
% here. The tags associated to each test are ignored. 
%
% 2. See the help of NIAK_SAMPLE_DIFFS for specification of OPT.BOOTSTRAP.
%
% 3. A field CDF should be present in OPT. This field is a structure with
% three fields : BINS, INTERPOLATION, LOW and UP. See help of NIAK_BUILD_CDF.
%
% OUPUTS:
% CDFS      (3D array) CDFS(:,m,d) is the (bootstrap) cumulative
%               distibution function of the mth element of the difference 
%               in the (vectorized) connectivity measure OPT.MEASURE 
%               between DATA entries corresponding to
%               OPT.LIST_TEST(d).DATASET(2) - OPT.LIST_TEST(d).DATASET(1)

%%% Connectivity measure options
gb_name_structure = 'opt';
gb_list_fields = {'measure','list_test','bootstrap','tag_fdr','flag_verbose','cdf'};
gb_list_defaults = {NaN,NaN,NaN,'',NaN,NaN};
niak_set_defaults

%%% Bootstrap options
gb_name_structure = 'opt.bootstrap';
gb_list_fields = {'dgp','null','nb_samps','nb_iterations','nb_samps_iter','ww','flag_global'};
gb_list_defaults = {NaN,NaN,NaN,NaN,NaN,NaN,NaN};
niak_set_defaults

%% Initalizing sample array
nb_data = prod(size(data));
nb_test = length(list_test);

T = zeros([nb_data 1]); 
M = zeros([nb_data 1]);

opt_m.measure = measure;
opt_m.flag_test = 1;
opt_m.flag_vec = 1;

for num_e = 1:nb_data
    T(num_e) = size(data(num_e).tseries,1);
    M(num_e) = length(niak_build_measure(data(num_e),opt_m));
end

opt_m.flag_test = 0;

samps = niak_sample_diffs(data,opt)
