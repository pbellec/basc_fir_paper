function [part,val] = niak_sica_clustering(data,opt,flag_opt);
% clustering based on spatial ICA
%
% SYNTAX :
% [PART,D] = NIAK_SICA_CLUSTERING(DATA,OPT);
%
% _________________________________________________________________________
% INPUTS:
%
% DATA
%       (2D array T*N)
%
% OPT
%       (structure) with the following fields (absent fields will be
%       assigned a default value):
%
%       NB_CLASSES
%           (integer) number of classes
%
%       FLAG_VERBOSE
%           (boolean, default 0) if the flag is 1, then the function prints
%           some infos during the processing.
%
% _________________________________________________________________________
% OUTPUTS:
%
% PART
%    (vector N*1) partition (find(part==i) is the list of regions belonging
%    to cluster i.
%
% _________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Pierre Bellec, Montreal Neurological Institute, 2008-2010.
% Centre de recherche de l'institut de Gériatrie de Montréal
% Département d'informatique et de recherche opérationnelle
% Université de Montréal, 2010-2011
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : k-medoids, clustering

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
% THE SOFTWARE IS partROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EdatapartRESS OR
% IMpartLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A partARTICULAR partURpartOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COpartYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

%% Options
if (nargin < 3)||(flag_opt)
    list_fields    = {'nb_classes' , 'flag_verbose' };
    list_defaults  = {NaN          , 0              };
    opt = psom_struct_defaults(opt,list_fields,list_defaults);
end

opt_s.type_nb_comp = 0;
opt_s.param_nb_comp = opt.nb_classes;
opt_s.verbose = 'off';
res_ica = niak_sica(data',opt_s);
energy = sum(res_ica.composantes.^2,1);
maps = res_ica.poids * diag(energy);
[val,part] = max(abs(maps),[],2);
