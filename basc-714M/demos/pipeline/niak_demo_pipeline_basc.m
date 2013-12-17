%
% _________________________________________________________________________
% SUMMARY NIAK_DEMO_PIPELINE_BASC
%
% This is a script to demonstrate the usage of :
% NIAK_PIPELINE_BASC
%
% SYNTAX:
% Just type in NIAK_DEMO_PIPELINE_BASC
%
% _________________________________________________________________________
% OUTPUT
%
% It will apply a boostrap analysis of stable clusters to the six subjects
% in ~/data_demo/
%
% _________________________________________________________________________
% COMMENTS
%
% NOTE 1
% This script will clear the workspace !!
%
% NOTE 2
% Note that the path to access the demo data is stored in a variable
% called GB_NIAK_PATH_DEMO defined in the script NIAK_GB_VARS.
% 
% NOTE 3
% The demo database exists in multiple file formats.NIAK looks into the demo 
% path and is supposed to figure out which format you are intending to use 
% by himself.You can the format by changing the variable GB_NIAK_FORMAT_DEMO 
% in the script NIAK_GB_VARS.
% _________________________________________________________________________
% Copyright (c) Pierre Bellec, Montreal Neurological Institute, 2008.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : medical imaging, slice timing, fMRI

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
niak_gb_vars
niak_gb_basc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setting input/output files %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% list_num_subject = [561 562 563 565 567 568];
% list_gender = {'M','M','F','M','F','M'};

list_num_subject = [561 562];
list_gender = {'M','M'};
    
%switch gb_niak_format_demo
    
     %case 'minc1' % If data are in minc1 format

         num_e = 1;
         for num_s = list_num_subject
             name_subj = sprintf('mni_%i',num_s);
             files_in.(name_subj).fmri{1} = [gb_basc_demo_path name_subj '_fmr_1_mc_a_f_p_res_s.mnc.gz'];
             files_in.(name_subj).extra.gender = list_gender{num_e};
             num_e = num_e+1;
         end
        
    %otherwise 
        
     %   error('niak:demo','%s is an unsupported file format for this demo. See help to change that.',gb_niak_format_demo)
        
%end

%%%%%%%%%%%%%%%%%%%%
%% Options : Misc %%
%%%%%%%%%%%%%%%%%%%%

opt.flag_test = false; 
opt.folder_out = [gb_basc_demo_path,filesep,'basc',filesep];

%%%%%%%%%%%%%%%%%%%%
%% Options : PSOM %%
%%%%%%%%%%%%%%%%%%%%

%opt.psom.mode = 'batch';
opt.psom.mode = 'session';
opt.psom.max_queued = 2;
opt.psom.mode_pipeline_manager = 'session';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Options : region growing %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opt.region_growing.ind_rois = [2001 2002];
opt.region_growing.thre_size = 50;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Options : individual stability %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Clustering options
clustering.type_clust = 'kmeans';
clustering.opt_clust.nb_iter = 5;
clustering.opt_clust.flag_verbose = 0;
clustering.opt_clust.type_init = 'random_point';
clustering.opt_clust.type_death = 'singleton';

%list_nb_classes = [3 4 5 6 10 13];
list_nb_classes = [3 4 5 10];
for num_c = 1:length(list_nb_classes)
    opt.stability_ind.clustering(num_c) = clustering;
    opt.stability_ind.clustering(num_c).opt_clust.nb_classes = list_nb_classes(num_c);
end

%% Bootstrap options
opt.stability_ind.bootstrap.dgp = 'CBB';
opt.stability_ind.bootstrap.block_length = 10;
opt.stability_ind.bootstrap.independence = false;

%% Sampling option
opt.stability_ind.nb_samps_stab = [100 100];
opt.stability_ind.nb_samps_cdf = 1000;

%% Normalization option
opt.stability_ind.correction_ind.type = 'mean_var';
opt.stability_ind.correction_group.type = 'mean_var';

%%%%%%%%%%%%%%%%%%%%%
%% Group stability %%
%%%%%%%%%%%%%%%%%%%%%

%% Options : bootstrap

opt.stability_group.bootstrap.type = 'SB';
opt.stability_group.bootstrap.opt.strata = {'gender'};

%% Options : cdf

opt.stability_group.cdf.nb_samps = 10000;
opt.stability_group.cdf.flag_pooled = true;
opt.stability_group.cdf.flag_log = true;
opt.stability_group.cdf.type = 'interp';
opt.stability_group.cdf.limits = [0 ; 1];
opt.stability_group.cdf.nb_bins = 300;
opt.stability_group.cdf.valx = [0 1];
opt.stability_group.cdf.valy = [10^(-10) 1-10^(-10)];

%% Options : fdr

opt.stability_group.fdr.nb_samps = 500;
opt.stability_group.fdr.bins = Inf;

%%%%%%%%%%%%%%%%%%%%%%%%
%% Threshold pipeline %%
%%%%%%%%%%%%%%%%%%%%%%%%

opt.threshold_stability.threshold_pce = 0.01;
opt.threshold_stability.threshold_size = 4;

%%%%%%%%%%%%%%%%%%%%%%
%% Run the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%
pipeline = niak_pipeline_basc(files_in,opt);

%% Note that opt.interpolation_method has been updated, as well as files_out

