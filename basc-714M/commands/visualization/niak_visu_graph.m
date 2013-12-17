function hf = niak_visu_graph(graph,opt)
%
% _________________________________________________________________________
% SUMMARY NIAK_VISU_GRAPH
%
% Visualization of a graph
%
% SYNTAX :
% HF = NIAK_VISU_GRAPH(GRAPH,OPT)
%
% _________________________________________________________________________
% INPUTS :
%
% GRAPH
%       (square matrix size NB_VERTICES*NB_VERTICES) defines a colored
%       graph. Non-symmetric matrices result in a directed graph.
%
% OPT
%       (structure, optional) with the following fields:
%
%       COORD
%           (matrix size NB_VERTICES*NB_DIMENSIONS, default : depends on
%           TYPE_VISU)
%           Line K of COORD defines the spatial coordinates of vertex K.
%
%       LABELS_VERTICES
%           (string, default {'1',...,'N'}) the labels applied on each
%           vertex.
%
%       TYPE_VISU
%           (string, default '2D_polygon')
%           let the user specifies its method to represent the graph.
%           Available options :
%               '2D_polygon' : vertices are placed on a regular polygon in
%               two dimensions.
%
%       LIMITS
%           (vector, default [min max])
%           the min and max value for coding the colors of the vertices.
%
%       SIZE_WINDOW
%           (vector, 1*(2*NB_DIMENSIONS), default use the min/max of 
%           vertices coordinates)
%           The range of spatial coordinates
%           [XMIN XMAX YMIN YMAX [ZMIN ZMAX]]
%
%       FLAG_COLORBAR
%           (boolean, default 1) if the flag is 1, show a color bar.
%
% _________________________________________________________________________
% OUTPUTS :
%
% HF
%       (vector) HF is the handle of the figure.
%
% _________________________________________________________________________
% COMMENTS :
%
% Copyright (c) Pierre Bellec, McConnell Brain Imaging Center, Montreal
%               Neurological Institute, McGill University, 2008.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : graph, visualization

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setting up default options %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gb_name_structure = 'opt';
gb_list_fields    = {'coord' , 'labels_vertices' , 'type_visu'  , 'limits'                      , 'size_window' , 'flag_colorbar' };
gb_list_defaults  = {''      , {}                , '2D_polygon' , [min(graph(:)),max(graph(:))] , []            , 1               };
niak_set_defaults

nb_vert = size(graph,1);

% Parametres par defaut
if isempty(opt.labels_vertices)
    for num_v = 1:nb_vert
        opt.labels_vertices{num_v} = num2str(num_v);
    end
end
labels_vertices = opt.labels_vertices;

if isempty(coord)
    
    switch type_visu
        
        case '2D_polygon'
            
            coord = sub_polygon(nb_vert);
            opt.coord = coord;
            
        otherwise
            
            error('%s is an unknown type of visualization',opt.type_visu);
    end
end

if isempty(size_window)
    minw = min(coord,[],1);
    maxw = max(coord,[],1);
    if any(minw<0)
        minw(minw<0) = 1.2*minw(minw<0);
    end
    if any(minw>0)
        minw(minw>0) = 0.8*minw(minw>0);
    end
    if any(maxw<0)
        maxw(maxw<0) = 0.8*maxw(maxw<0);
    end
    if any(maxw>0)
        maxw(maxw>0) = 1.2*maxw(maxw>0);
    end
    size_window = [minw(:)' ; maxw(:)'];
    size_window = size_window(:);
    opt.size_window = size_window;
end

maxi = opt.limits(1);
mini = opt.limits(2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Hard-coded parameters  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
max_trait=4;
max_couleur=100;
font_size_label = 14;
codage_trait = 1;
rapport_couleur=max_couleur/(maxi-mini);
couleurs=colormap(jet(max_couleur)); % Palette topographique
if (codage_trait)
    rapport_trait=max_trait/(maxi-mini);
    trait = 6;
else
    trait=max_trait;
end
diff = graph==graph';
flag_sym = min(diff(:));

%%%%%%%%%%%%%%%%%%%%%%%%
%% Plotting the graph %%
%%%%%%%%%%%%%%%%%%%%%%%%

hf = gcf;
hold on;
noeuds_x = coord(:,1);
noeuds_y = coord(:,2);
noeuds_z = coord(:,3);

%% The edges ...
for j=1:nb_vert
    for k=1:nb_vert
        
        indCol=ceil((abs(graph(j,k))-mini)*rapport_couleur);
        if indCol<1
            indCol=1;
        end
        if indCol>max_couleur
            indCol=max_couleur;
        end
        couleur=couleurs(indCol,:);
                
        if ~flag_sym || (j<k)
            if graph(j,k)>0
                plot3(noeuds_x([j,k]),noeuds_y([j,k]),noeuds_z([j,k]),'Color',couleur,'LineWidth',trait,'MarkerEdgeColor','k');
            elseif graph(j,k)<0
                plot3(noeuds_x([j,k]),noeuds_y([j,k]),noeuds_z([j,k]),'--','Color',couleur,'LineWidth',trait,'MarkerEdgeColor','k');
            end
        end
        if ~flag_sym
            plot3(noeuds_x([j]),noeuds_y([j]),noeuds_z([j]),'Color',couleur,'LineWidth',trait,'Marker','>');
        end

    end
end

%% The vertices
for num_region = 1:nb_vert

    indCol=ceil((abs(graph(num_region,num_region))-mini)*rapport_couleur);
    if indCol<1
        indCol=1;
    end
    if indCol>max_couleur
        indCol=max_couleur;
    end
    couleur=couleurs(indCol,:);

    plot3(noeuds_x(num_region),noeuds_y(num_region),noeuds_z(num_region),'o',...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',couleur,...
        'MarkerSize',15);

end

%% The labels
ymax = max(noeuds_y);
ymin = min(noeuds_y);

for j=1:length(opt.labels_vertices)
    text(noeuds_x(j),noeuds_y(j)-(ymax-ymin)/15,noeuds_z(j),char(opt.labels_vertices{j}),'FontSize',font_size_label,'FontWeight','bold','Color',[0 0 0]);
end

grid on;
hold off;

flag_2d = min(coord(1,3)==coord(:,3));
if flag_2d
    axis(opt.size_window(1:4));
else
    axis(opt.size_window);
end

if flag_colorbar
    colorbar
end

function [coord,sizew] = sub_polygon(nb_regions);

if nb_regions ~=4
    dzeta=exp(i*2*pi/nb_regions);
  
    coord(:,1) = real(dzeta.^((1:nb_regions)-1))';
    coord(:,2) = imag(dzeta.^((1:nb_regions)-1))';
    coord(:,3) = 0;
    sizew = [-1 1 -1 1 0 1];
else
    coord = [-1 1 0; 1 1 0; -1 -1 0; 1 -1 0];
    sizew = [-1.2 1.2 -1.2 1.2 0 1];
end