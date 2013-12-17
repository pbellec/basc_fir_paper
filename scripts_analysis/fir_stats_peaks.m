%% A script to generate statistics on the peaks of the FIR
clear
fir_gb_vars
path_data = '/home/pbellec/database/BASC_FIR/stability_fir_std_4';
path_tseries = '/home/pbellec/database/BASC_FIR/fir_rois/rois';

%% # Samples for the estimation of the significance of differences
nb_samps = 10000;
%nb_samps = 100;

%% FIR estimation options
opt.fir.type          = 'fir_shape';
opt.fir.time_norm     = 1;
opt.fir.time_sampling = 1;

%% List of scales
scales_maps = ...
[  2    2    2 
   5    4    4  
   10   10   9   
   8    11   10 
   10   12   11 
   10   13   12 
   10   10   13 
   15   12   14 
   20   18   15 
   20   18   16 
   22   16   17 
   20   18   18 
   22   16   19 
   22   16   20 
   24   27   21 
   26   29   22 
   30   27   23 
   32   26   24 
   30   27   25 
   30   27   26 
   30   27   27 
   30   33   28 
   30   33   29 
   37   34   30 
   37   34   31 
   30   30   32 
   30   39   33 
   30   27   34  
  120   84  115  
  250  250  283 ]; 

%% Build the pipeline
pipeline = struct();
nb_subject = length(list_subject);
nb_scales = size(scales_maps,1);
for num_s = 1:nb_subject
    job_in.fir_all{num_s} = [path_tseries filesep 'fir_tseries_' list_subject{num_s} '_roi.mat'];
end
job_in.atoms = [path_tseries filesep 'brain_rois.nii.gz'];;
job_opt.nb_samps = nb_samps;
job_opt.normalize = opt.fir;
    
for num_sc = 1:nb_scales    
    job_opt.rand_seed = num_sc;    
    label_scale = ['sci' num2str(scales_maps(num_sc,1)) '_scg' num2str(scales_maps(num_sc,2)) '_scf' num2str(scales_maps(num_sc,end))];
    job_in.partition = [path_data filesep 'stability_group' filesep label_scale filesep 'brain_partition_core_group_' label_scale '.nii.gz'];
    job_out.fdr = [path_data filesep 'stats_peaks_group' filesep 'stats_peaks_group_exec_minus_prep_' label_scale '.mat'];
    pipeline = psom_add_job(pipeline,['stats_peaks_' label_scale],'fir_brick_stat_peaks',job_in,job_out,job_opt,false);   
end
opt_pipe.path_logs = [path_data filesep 'stats_peaks_group' filesep 'logs'];
