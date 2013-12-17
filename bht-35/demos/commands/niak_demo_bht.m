%
% _________________________________________________________________________
% SUMMARY NIAK_DEMO_BHT
%
% This is a script to demonstrate how to use the bootstrap hypothesis
% testing function NIAK_BHT to perform a test of significant AFC against a
% null hypothesis of independence between time series.
%
% SYNTAX:
% Just type in NIAK_DEMO_BHT
%
% _________________________________________________________________________
% OUTPUT
%
% The script will use NIAK_DEMO_DATA to generate an example dataset and
% will test for AFC values significantly different than under a null
% hypothesis of temporal independence.
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
opt.bootstrap(1).type = 'SB';
opt.bootstrap(1).opt.strata = {'gender'};

%% circular block bootstrap
opt.bootstrap(2).type = 'CBB'; %% Use of circular block bootstrap to resample the time series
opt.bootstrap(2).opt.field = 'tseries';
opt.bootstrap(2).opt.block_length = 10;
opt.bootstrap(2).opt.independence = true;

%%%%%%%%%%%%%%%%%%%%%%%%
%% Measure estimation %%
%%%%%%%%%%%%%%%%%%%%%%%%

opt.measure.function_name = 'niak_build_measure';
opt.measure.opt_func.flag_vec = true;
opt.measure.opt_func.measure_ind.type = 'AFC';
opt.measure.opt_func.measure_ind.field_argin1 = 'tseries';
opt.measure.opt_func.measure_ind.field_argin2 = 'part';
opt.measure.opt_func.measure_group.type = 'average';
opt.measure.opt_func.measure_group.label = 'average AFC';
opt.measure.opt_func.measure_group.field_subset = {};
opt.measure.opt_func.measure_group.val_subset = {};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CDF estimation options %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

opt.cdf.type = 'interp';
opt.cdf.nb_samps = 1000;
opt.cdf.limits = [-1 ; 1];
opt.cdf.nb_bins = 100;
opt.cdf.valx = [-1 1];
opt.cdf.valy = [10^(-10) 1-10^(-10)];
opt.cdf.interp = 'cubic';
opt.cdf.flag_log = true;
opt.cdf.flag_pooled = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FDR estimation options %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opt.fdr.nb_samps = 100;
opt.fdr.bins = Inf;

%%%%%%%%%%%%%%%%%
%% BHT options %%
%%%%%%%%%%%%%%%%%
opt.side = 'right-sided';

tests = niak_bht(data,opt);