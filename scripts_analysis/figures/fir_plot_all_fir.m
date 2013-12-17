
clear
close all
name = 'fdr_group_average_sci30_scg27_scf34_clust';     
scale = 34;
subscale = 4;        % nb clusters à l'échelle considérée (ne traite pas clust0.mat)
linewidth = 3;
background = [0.75 0.75 0.75]; % color of the background for non-significant responses
opt.ind_fir = [];
opt.flag_diff = true;
opt.flag_legend = false;
opt.flag_std = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for n = 1   %:subscale
    hf = figure;
    files_in = strcat(name,num2str(n),'.mat');
    load(strcat(name,num2str(n),'.mat'));
    [x,sizesubclust] =  size(test_fir.mean);                 
    
    ymaxtmp = max(test_fir.mean) + 1.5*max(test_fir.std); % added the 1.5 because of the '*' indicating significance
    ymintmp = min(test_fir.mean) - max(test_fir.std);
    ymaxtmp2 = max(ymaxtmp);
    ymintmp2 = min(ymintmp);
    if ymaxtmp2 < 0
        ymax = 0;
    else 
        ymax = ymaxtmp2 + 0.1;
    end
    if ymintmp2 > 0
        ymin = 0;
    else 
        ymin = ymintmp2 - 0.1;
    end
    axisvalues = [1 21];
    axisvalues(1,3) = ymin;
    axisvalues(1,4) = ymax;
    
    xtick = [10 20];
    ytick = [-0.9:0.3:0.9];
    ytick = round(10*ytick)/10;

    subplot(sizesubclust,sizesubclust,1+(sizesubclust-1)*sizesubclust);
    ha = gca;
    axis(axisvalues)
    set(ha,'xtick',xtick)
    set(ha,'ytick',ytick)
    set(ha,'linewidth',linewidth);
    for m = 1:sizesubclust
        subplot(sizesubclust,sizesubclust,m+(m-1)*sizesubclust);
        opt.ind_fir = m;
        opt.linewidth = linewidth;
        opt.flag_diff = false;
        opt.flag_std = true;
        opt.background = background;
        opt.axis = axisvalues;
        niak_brick_fig_fir(files_in,'',opt);
        ha = gca;
        set(ha,'xtick',[])
        set(ha,'ytick',[])
        set(ha,'visible','off')

        for mm = 2:sizesubclust
            if mm > m
                subplot(sizesubclust,sizesubclust,mm+(m-1)*sizesubclust);
                opt.flag_diff = true;
                opt.flag_std = true;
                opt.ind_fir(1,1) = m;
                opt.ind_fir(1,2) = mm;
                files_out = '';
                niak_brick_fig_fir(files_in,files_out,opt);
                ha = gca;
                set(ha,'xtick',[])
                set(ha,'ytick',[])
                set(ha,'visible','off')
            end
        end
    end
    files_out = strcat('scale',num2str(scale),'_subscale',num2str(subscale),'_clust',num2str(n),'.pdf');
    print(files_out,'-dpdf')
end
    