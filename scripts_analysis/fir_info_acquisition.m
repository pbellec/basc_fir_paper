clear

path_raw = '/media/database2/BASC_FIR/raw_mnc/';

list_folders = dir(path_raw);
list_folders = {list_folders.name};
list_folders = list_folders(~ismember(list_folders,{'.','..'}));

%% Functional volumes
for num_f = 1:length(list_folders)
    fprintf('%s\n',list_folders{num_f});
    file_rest = [path_raw list_folders{num_f} filesep 'task.mnc.gz'];
    
    hdr = niak_read_vol(file_rest);
    nb_vol(num_f) = hdr.info.dimensions(4);
    sex{num_f} = niak_get_minc_att (hdr,'patient','sex');
    age{num_f} = niak_get_minc_att (hdr,'patient','age');
    tr(num_f) = niak_get_minc_att (hdr,'time','step');
    te(num_f) = niak_get_minc_att (hdr,'acquisition','echo_time');
    fa(num_f) = niak_get_minc_att (hdr,'acquisition','flip_angle');
    mat_size(num_f,:) = hdr.info.dimensions(1:3);
    voxel_size(num_f,:) = hdr.info.voxel_size;    
end

%% Reshape info
for num_s = 1:length(age)
   age_v(num_s) = str2num(age{num_s}(2:3));
end
fprintf('Mean age: %1.2f; min age: %1.2f; max age: %1.2f\n',mean(age_v),min(age_v),max(age_v));
fprintf('Mean nb vol: %1.2f; std nb vol: %1.2f; min nb vol: %1.2f; max nb vol: %1.2f\n',mean(nb_vol),std(nb_vol),min(nb_vol),max(nb_vol));
fprintf('Number of male: %i\n',sum(ismember(sex,'female')));
