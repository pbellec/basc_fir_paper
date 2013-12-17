function [] = niak_boxplot(data,opt)
% Make a boxplot
%
% SYNTAX:
% NIAK_BOXPLOT(DATA,OPT)
%
% _________________________________________________________________________
% INPUTS:
%
% DATA
%   (cell of vectors or array) DATA{S} is the vector of observations for 
%   box plot #S. Alternatively, if DATA is an array, DATA(:,S) is the
%   vector of observations for box plot #S. 
%
% OPT
%   (structure, optional) with the following options :
%
%   PERC_BOX
%       (vector, default [0.25 0.75]) the percentiles for the bottom and
%       top of the box
%
%   PERC_WHISKER
%       (vector, default [0.01 0.99]) the percentiles for the bottom and
%       top of the whiskers.
%
%   COLOR_BOX
%       (string, default 'k') set the color of the box (see PLOT)
%
%   COLOR_WHISKER
%       (string, default 'k') set the color of the whiskers (see PLOT)
%
%   COLOR_MEDIAN
%       (string, default 'r') set the color of the median line (see PLOT)
%
% _________________________________________________________________________
% OUTPUTS:
%
% A boxplot representation of data.
%
% _________________________________________________________________________
% SEE ALSO:
%
% _________________________________________________________________________
% COMMENTS:
% 
% If DATA{S} has N values, the n value is associated with the n/(N+1)
% percentile. Percentiles that are not exactly of the form n/(N+1) are
% estimated by linear interpolation. Percentiles that are below the min or
% above the max of DATA{S} are associated with the min or max. 
%
% Quick example :
% data{1} = randn([100 1]);
% data{2} = randn([50 1])+3;
% niak_boxplot(data);
%
% Copyright (c) Pierre Bellec, 2011
% Centre de recherche de l'institut de Gériatrie de Montréal
% Département d'informatique et de recherche opérationnelle
% Université de Montréal
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : boxplot, statistics

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

%% Set defaults
list_fields   = {'perc_box'  , 'perc_whisker' , 'color_box' , 'color_whisker' , 'color_median' };
list_defaults = {[0.25 0.75] , [0.01 0.99]    , 'k'         , 'k'             , 'r'            };
if nargin < 2
    opt = psom_struct_defaults(struct(),list_fields,list_defaults);
else
    opt = psom_struct_defaults(opt,list_fields,list_defaults);
end

if length(opt.perc_box)~=2
    error('OPT.PERC_BOX should have two elements');
end

if length(opt.perc_whisker)~=2
    error('OPT.PERC_WHISKER should have two elements');
end

% If DATA has been entered as an array, convert to cell
if ~iscell(data)
    data_bis = cell([size(data,2) 1]);
    for num_c = 1:size(data,2)
        data_bis{num_c} = data(:,num_c);
    end
    niak_boxplot(data_bis,opt);
    return
end

%% Get percentiles
nb_box = length(data);
list_perc = [opt.perc_box(:) ; opt.perc_whisker(:) ; 0.5];
perc = cell([nb_box 1]);
for num_b = 1:nb_box
    perc{num_b} = sub_percentiles(data{num_b},list_perc);
end

%% Make boxplot
wb = 0.15; % hard-coded box width
ww = 0.1; % hardcoded whisker width
hold on
for num_b = 1:nb_box
    p = perc{num_b};    
    x = num_b;
    
    %% Whiskers
    plot([x ; x],[p(2) ; p(4)],opt.color_whisker); % upper whisker
    plot([x ; x],[p(3) ; p(1)],opt.color_whisker); % lower whisker   
    plot([x - ww ; x + ww],[p(4) ; p(4)],opt.color_whisker); % end of upper whisker
    plot([x - ww ; x + ww],[p(3) ; p(3)],opt.color_whisker); % end of lower whisker        
    
    %% Box
    plot([x - wb ; x + wb],[p(1) ; p(1)],opt.color_box); % bottom of the box
    plot([x - wb ; x + wb],[p(2) ; p(2)],opt.color_box); % top of the box    
    plot([x - wb ; x - wb],[p(1) ; p(2)],opt.color_box); % left of the box
    plot([x + wb ; x + wb],[p(1) ; p(2)],opt.color_box); % right of the box
    
    %% median 
    plot([x - wb ; x + wb],[p(5) ; p(5)],opt.color_median); % bottom of the box
    
end

%%%%%%%%%%%%%%%%%
%% SUBFUNCTION %%
%%%%%%%%%%%%%%%%%

function perc = sub_percentiles(X,p)
% Build percentiles of a vector
nx = length(X);
X = sort(X);
percX = (1:nx)/(nx+1);
perc = zeros([length(p) 1]);
for num_p = 1:length(p)
    if p(num_p)<=percX(1)
        perc(num_p) = X(1);
    elseif p(num_p)>=percX(end)
        perc(num_p) = X(end);
    else
        perc(num_p) = interp1(percX,X,p(num_p),'linear');
    end
end