%% Histogram of group compound stability -- REST experiment
clear
path_data = '/home/pbellec/database/BASC_FIR/';
path_out = '/home/pbellec/database/BASC_FIR/figures_sm/fig_stab_compound/';
list_std_noise = [0 2 4];
list_scales = [5 5 5; 10 10 10; 25 25 25; 50 50 50; 100 100 100 ; 200 200 200];
%list_scales = [5 5 5 ; 10 10 10; 50 50 50];
for num_sc = 1:length(list_scales)
    hf = figure ;
    label_std = cell([length(list_std_noise) 1]);
    for num_std = 1:length(list_std_noise)           
        label_scale = ['sci' num2str(list_scales(num_sc,1)) '_scg' num2str(list_scales(num_sc,2)) '_scf' num2str(list_scales(num_sc,3))];    
        label_std{num_std} = ['std' num2str(list_std_noise(num_std))];
        file_stability = [path_data 'stability_fir_rest' filesep 'std_' num2str(list_std_noise(num_std)) filesep 'stability_group' filesep label_scale filesep 'compound_stability_map_group_' label_scale '.nii.gz'];    
        [hdr,vol] = niak_read_vol(file_stability);
        file_atoms = [path_data 'stability_fir_rest' filesep 'std_' num2str(list_std_noise(num_std)) filesep  'atoms' filesep 'brain_atoms.nii.gz'];
        [hdr,atoms] = niak_read_vol(file_atoms);
        [Y,X] =  hist(vol(atoms>0),0:0.05:1);
        if num_std == 1
            Yall = (Y/((X(2)-X(1))*sum(atoms(:)>0)))';
        else
            Yall = [Yall (Y/((X(2)-X(1))*sum(atoms(:)>0)))'];   
        end 
    end
    max(Yall(:))
    bar(X,Yall)
    title(sprintf('Group-level compound stability (%s) -- REST experiment',strrep(label_scale,'_','\_')))
    axis([-0.1 1.1 0 10])
    file_out = [path_out 'rest_compound_stability_group_' label_scale '.pdf'];
    print(file_out,'-dpdf')
    close(hf)    
end

%% Histogram of group compound stability -- FIR experiment
clear
path_data = '/home/pbellec/database/BASC_FIR/';
path_out = '/home/pbellec/database/BASC_FIR/figures_sm/fig_stab_compound/';
list_std_noise = [0 2 4];
list_scales = [5 5 5; 10 10 10; 25 25 25; 50 50 50; 100 100 100 ; 200 200 200];
%list_scales = [5 5 5 ; 10 10 10; 50 50 50];
for num_sc = 1:length(list_scales)
    hf = figure ;
    label_std = cell([length(list_std_noise) 1]);
    for num_std = 1:length(list_std_noise)           
        label_scale = ['sci' num2str(list_scales(num_sc,1)) '_scg' num2str(list_scales(num_sc,2)) '_scf' num2str(list_scales(num_sc,3))];    
        label_std{num_std} = ['std' num2str(list_std_noise(num_std))];
        file_stability = [path_data 'stability_fir' filesep 'std_' num2str(list_std_noise(num_std)) filesep 'stability_group' filesep label_scale filesep 'compound_stability_map_group_' label_scale '.nii.gz'];    
        [hdr,vol] = niak_read_vol(file_stability);
        file_atoms = [path_data 'stability_fir' filesep 'std_' num2str(list_std_noise(num_std)) filesep  'atoms' filesep 'brain_atoms.nii.gz'];
        [hdr,atoms] = niak_read_vol(file_atoms);
        [Y,X] =  hist(vol(atoms>0),0:0.05:1);
        if num_std == 1
            Yall = (Y/((X(2)-X(1))*sum(atoms(:)>0)))';
        else
            Yall = [Yall (Y/((X(2)-X(1))*sum(atoms(:)>0)))'];   
        end 
    end
    max(Yall(:))    
    bar(X,Yall)
    title(sprintf('Group-level compound stability (%s) -- FIR experiment',strrep(label_scale,'_','\_')))
    axis([-0.1 1.1 0 10])
    file_out = [path_out 'fir_compound_stability_group_' label_scale '.pdf'];
    print(file_out,'-dpdf')
    close(hf)    
end


%% Histogram of intra-cluster group average stability -- FIR experiment
clear
path_data = '/home/pbellec/database/BASC_FIR/';
list_std_noise = [0 2 4];
%list_scales = [5 5 5; 10 10 10; 25 25 25; 50 50 50; 100 100 100];
list_scales = [5 5 5 ; 10 10 10; 50 50 50];
for num_sc = 1:length(list_scales)
figure 
label_std = cell([length(list_std_noise) 1]);
for num_std = 1:length(list_std_noise)           
    label_scale = ['sci' num2str(list_scales(num_sc,1)) '_scg' num2str(list_scales(num_sc,2)) '_scf' num2str(list_scales(num_sc,3))];    
    label_std{num_std} = ['std' num2str(list_std_noise(num_std))];
    file_stability = [path_data 'stability_fir_std_noise_' num2str(list_std_noise(num_std)) filesep 'stability_group' filesep 'stability_group_sci' num2str(list_scales(num_sc,1)) '.mat'];    
    data = load(file_stability);
    ind = find(data.nb_classes == list_scales(num_sc,2));
    opt_thresh.thresh = list_scales(num_sc,3);
    part = niak_threshold_hierarchy(data.hier{ind},opt_thresh);
    stab = niak_vec2mat(data.stab(:,ind));
    [sil,intra,inter] = niak_build_silhouette(stab,part,false);
    [Y,X] =  hist(intra,0:0.05:1);
    if num_std == 1
        Yall = (Y/((X(2)-X(1))*length(intra)))';
    else
        Yall = [Yall (Y/((X(2)-X(1))*length(intra)))'];   
    end 
end
bar(X,Yall)
title(sprintf('Group-level intra-cluster stability (%s) -- FIR experiment',strrep(label_scale,'_','\_')))
legend(label_std)
axis([-0.1 1.1 0 6])
end

%% Histogram of inter-cluster group average stability -- FIR experiment
clear
path_data = '/home/pbellec/database/BASC_FIR/';
list_std_noise = [0 2 4];
%list_scales = [5 5 5; 10 10 10; 25 25 25; 50 50 50; 100 100 100];
list_scales = [5 5 5 ; 10 10 10; 50 50 50];
for num_sc = 1:length(list_scales)
figure 
label_std = cell([length(list_std_noise) 1]);
for num_std = 1:length(list_std_noise)           
    label_scale = ['sci' num2str(list_scales(num_sc,1)) '_scg' num2str(list_scales(num_sc,2)) '_scf' num2str(list_scales(num_sc,3))];    
    label_std{num_std} = ['std' num2str(list_std_noise(num_std))];
    file_stability = [path_data 'stability_fir_std_noise_' num2str(list_std_noise(num_std)) filesep 'stability_group' filesep 'stability_group_sci' num2str(list_scales(num_sc,1)) '.mat'];    
    data = load(file_stability);
    ind = find(data.nb_classes == list_scales(num_sc,2));
    opt_thresh.thresh = list_scales(num_sc,3);
    part = niak_threshold_hierarchy(data.hier{ind},opt_thresh);
    stab = niak_vec2mat(data.stab(:,ind));
    [sil,intra,inter] = niak_build_silhouette(stab,part,false);
    [Y,X] =  hist(inter,0:0.05:1);
    if num_std == 1
        Yall = (Y/((X(2)-X(1))*length(intra)))';
    else
        Yall = [Yall (Y/((X(2)-X(1))*length(intra)))'];   
    end 
end
bar(X,Yall)
title(sprintf('Group-level inter-cluster stability (%s) -- FIR experiment',strrep(label_scale,'_','\_')))
legend(label_std)
axis([-0.1 1.1 0 6])
end

%% Histogram of group-level stability contrast -- FIR experiment
clear
path_data = '/home/pbellec/database/BASC_FIR/';
path_out = [path_data 'figures' filesep];
list_std_noise = [0 2 4];
%list_scales = [5 5 5; 10 10 10; 25 25 25; 50 50 50; 100 100 100];
list_scales = [5 5 5 ; 10 10 10; 50 50 50 ; 100 100 100; 200 200 200];
for num_sc = 1:length(list_scales)
figure 
label_std = cell([length(list_std_noise) 1]);
for num_std = 1:length(list_std_noise)           
    label_scale = ['sci' num2str(list_scales(num_sc,1)) '_scg' num2str(list_scales(num_sc,2)) '_scf' num2str(list_scales(num_sc,3))];    
    label_std{num_std} = ['std' num2str(list_std_noise(num_std))];
    file_stability = [path_data 'stability_fir_rest_std_noise' filesep 'std_' num2str(list_std_noise(num_std)) filesep 'stability_group' filesep 'stability_group_sci' num2str(list_scales(num_sc,1)) '.mat'];    
    data = load(file_stability);
    ind = find(data.nb_classes == list_scales(num_sc,2));
    opt_thresh.thresh = list_scales(num_sc,3);
    part = niak_threshold_hierarchy(data.hier{ind},opt_thresh);
    stab = niak_vec2mat(data.stab(:,ind));
    [sil,intra,inter] = niak_build_silhouette(stab,part,false);
    [Y,X] =  hist(intra-inter,0:0.05:1);
    if num_std == 1
        Yall = (Y/((X(2)-X(1))*length(intra)))';
    else
        Yall = [Yall (Y/((X(2)-X(1))*length(intra)))'];   
    end 
end
bar(X,Yall)
title(sprintf('Group-level stability contrast (%s) -- FIR experiment',strrep(label_scale,'_','\_')))
legend(label_std)
axis([-0.1 1.1 0 8])
print([path_out 'fir_fig_group_contrast_rest_' label_scale '.pdf'],'-dpdf');
end

%% Histogram of group-level tests on the FIR -- FIR experiment
clear
path_data = '/home/pbellec/database/BASC_FIR/';
list_std_noise = [0 2 4];
type_test = 'pce'; % 'pce' or 'fdr'
type_fir = 'fir'; % 'fir' or 'diff'
nb_samps = 10000;
%list_scales = [5 5 5; 10 10 10; 25 25 25; 50 50 50; 100 100 100];
list_scales = [5 5 5 ; 10 10 10; 50 50 50 ; 100 100 100; 200 200 200];
for num_sc = 1:length(list_scales)
    figure 
    label_std = cell([length(list_std_noise) 1]);
    for num_std = 1:length(list_std_noise)  
        num_std
        label_scale = ['sci' num2str(list_scales(num_sc,1)) '_scg' num2str(list_scales(num_sc,2)) '_scf' num2str(list_scales(num_sc,3))];    
        label_std{num_std} = ['std' num2str(list_std_noise(num_std))];
        fir_name = ['test_' type_fir];
        file_fdr = [path_data 'stability_fir_rest' filesep 'std_' num2str(list_std_noise(num_std)) filesep 'stability_group' filesep label_scale filesep 'fdr_group_average_' label_scale '.mat'];    
        data = load(file_fdr);    
        [Y,X] =  hist(data.(fir_name).(type_test)(:),0:0.1:1);    
        if num_std == 1
            Yall = (Y/((X(2)-X(1))*length(data.(fir_name).(type_test)(:))))';
        else
            Yall = [Yall (Y/((X(2)-X(1))*length(data.(fir_name).(type_test)(:))))'];   
        end 
    end
    bar(X,Yall)
    title(sprintf('Group-level FIR (%s, %s, %s) -- REST experiment',type_test,type_fir,strrep(label_scale,'_','\_')))
    legend(label_std)
    axis([-0.1 1.1 0 1.5])
end

%% Histogram of group-level tests on the differences between FIR -- FIR experiment
clear
path_data = '/home/pbellec/database/BASC_FIR/';
path_out = '/home/pbellec/database/BASC_FIR/figures_sm/fig_pce/';
list_std_noise = [0 2 4];
type_test = 'pce'; % 'pce' or 'fdr'
type_fir = 'diff'; % 'fir' or 'diff'
nb_samps = 10000;
%list_scales = [5 5 5; 10 10 10; 25 25 25; 50 50 50; 100 100 100];
list_scales = [5 5 5 ; 10 10 10; 50 50 50 ; 100 100 100; 200 200 200];

for num_sc = 1:length(list_scales)
    label_std = cell([length(list_std_noise) 1]);
    hf = figure;
    for num_std = 1:length(list_std_noise)          
        num_std
        label_scale = ['sci' num2str(list_scales(num_sc,1)) '_scg' num2str(list_scales(num_sc,2)) '_scf' num2str(list_scales(num_sc,3))];    
        label_std{num_std} = ['std' num2str(list_std_noise(num_std))];
        fir_name = ['test_' type_fir];
        file_fdr = [path_data 'stability_fir' filesep 'std_' num2str(list_std_noise(num_std)) filesep 'stability_group' filesep label_scale filesep 'fdr_group_average_' label_scale '.mat'];    
        data = load(file_fdr);    
        [Y,X] =  hist(data.(fir_name).(type_test)(:),0:0.1:1);    
        if num_std == 1
            Yall = (Y/((X(2)-X(1))*length(data.(fir_name).(type_test)(:))))';
        else
            Yall = [Yall (Y/((X(2)-X(1))*length(data.(fir_name).(type_test)(:))))'];   
        end 
        fprintf('Group-level FIR (%s, %s, %s) -- REST experiment, min FDR: %1.3f\n',type_test,type_fir,strrep(label_scale,'_','\_'),min(data.(fir_name).fdr(:)));
    end
    bar(X,Yall)
    title(sprintf('Group-level FIR (%s, %s, %s) -- REST experiment',type_test,type_fir,strrep(label_scale,'_','\_')))
    %legend(label_std)
    axis([-0.1 1.1 0 1.5])
    print([path_out type_test '_' type_fir '_' strrep(label_scale,'_','\_') '.pdf'],'-dpdf')
    close(hf)
end

%% Histogram of group-level tests on the differences between FIR -- REST (control) experiment
clear
path_data = '/home/pbellec/database/BASC_FIR/';
path_out = '/home/pbellec/database/BASC_FIR/figures_sm/fig_pce/';
list_std_noise = [0 2 4];
type_test = 'pce'; % 'pce' or 'fdr'
type_fir = 'diff'; % 'fir' or 'diff'
nb_samps = 10000;
%list_scales = [5 5 5; 10 10 10; 25 25 25; 50 50 50; 100 100 100];
list_scales = [5 5 5 ; 10 10 10; 50 50 50 ; 100 100 100; 200 200 200];

for num_sc = 1:length(list_scales)
    label_std = cell([length(list_std_noise) 1]);
    hf = figure;
    for num_std = 1:length(list_std_noise)          
        num_std
        label_scale = ['sci' num2str(list_scales(num_sc,1)) '_scg' num2str(list_scales(num_sc,2)) '_scf' num2str(list_scales(num_sc,3))];    
        label_std{num_std} = ['std' num2str(list_std_noise(num_std))];
        fir_name = ['test_' type_fir];
        file_fdr = [path_data 'stability_fir_rest' filesep 'std_' num2str(list_std_noise(num_std)) filesep 'stability_group' filesep label_scale filesep 'fdr_group_average_' label_scale '.mat'];    
        data = load(file_fdr);    
        [Y,X] =  hist(data.(fir_name).(type_test)(:),0:0.1:1);    
        if num_std == 1
            Yall = (Y/((X(2)-X(1))*length(data.(fir_name).(type_test)(:))))';
        else
            Yall = [Yall (Y/((X(2)-X(1))*length(data.(fir_name).(type_test)(:))))'];   
        end 
        fprintf('Group-level FIR (%s, %s, %s) -- REST experiment, min FDR: %1.3f\n',type_test,type_fir,strrep(label_scale,'_','\_'),min(data.(fir_name).fdr(:)));
    end
    bar(X,Yall)
    title(sprintf('Group-level FIR (%s, %s, %s) -- REST experiment',type_test,type_fir,strrep(label_scale,'_','\_')))
    %legend(label_std)
    axis([-0.1 1.1 0 1.5])
    print([path_out type_test '_' type_fir '_' strrep(label_scale,'_','\_') '.pdf'],'-dpdf')
    close(hf)
end
