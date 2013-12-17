function [fdr,bins_pce] = niak_build_fdr(pce,bins_measure,pce_emp,data,bootstrap,measure,opt_fdr)
% Estimate the false-discovery rate as a function of the per-comparison
% error (PCE).
%
% SYNTAX:
% [FDR,BINS_PCE] = NIAK_BUILD_FDR(PCE,BINS_MEASURE,PCE_EMP,DATA,BOOTSTRAP,MEASURE,OPT_FDR)
%
% _________________________________________________________________________
% INPUTS:
%
% PCE
%    (matrix size NB_BINS*M) PCE(I,M) is the estimated per-comparison
%    error for the value BINS_MEASURE(I,M) of the Mth component of the
%    measure.
%
% BINS_PCE
%    (matrix size NB_BINS*M) BINS_PCE(:,M) are the bins used for the Mth
%    component of the measure.
%
% PCE_EMP
%    (vector size [M 1]) the real per-comparison error estimated for
%    each component of the measure.
%
% DATA
%    (structure) DATA is a database organized into a matlab structure,
%    with an arbitrary number of fields and entries.
%
% BOOTSRAP
%    (structure) describes the bootstrap scheme that will be applied
%    to the database. The structure has the following fields : 
%
%    NAME_BOOT
%        (string) the name of a function. The data will be resampled
%        by invoking the command :
%            >> data_boot = feval(NAME_BOOT,DATA,OPT.BOOTSTRAP.OPT_BOOT)
%        FUNCTION_NAME can be for example 'niak_bootstrap_data'.
%
%    OPT_BOOT
%        (any type, default []) the option of the resampling scheme.
%        See the description of OPT.BOOTSTRAP.NAME_BOOT above.
%
% MEASURE
%    (structure) describe which measure will be estimated on the 
%    data. The structure has the following fields : 
%         
%    NAME_MES
%        (string) the name of a function, the measure will be 
%        estimated by invoking the command : 
%            >> mes = feval(NAME_MES,DATA,OPT.MEASURE.OPT_MES)
%        NAME_MES can be 'niak_build_measure' for example.
%
%    OPT_MES
%        (any type, default []) the option of the measure estimation. 
%        See the description of OPT.MEASURE.NAME_MES above.
%
% OPT_FDR
%    (structure) with the following fields:
%
%    NB_SAMPS
%        (integer, default 100) the number B of samples that will be
%        used to perform the FDR estimation.
%
%    BINS
%        (vector, default []) The bins that will used on the PCE values.
%        Special cases :
%
%        [] : use a default value that fully covers [0 1] and emphasizes
%        small values.
%
%        Inf : use the estimated per-comparison errors themselves for
%        bins.
%
%    FLAG_VERBOSE 
%        (boolean, default true) If FLAG_VERBOSE == 1, write
%        messages indicating progress.
%
% _________________________________________________________________________
% OUTPUTS:
%
% FDR
%    (vector [NB_BINS 1]) FDR(I) is the estimated FDR for a PCE
%    threshold equals to BINS_PCE(I).
%
% BINS_PCE
%    (vector [NB_BINS 1]) the bins used on the PCE values.
%
% _________________________________________________________________________
% COMMENTS:
%
% if PCE has just one column, the same PCE function will be used for all
% the components of the measure.
%
% If the number of samples is 0, FDR has the right size but is filled with
% NaNs.
%
% Copyright (c) Pierre Bellec
% Département d'informatique et de recherche opérationnelle
% Centre de recherche de l'institut de Gériatrie de Montréal
% Université de Montréal, 2011
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : bootstrap, false-discovery rate, hypothesis testing

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialization and syntax checks %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Syntax
if ~exist('pce','var')||~exist('bins_measure','var')||~exist('pce_emp','var')||~exist('data','var')||~exist('bootstrap','var')||~exist('measure','var')
    error('Syntax : [FDR,BINS_PCE] = NIAK_BUILD_FDR(PCE,BINS_MEASURE,PCE_EMP,DATA,BOOTSTRAP,MEASURE,OPT_FDR) ; for more infos, type ''help niak_build_fdr''.')
end

%% Measure estimation options
gb_name_structure = 'measure';
gb_list_fields    = {'name_mes' , 'opt_mes' };
gb_list_defaults  = {NaN        , NaN       };
niak_set_defaults

%% Bootstrap options
gb_name_structure = 'bootstrap';
gb_list_fields = {'name_boot','opt_boot'};
gb_list_defaults = {NaN,NaN};
niak_set_defaults

%%% FDR estimation options
gb_name_structure = 'opt_fdr';
gb_list_fields = {'flag_verbose','nb_samps','bins'};
gb_list_defaults = {true,100,Inf};
niak_set_defaults

if length(opt_fdr.bins) == 1

    if opt_fdr.bins == Inf
        bins_pce = pce_emp;
    end

elseif isempty(opt_fdr.bins)

    bins_pce =[0];
    for pow = -5:-2
        bins_pce = [bins_pce 10^pow:10^(pow):10^(pow+1)-10^(pow)];
    end
    bins_pce = [bins_pce 0.1:0.01:1]; % That's the grid for the cdf values.
    bins_pce = bins_pce(:);

else

    bins_pce = opt.bins;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FDR estimation starts now %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bins_pce = unique(bins_pce);
bins_pce = sort(bins_pce);

nb_bins = length(bins_pce);
nb_mes = length(pce_emp);

V = zeros([nb_bins 1]);

for num_p = 1:nb_bins
    V(num_p) = max(sum(pce_emp <= bins_pce(num_p))-(bins_pce(num_p)*nb_mes),0);
end

if nb_samps > 0
    fdr = zeros([nb_bins 1]);
    pce_samp = zeros([nb_mes 1]);

    if flag_verbose
        fprintf('     Percentage done : ');
        curr_perc = -1;
    end

    for num_s = 1:nb_samps

        if flag_verbose
            new_perc = 5*floor(20*num_s/nb_samps);
            if curr_perc~=new_perc
                fprintf(' %1.0f',new_perc);
                curr_perc = new_perc;
            end
        end

        data_boot = feval(name_boot,data,opt_boot);
        mes = feval(name_mes,data_boot,opt_mes);

        if size(pce,2)==1

            pce_samp = interp1(bins_measure,pce,mes,'nearest');

        else

            for num_m = 1:nb_mes

                pce_samp(num_m) = interp1(bins_measure(:,num_m),pce(:,num_m),mes(num_m),'nearest');

            end

        end

        for num_p = 1:nb_bins

            F = sum(pce_samp<=bins_pce(num_p));

            if F ~= 0
                fdr(num_p) = fdr(num_p) + F./(F+V(num_p));
            end
        end

    end

    if flag_verbose
        fprintf('\n');
    end
    fdr = fdr/nb_samps;
else
    fdr = nan([nb_bins 1]);
end