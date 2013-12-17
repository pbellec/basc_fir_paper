clear

niak_demo_bootstrap_data

%% Clustering options
opt_samp.type_clustering = 'kmeans';
opt_samp.clustering.nb_classes = 2;
opt_samp.clustering.nb_iter = 1;
opt_samp.clustering.flag_verbose = 0;

%% Bootstrap options
opt_samp.bootstrap.group.dgp = {'subject'};
opt_samp.bootstrap.individual.dgp = 'CBB';
opt_samp.bootstrap.individual.block_length = 10;

%% Bootstrap options under the null
opt_samp.bootstrap_null.group.dgp = {'subject'};
opt_samp.bootstrap_null.group.independence_space = {'subject'}; % samples from different subjects are independent spatially
opt_samp.bootstrap_null.individual.dgp = 'CBB';
opt_samp.bootstrap_null.individual.block_length = 10;

%% Sampling option 
opt_samp.nb_samps_form = 10;
opt_samp.nb_samps_data = 30;
opt_samp.flag_verbose = 1;

%% Build actual forms
samps = niak_sample_form_null(data,opt_samp);

%% Visualize the samples
opt_visu.limits = [0 1];
opt_visu.color_map = 'jet';
for num_s = 1:size(samps,2)
    niak_visu_matrix(niak_vec2mat(samps(:,num_s)),opt_visu);
    pause(1)
end

