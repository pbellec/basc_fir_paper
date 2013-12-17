
%% In which path is BASC ?
str_kmeans = which('niak_kmeans_clustering');
if isempty(str_kmeans)
    error('NIAK is not in the path ! (could not find NIAK_READ_VOL)')
end
tmp_folder = niak_string2words(str_kmeans,{filesep});
gb_basc_path = filesep;
for num_f = 1:(length(tmp_folder)-3)
    gb_basc_path = [gb_basc_path tmp_folder{num_f} filesep];
end

%% The BASC demo data path
gb_basc_demo_path = [gb_basc_path filesep 'data_demo' filesep];