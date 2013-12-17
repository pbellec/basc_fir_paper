function [cdfs,bins,mean_v,std_v] = niak_build_cdf(data,bootstrap,measure,opt_cdf)
% Estimate a left-sided cumulative distribution function (cdf) 
% For a dataset y, a resampling scheme y -> y* and a functional y* -> m(y*) :
%                           y -> y* -> m(y*)
% The (left-sided) cdf is:
%                      cdfl(x) = Pr( m(y*)<=x | y->y* )
%
% The (right-sided) cdf is:
%                      cdfr(x) = Pr( m(y*)<=x | y->y* )
%
% SYNTAX:
% [CDFS,BINS,MEAN_V,STD_V] = NIAK_BUILD_CDF(DATA,BOOTSTRAP,MEASURE,CDF)
%
% _________________________________________________________________________
% INPUTS:
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
%        >> data_boot = feval(NAME_BOOT,DATA,OPT.BOOTSTRAP.OPT_BOOT)
%        FUNCTION_NAME can be for example 'niak_bootstrap_data'.
%
%    OPT_BOOT
%           (any type, default []) the option of the resampling scheme.
%           See the description of OPT.BOOTSTRAP.NAME_BOOT above.
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
% OPT_CDF
%
%    (structure) with the following fields:
%
%    NB_SAMPS
%        (integer, default 10000) the number B of samples that will be 
%        used to perform the CDF estimation.
%
%    FLAG_POOLED
%        (boolean, default false) If FLAG_POOL is true, all the
%        components of the measure are assumed to have the same cdf.
%        The samples of the different components are thus pooled to
%        produce one cdf estimate.
%
%    TYPE
%        (string, default 'bins') The method to build the cdf, 
%        available choices:
%               
%            'bins' 
%                the cdf is estimated on a fixed grid of values.
%                       
%            'empirical'
%                the usual empirical cdf.
%           
%    LIMITS   
%        (vector 2*1 or 2*M, default : estimation)
%        LIMITS(:,M) are the min/max possible values of the Mth 
%        component of the measure. If the vector is 2*1, the 
%        same limits are used for all of the components.
%        If LIMITS is left empty, a first pass with
%        NB_SAMPS_1PASS will be made to estimate the LIMITS
%        using NB_STD_LIMITS standard-deviation away from the mean.
%
%    FLAG_MEAN_STD
%        (boolean, default false) If FLAG_MEAN_STD is true, only 
%        estimate the mean and the standard deviation. The CDFS and 
%        BINS are left empty.
%
%    NB_SAMPS_1PASS
%        (integer, default 100) number of samples for first pass, if
%        any.
%
%    NB_STD_LIMITS
%        (integer, default 10) the number of std away from the mean
%        to set the limits in a data-driven way.
%
%    NB_BINS
%        (scalar)
%        The number of bins to use on the measure grid.
%
%    FLAG_VERBOSE 
%        (boolean, default true) If FLAG_VERBOSE == 1, write
%        messages indicating progress.
%
% _________________________________________________________________________
% OUTPUTS:
%
% CDFS      
%    (matrix) CDFS(:,NUM_M,1) is the estimated (left-sided) cumulative 
%    distribution function of the NUM_M-th component of the measure, and
%    CDF(:,NUM_M,2) is the right-sided cumulative distribution function.
%
% BINS  
%    (matrix) BINS(:,NUM_M) are the bins used to build the estimated 
%    cdf on the NUM_M-th component of the measure.
%
% MEAN_V
%    (vector) MEAN_V(NUM_M) is the bootstrap estimate of the mean of the
%    NUM_M-th component of the measure. 
%
% STD_V
%    (vector) STD_V(NUM_M) is the bootstrap estimate of the standard
%    deviation of the NUM_M-th component of the measure. 
%
% _________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Pierre Bellec
% Département d'informatique et de recherche opérationnelle
% Centre de recherche de l'institut de Gériatrie de Montréal
% Université de Montréal, 2011
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : statistics, cumulative distribution function

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
if ~exist('data','var')||~exist('bootstrap','var')||~exist('measure','var')||~exist('opt_cdf','var')
    error('Syntax : [CDFS,BINS,MEAN_V,STD_V] = NIAK_BUILD_CDF(DATA,BOOTSTRAP,MEASURE,OPT_CDF) ; for more infos, type ''help niak_build_cdf''.')
end

%% Measure estimation options
gb_name_structure = 'measure';
gb_list_fields    = {'name_mes', 'opt_mes' };
gb_list_defaults  = {NaN       , []       };
niak_set_defaults

%% Bootstrap options
gb_name_structure = 'bootstrap';
gb_list_fields    = {'name_boot' , 'opt_boot' };
gb_list_defaults  = {NaN         , []        };
niak_set_defaults

%% CDF estimation options
gb_name_structure = 'opt_cdf';
gb_list_fields    = {'flag_mean_std' , 'nb_std_limits' , 'nb_samps_1pass' , 'flag_verbose' , 'flag_pooled' , 'nb_samps' , 'type' , 'limits' , 'nb_bins' };
gb_list_defaults  = {false           , 10              , 100              , true           , false         , 10000      , 'bins' , []       , []        };
niak_set_defaults

if size(opt_cdf.limits,1)>2
    error('OPT_CDF.LIMITS can only have two rows (min/max)');
end

if flag_mean_std
    opt_cdf.type = 'empirical';
    type = 'empirical';
end

if isempty(limits)&&~flag_mean_std
    % 1st pass    
    if flag_verbose
        fprintf('First pass : setting up windows \n');
    end
    opt_cdf.nb_samps = opt_cdf.nb_samps_1pass;
    opt_cdf.flag_mean_std = true;    
    [tmp1,tmp2,mean_v,std_v] = niak_build_cdf(data,bootstrap,measure,opt_cdf);        
    
    % 2nd pass
    if flag_verbose
        fprintf('Second pass : cumulative distribution function estimation\n');
    end
    opt_cdf.limits = [(mean_v-nb_std_limits*std_v)';(mean_v+nb_std_limits*std_v)'];   
    opt_cdf.nb_samps = nb_samps;
    opt_cdf.flag_mean_std = false;
    [cdfs,bins,mean_v,std_v] = niak_build_cdf(data,bootstrap,measure,opt_cdf);    
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% The cdf estimation starts here %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mes = feval(name_mes,data,opt_mes);

nb_mes = length(mes);

mean_v = zeros([nb_mes 1]);    
std_v = zeros([nb_mes 1]);

if flag_mean_std
    opt_cdf.type = 'empirical';
end

switch opt_cdf.type
    
    case 'empirical'
        
        %% Generate B bootstrap replications of the measure
        if ~flag_mean_std
            samps = zeros([nb_samps nb_mes]);
        end

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
            if ~flag_mean_std
                samps(num_s,:) = mes(:)';
            end

            mean_v = mean_v + mes(:);
            std_v = std_v + mes(:).^2;
            
        end
        
        if flag_verbose
            fprintf('\n');
        end
        
        if ~flag_mean_std
            %% Build the cdf
            if flag_pooled
                samps = samps(:);
            end
            bins = sort(samps,1,'ascend');
            if flag_pooled
                cdfs = (1:(nb_samps*nb_mes))'/(nb_samps*nb_mes);
                cdfs(:,2) = cdfs(end:-1:1);
            else
                cdfs = repmat((1:nb_samps)'/nb_samps,[1 nb_mes]);
                cdfs(:,:,2) = cdfs1(end:-1:1);
            end
        else
            cdfs = [];
            bins = [];
        end
        
    case {'bins','interp'}
        
        %% Build the bins
        if flag_pooled
            bins = (limits(1,1):( limits(2,1) - limits(1,1))/(nb_bins-1):limits(2,1))';
        else
            if size(limits,2) == 1
                limits = repmat(limits(:),[1 nb_mes]);
            end
            bins = zeros([nb_bins nb_mes]);
            for num_m = 1:nb_mes
                if limits(1,num_m) < limits(2,num_m)
                    bins(:,num_m) = linspace(limits(1,num_m),limits(2,num_m),nb_bins)';
                else
                    bins(:,num_m) = limits(1,num_m);
                end
            end
        end

        %% Estimate the histogram of bootstrap samples
        if flag_pooled
            cdfs = zeros(size(bins));
            vec_min = limits(1);
            vec_step = ( limits(2,1) - limits(1))'/(nb_bins-1);
        else            
            cdfs = zeros([size(bins,1) nb_mes]);
            vec_min = limits(1,:)';
            vec_step = ( limits(2,:) - limits(1,:))'/(nb_bins-1);
        end
        cdfs2 = cdfs;
        ind_mes = (1:nb_mes)';
        
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
            mes = mes(:);

            if flag_pooled
                ind_samp = max(min(((mes-vec_min)/vec_step)+1,size(bins,1)),1);
                ind_samp2 = ceil(ind_samp);
                ind_samp = floor(ind_samp);
                for num_m = 1:nb_mes
                    cdfs(ind_samp(num_m)) = cdfs(ind_samp(num_m))+1;
                    cdfs2(ind_samp2(num_m)) = cdfs2(ind_samp2(num_m))+1;
                end
            else
                ind_samp = max(min(((mes-vec_min)./vec_step)+1,size(bins,1)),1);
                ind_cdfs  = niak_sub2ind_2d(size(cdfs),floor(ind_samp),ind_mes);
                ind_cdfs2 = niak_sub2ind_2d(size(cdfs),ceil(ind_samp),ind_mes);
                cdfs(ind_cdfs) = cdfs(ind_cdfs)+1;
                cdfs2(ind_cdfs2) = cdfs2(ind_cdfs2)+1;
            end

            mean_v = mean_v + mes(:);
            std_v = std_v + mes(:).^2;
            
        end
        
        if flag_verbose
            fprintf('\n');
        end
        
        if flag_pooled
            cdfs = cumsum(cdfs,1)/(nb_samps*nb_mes + 1);
            cdfs(:,2) = (nb_samps*nb_mes-cumsum(cdfs2,1))/(nb_samps*nb_mes + 1);
        else
            cdfs = cumsum(cdfs,1)/(nb_samps+1);
            cdfs(:,:,2) = (nb_samps-cumsum(cdfs2,1))/(nb_samps+1);
        end
                
    otherwise
        
        error('OPT_CDF.TYPE = %s is an unkown type of estimation method for the cdf.',opt_cdf.type)
        
end      

mean_v = mean_v / nb_samps;
std_v = std_v / nb_samps - mean_v.^2;
std_v = sqrt(std_v);