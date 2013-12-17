%
% _________________________________________________________________________
% SUMMARY NIAK_DEMO_FDR
%
% This is a script to demonstrate how estimate an FDR threshold associated
% to a given PCE.
%
% SYNTAX:
% Just type in NIAK_DEMO_FDR
%
% _________________________________________________________________________
% OUTPUT
%
% The script will use NIAK_DEMO_DATA to generate an example dataset, and
% will generate an estimation of the cdf of the AFC measure, and use the
% cdf as pce (left-sided test) to infer the FDR as a function of the PCE
% threshold over a grid of PCE values.
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Simulating a dataset using a linear mixture model %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

niak_demo_data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setting up the bootstrap scheme %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Stratified bootstrap 
opt_boot(1).type = 'SB';
opt_boot(1).opt.strata = {'gender'};

%% circular block bootstrap
opt_boot(2).type = 'CBB'; %% Use of circular block bootstrap to resample the time series
opt_boot(2).opt.field = 'tseries';
opt_boot(2).opt.block_length = 10;
opt_boot(2).opt.independence = true;

%%%%%%%%%%%%%%%%%%%%%%%%
%% Measure estimation %%
%%%%%%%%%%%%%%%%%%%%%%%%

opt_mes.function_name = 'niak_build_measure';
opt_mes.opt_func.flag_vec = true;
opt_mes.opt_func.measure_ind.type = 'AFC';
opt_mes.opt_func.measure_ind.field_argin1 = 'tseries';
opt_mes.opt_func.measure_ind.field_argin2 = 'part';
opt_mes.opt_func.measure_group.type = 'average';
opt_mes.opt_func.measure_group.label = 'average AFC';
opt_mes.opt_func.measure_group.field_subset = {};
opt_mes.opt_func.measure_group.val_subset = {};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CDF estimation options %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

opt_cdf.type = 'interp';
opt_cdf.nb_samps = 1000;
opt_cdf.limits = [-1 ; 1];
opt_cdf.nb_bins = 100;
opt_cdf.valx = [-1 1];
opt_cdf.valy = [10^(-10) 1-10^(-10)];
opt_cdf.interp = 'cubic';
opt_cdf.flag_log = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FDR estimation options %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opt_fdr.nb_samps = 100;
opt_fdr.bins = Inf;

[cdfs,bins_measure] = niak_build_cdf(data,opt_boot,opt_mes,opt_cdf);

pce = 1-cdfs;
mes = niak_build_measure(data,opt_mes.opt_func);
pce_samp = zeros(size(mes));

for num_m = 1:size(cdfs,2)
    pce_samp(num_m) = interp1(bins_measure(:,num_m),pce(:,num_m),mes(num_m));
end

[fdr,bins_pce] = niak_build_fdr(pce,bins_measure,pce_samp,data,opt_boot,opt_mes,opt_fdr);