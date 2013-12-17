function tests = niak_bht(data,opt)
% Perform a bootstrap hypothesis test. 
% Let y be a dataset, m(y) is a multivariate measure estimated on the 
% database :
%
%                   y -> m(y) = (m_i(y))_{i=1...I}
%
% A bootstrap sampling scheme is designed such that it is valid under some 
% null hypothesis, and still conforms with the null hypothesis even when 
% this hypothesis is not verified : 
%
%                       (H0) y -> y* -> m(y*)
%
% The Bootstrap hypothesis test consists in estimating one of the following 
% quantities : 
%
%   * Left-sided per-comparison error : 
%
%               p_i- = Pr(m_i(y*)<=m_i(y)| H0 )
%
%   * Right-sided per-comparison error : 
%
%               p_i+ = Pr(m_i(y*)>=m_i(y)| H0 ) 
%
%   * Two-sided per-comparison error : 
%
%               p_i = 2 min(p_i-,p_i+)
%
% Note that the equality p_i+ = 1-p_i- holds only when m_i(y*) is different
% of m_i(y) for all i, which is almost surely the case for continuous 
% random variables, but is not assumed in this procedure.
%
% For a given threshold on the per-comparison error, the procedure by
% Benjamini (1995) is used to estimate the false-discovery rate associated 
% with the family of tests on all (m_i(y))_{i=1...I}.
%
% SYNTAX:
% TESTS = NIAK_BHT(DATA,OPT)
%
% _________________________________________________________________________
% INPUTS:
%
% DATA   
%   (?) DATA is a dataset. Its type depends on OPT.MEASURE and OPT.CDF.
%
% OPT    
%   (structure) describe the statistical tests to perform on data. The 
%   following fieds will be used :
%
%   BOOTSRAP
%   (structure) describes the bootstrap scheme that will be applied
%   to the database. The structure has the following fields : 
%
%       NAME_BOOT
%           (string) the name of a function. The data will be resampled
%           by invoking the command :
%               >> data_boot = feval(NAME_BOOT,DATA,OPT.BOOTSTRAP.OPT_BOOT)
%           FUNCTION_NAME can be for example 'niak_bootstrap_data'.
%
%       OPT_BOOT
%           (any type, default []) the option of the resampling scheme.
%           See the description of OPT.BOOTSTRAP.NAME_BOOT above.
%
%   MEASURE
%       (structure) describe which measure will be estimated on the 
%       data. The structure has the following fields : 
%   
%       NAME_MES
%           (string) the name of a function, the measure will be 
%           estimated by invoking the command : 
%               >> mes = feval(NAME_MES,DATA,OPT.MEASURE.OPT_MES)
%           NAME_MES can be 'niak_build_measure' for example.
%
%       OPT_MES
%           (any type, default []) the option of the measure estimation. 
%           See the description of OPT.MEASURE.NAME_MES above.
%
%   CDF
%       (structure) how to estimate the cumulative distribution
%       function under the null hypothesis. See the OPT_CDF argument of
%       NIAK_BUILD_CDF.
%
%   FDR
%       (structure) how to estimate the false-discovery test associated
%       with each test. See NIAK_BUILD_FDR.
%
%   SIDE
%       (string, default 'two-sided') the type of per-comparison error.
%       Available options : 'two-sided', 'left-sided', 'right-sided'
%       
%   FLAG_VERBOSE 
%       (boolean, default true) print messages to indicate which 
%       computation are being done.
%
% _________________________________________________________________________
% OUTPUTS:
%
% TESTS
%   (structure) with the following fields :
%
%   BINS_MEASURE
%       (matrix) BINS_MEASURE(:,M) are the bins used on the Mth 
%       component of the connectivity measure to estimate the CDF and
%       PCE.
%
%   BINS_PCE
%       (vector) the bins used on the PCE to estimate the FDR.
%
%   CDFS   
%       (matrix) CDFS(:,M,1) is the bootstrap left-side cdf evaluated on 
%       BINS_MEASURE for the Mth component of the measure, and
%       CDFS(:,M,2) is the right-sided cumulative distribution
%       function.
%
%   PCE  
%       (vector) PCE(M) is the per-comparison error for the Mth
%       component of the measure. The exact definition of the PCE
%       depends on OPT.SIDE (either left-, right- or two-sided
%       hypothesis).
%
%   FDR  
%       (vector) FDR(I) is the false discovery rate for a threshold on
%       the per-comparison error equals to PCE(I).
%
%   FDR_DIST
%       (vector) FDR(I) is the false discovery rate for a threshold on
%       the per-comparison error equals to BINS_PCE(I).
%
%   PLUGIN 
%       (vector) the plug-in estimated measure.
%
%   MEAN
%       (vector) the bootstrap estimate of the mean of the estimated
%       measure.
%
%   STD
%       (vector) the bootstrap estimate of the standard deviation of
%       the estimated measure
%
% _________________________________________________________________________
% SEE ALSO:
% NIAK_BUILD_CDF, NIAK_BUILD_FDR
% _________________________________________________________________________
% COMMENTS:
%
% It is possible to pool the cdf estimates for all components of the
% measure by specifying OPT.CDF.FLAG_POOLED = true. 
% In that case, TESTS.CDFS is just a vector.
%
% Some details about bootstrap hypothesis test for time series can be 
% found in the following reference:
%
%   P. Bellec; G. Marrelec; H. Benali, A bootstrap test to investigate 
%   changes in brain connectivity for functional MRI.Statistica Sinica, 
%   special issue on Statistical Challenges and Advances in Brain Science.
%
% Copyright (c) Pierre Bellec
% Département d'informatique et de recherche opérationnelle
% Centre de recherche de l'institut de Gériatrie de Montréal
% Université de Montréal, 2011
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : bootstrap, hypothesis testing, null distribution

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

%%%%%%%%%%%%%%%%%%%%%%%%
% set default inputs %%%
%%%%%%%%%%%%%%%%%%%%%%%%

flag_gb_niak_fast_gb = true;
niak_gb_vars

gb_name_structure = 'opt';
gb_list_fields = {'bootstrap','measure','cdf','fdr','side','flag_verbose'};
gb_list_defaults = {NaN,NaN,NaN,NaN,'two-sided',true};
niak_set_defaults

gb_name_structure = 'opt.measure';
gb_list_fields = {'name_mes','opt_mes'};
gb_list_defaults = {NaN,[]};
niak_set_defaults

gb_name_structure = 'opt.bootstrap';
gb_list_fields = {'name_boot','opt_boot'};
gb_list_defaults = {NaN,[]};
niak_set_defaults

%%%%%%%%%%%%%%%%%%%%%%%
%%% BHT starts now   %%
%%%%%%%%%%%%%%%%%%%%%%%

%% Derive the plug-in estimate
if flag_verbose
    fprintf('Deriving the plugin estimate... \n');
end

mes = feval(name_mes,data,opt_mes);

%% Derive the cumulative distribution functions
if flag_verbose
    fprintf('Deriving the bootstrap cumulative distribution functions... \n');
end

opt.cdf.flag_verbose = opt.flag_verbose;
[cdfs,bins_measure,mean_v,std_v] = niak_build_cdf(data,opt.bootstrap,opt.measure,opt.cdf);

%% Derive the per-comparison errors
if flag_verbose
    fprintf('Deriving the per-comparison errors... \n');
end

nb_mes = length(mes);

max_bm = max(bins_measure,[],1);
min_bm = min(bins_measure,[],1);
if ndims(cdfs)==2
    pcel = sub_interp_pce(nb_mes,cdfs(:,1),mes,bins_measure,min_bm,max_bm,1);
    pcer = sub_interp_pce(nb_mes,cdfs(:,2),mes,bins_measure,min_bm,max_bm,0);
else
    pcel = sub_interp_pce(nb_mes,cdfs(:,:,1),mes,bins_measure,min_bm,max_bm,1);
    pcer = sub_interp_pce(nb_mes,cdfs(:,:,2),mes,bins_measure,min_bm,max_bm,0);
end

switch opt.side
    
    case 'left-sided'

        pce = pcel;
        if ndims(cdfs)==2
            pce_dist = cdfs(:,1);
        else
            pce_dist = cdfs(:,:,1);
        end
        
    case 'right-sided'
        
        pce = pcer;
        if ndims(cdfs)==2
            pce_dist = cdfs(:,2);
        else
            pce_dist = cdfs(:,:,2);
        end
       
    case 'two-sided'
        
        pce = 2*min(pcel,pcer);
        pce_dist = 2*min(cdfs(:,:,1),cdfs(:,:,2));
        
    otherwise
        
        error('%s : is an unknown option for OPT.SIDE',opt.side);
end

%% Derive estimate of the false-discovery rate for various pce thresholds
if flag_verbose
    fprintf('Deriving the false-discovery rate... \n');
end

opt.fdr.flag_verbose = opt.flag_verbose;
[fdr_dist,bins_pce] = niak_build_fdr(pce_dist,bins_measure,pce,data,opt.bootstrap,opt.measure,opt.fdr);

if opt.fdr.nb_samps == 0;
    fdr = nan(size(pce));
else
    if length(bins_pce)>1
        fdr = interp1(bins_pce,fdr_dist,pce,'linear');
    else
        fdr = fdr_dist;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Formatting the outputs           %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if flag_verbose
    fprintf('Formatting the outputs... \n');
end

tests.bins_measure = bins_measure;
tests.bins_pce = bins_pce;
tests.cdfs = cdfs;
tests.pce = pce;
tests.fdr = fdr;
tests.fdr_dist = fdr_dist;
tests.plugin = mes;
tests.mean = mean_v;
tests.std = std_v;

if flag_verbose
    fprintf('Done !\n');
end

%%%%%%%%%%%%%%%%%%
%% Subfunctions %%
%%%%%%%%%%%%%%%%%%
function pce = sub_interp_pce(nb_mes,cdfs,mes,bins_measure,min_bm,max_bm,flag_left);
% Interpolate the PCE values for the plug-in estimate
pce = zeros([nb_mes 1]);
for num_m = 1:nb_mes
    if size(cdfs,2) == 1
        if mes(num_m) > max_bm
            pce(num_m) = flag_left;
        elseif mes(num_m) < min_bm
            pce(num_m) = 1-flag_left;
        else
            if any(bins_measure==mes(num_m))
                pce(num_m) = max(cdfs(bins_measure==mes(num_m)));
            else
                pce(num_m) = interp1(bins_measure,cdfs,mes(num_m),'linear');
            end
        end
    else
        if mes(num_m) > max_bm(num_m)
            pce(num_m) = flag_left;
        elseif mes(num_m) < min_bm(num_m)
            pce(num_m) = 1-flag_left;
        else
            if any(bins_measure(:,num_m)==mes(num_m))
                pce(num_m) = max(cdfs(bins_measure(:,num_m)==mes(num_m),num_m));
            else 
                pce(num_m) = interp1(bins_measure(:,num_m),cdfs(:,num_m),mes(num_m),'linear');
            end
        end
    end
end