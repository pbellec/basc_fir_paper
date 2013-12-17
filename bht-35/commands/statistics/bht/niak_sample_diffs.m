function samps = niak_sample_diffs(data,opt)

% Generate bootstrap samples of the connectivity measures between two fMRI datasets.
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
% SAMPS = NIAK_SAMPLE_DIFFS(DATA,OPT)
%
% INPUTS:
% The inputs of NIAK_TEST_DIFFS will work here with slight differences:
%
% 1. all the differences listed in OPT.LIST_TEST will be considered
% here. The tags associated to each test are ignored.
%
% OUPUTS:
% SAMPS      (3D array) SAMPS(b,m,d) is the bth (bootstrap) sample of the mth
%               element of the difference in the (vectorized) connectivity
%               measure OPT.MEASURE between DATA entries corresponding to
%               OPT.LIST_TEST(d).DATASET(2) - OPT.LIST_TEST(d).DATASET(1)

%%% Connectivity measure options
name_structure = 'opt';
list_fields = {'measure','list_test','bootstrap','tag_fdr','flag_verbose'};
list_defaults = {NaN,NaN,NaN,'',NaN};
niak_set_defaults

%%% Bootstrap options
name_structure = 'opt.bootstrap';
list_fields = {'dgp','null','nb_samps','nb_iterations','nb_samps_iter','ww'};
list_defaults = {NaN,NaN,NaN,NaN,NaN,NaN};
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

flag_M = min(M==M(1));

if flag_M == 0
    error('All measures should have the same dimension !')
else
    M = M(1);
end

switch opt.bootstrap.null
    case {'duplicate','duplicate_paired'}

        nb_samps0 = ceil(sqrt(nb_samps/nb_data));
        samps = zeros([nb_data nb_samps0^2 M nb_test]);
        [indx,indy] = find(ones([nb_samps0,nb_samps0]));

    case {'mixture','mixture_paired'}

        nb_samps0 = ceil(sqrt(nb_samps));
        samps = zeros([nb_samps0^2 M nb_test]);

end

opt_boot.dgp = opt.bootstrap.dgp;
opt_boot.nb_samps = nb_samps0;
opt_boot.ww = ww;


for num_t = 1:length(list_test) % Loop over all tests

    %% Extracting the datasets involved in the test
    ind{1} = find(niak_find_structs(data,list_test(num_t).tags_data(1)));
    nb_data(1) = length(ind{1});
    ind{2} = find(niak_find_structs(data,list_test(num_t).tags_data(2)));
    nb_data(2) = length(ind{2});

    if ~isempty(findstr(opt.bootstrap.null,'paired'))

        if nb_data(1)~=nb_data(2)
            error('Impossible to use paired tests in uneven populations.')
        end

    end

    %% The "duplicate" (both paired or not paired) scheme 

    if findstr(opt.bootstrap.null,'duplicate')

        for num_l = 1:nb_data % Each dataset will be used as seed

            samps_m = zeros([nb_samps0 2 M]);

            if max(nb_data)==1
                data_seed1 = data(ind{num_l});
                data_seed2 = data(ind{num_l});
            end

            for num_s = 1:nb_samps0 % Loop over all samples

                if max(nb_data)>1 % Multiple datasets are involved : this is a group test

                    switch null

                        case 'duplicate_paired'

                            num = floor(nb_data(num_l)*rand([nb_data(1) 1]))+1;
                            data_seed1 = data(ind{num_l}(num));
                            data_seed2 = data(ind{num_l}(num));

                        case 'duplicate'

                            num1 = floor(nb_data(num_l)*rand([nb_data(1) 1]))+1;
                            num2 = floor(nb_data(num_l)*rand([nb_data(2) 1]))+1;
                            data_seed1 = data(ind{num_l}(num1));
                            data_seed2 = data(ind{num_l}(num2));
                    end
                end

                for num_e = 1:length(data_seed1)
                    opt_boot.t_boot = size(data(ind{1}(num_e)).tseries,1);
                    data_boot1 = rmfield(data_seed1,'tseries');
                    data_boot1(num_e).tseries = niak_bootstrap_tseries(data_seed1(num_e).tseries,opt_boot);
                end

                for num_e = 1:length(data_seed2)
                    opt_boot.t_boot = size(data(ind{2}(num_e)).tseries,1);
                    data_boot2 = rmfield(data_seed1,'tseries');
                    data_boot2(num_e).tseries = niak_bootstrap_tseries(data_seed2(num_e).tseries,opt_boot);
                end

                samps_m(num_s,1,:) = niak_build_measure(data_boot1,opt_m);
                samps_m(num_s,2,:) = niak_build_measure(data_boot2,opt_m);

            end % loop over all samples

            samps(num_l,:,:,num_t) = squeeze(samps_m(indy,2,:) - samps_m(indx,1,:)); % We consider all possible differences between bootstrap samples of measure from data1* and from data2*

        end % Loop over all seeds
    end % if 'duplicate'
end % Loop over all tests


switch opt.bootstrap.null
    
    case {'duplicate','duplicate_paired'}

        samps = reshape(samps,[nb_data*nb_samps0^2 M nb_test]);

end
