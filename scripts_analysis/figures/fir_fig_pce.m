
%% Histogram of group-level tests on FIR -- FIR experiment
clear
path_data = '/home/pbellec/database/BASC_FIR/';
path_out = '/home/pbellec/database/BASC_FIR/figures_sm/fig_pce/';
list_std_noise = [0 2 4];
type_test = 'pce'; % 'pce' or 'fdr'
type_fir  = 'fir'; % 'fir' or 'diff'
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
        [Y,X] =  hist(data.(fir_name).(type_test)(:),0:0.05:1);    
        if num_std == 1
            Yall = (Y/((X(2)-X(1))*length(data.(fir_name).(type_test)(:))))';
        else
            Yall = [Yall (Y/((X(2)-X(1))*length(data.(fir_name).(type_test)(:))))'];   
        end 
        fprintf('Group-level FIR (%s, %s, %s) -- FIR experiment, min FDR: %1.3f\n',type_test,type_fir,strrep(label_scale,'_','\_'),min(data.(fir_name).fdr(:)));
    end
    bar(X,Yall)
    title(sprintf('Group-level FIR (%s, %s, %s) -- FIR experiment',type_test,type_fir,strrep(label_scale,'_','\_')))
    %legend(label_std)
    axis([-0.1 1.1 0 15])
    print([path_out type_test '_fir_' type_fir '_' label_scale '.pdf'],'-dpdf')
    close(hf)
end


%% Histogram of group-level tests on FIR -- REST experiment
clear
path_data = '/home/pbellec/database/BASC_FIR/';
path_out = '/home/pbellec/database/BASC_FIR/figures_sm/fig_pce/';
list_std_noise = [0 2 4];
type_test = 'pce'; % 'pce' or 'fdr'
type_fir  = 'fir'; % 'fir' or 'diff'
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
        [Y,X] =  hist(data.(fir_name).(type_test)(:),0:0.05:1);    
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
    axis([-0.1 1.1 0 15])
    print([path_out type_test '_rest_' type_fir '_' label_scale '.pdf'],'-dpdf')
    close(hf)
end

%% Histogram of group-level tests on the differences between FIR -- FIR experiment
clear
path_data = '/home/pbellec/database/BASC_FIR/';
path_out = '/home/pbellec/database/BASC_FIR/figures_sm/fig_pce/';
list_std_noise = [0 2 4];
type_test = 'pce'; % 'pce' or 'fdr'
type_fir  = 'diff'; % 'fir' or 'diff'
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
        [Y,X] =  hist(data.(fir_name).(type_test)(:),0:0.05:1);    
        if num_std == 1
            Yall = (Y/((X(2)-X(1))*length(data.(fir_name).(type_test)(:))))';
        else
            Yall = [Yall (Y/((X(2)-X(1))*length(data.(fir_name).(type_test)(:))))'];   
        end 
        fprintf('Group-level FIR (%s, %s, %s) -- FIR experiment, min FDR: %1.3f\n',type_test,type_fir,strrep(label_scale,'_','\_'),min(data.(fir_name).fdr(:)));
    end
    bar(X,Yall)
    title(sprintf('Group-level FIR (%s, %s, %s) -- FIR experiment',type_test,type_fir,strrep(label_scale,'_','\_')))
    %legend(label_std)
    axis([-0.1 1.1 0 15])
    print([path_out type_test '_fir_' type_fir '_' label_scale '.pdf'],'-dpdf')
    close(hf)
end

%% Histogram of group-level tests on the differences between FIR -- REST (control) experiment
clear
path_data = '/home/pbellec/database/BASC_FIR/';
path_out = '/home/pbellec/database/BASC_FIR/figures_sm/fig_pce/';
list_std_noise = [0 2 4];
type_test = 'pce'; % 'pce' or 'fdr'
type_fir  = 'diff'; % 'fir' or 'diff'
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
        [Y,X] =  hist(data.(fir_name).(type_test)(:),0:0.05:1);    
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
    axis([-0.1 1.1 0 15])
    print([path_out type_test '_rest_' type_fir '_' label_scale '.pdf'],'-dpdf')
    close(hf)
end
