%
% _________________________________________________________________________
% SUMMARY NIAK_DEMO_MEASURE
%
% This is a script to demonstrate how to perform measure estimation over a
% database
%
% SYNTAX:
% Just type in NIAK_DEMO_MEASURE
%
% _________________________________________________________________________
% OUTPUT
%
% The script will use NIAK_DEMO_DATA to generate an example dataset, and
% will generate multiple measure estimation
%
% _________________________________________________________________________
% COMMENTS
%
% NOTE 1
% This script will clear the workspace !!
%
% _________________________________________________________________________
% Copyright (c) Pierre Bellec, Montreal Neurological Institute, 2008.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : 

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
    
clear 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Simulating a dataset using a linear mixture model %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

niak_demo_data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Individual correlation matrices for right-handed males and right-handed females %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

opt_mes_R.measure_ind.type = 'correlation';
opt_mes_R.measure_ind.field_argin1 = 'tseries';

opt_mes_R.measure_group(1).type = 'copy';
opt_mes_R.measure_group(1).label = 'right-handed males';
opt_mes_R.measure_group(1).field_subset = {'gender','hand'};
opt_mes_R.measure_group(1).val_subset = {'M','R'};

opt_mes_R.measure_group(2).type = 'copy';
opt_mes_R.measure_group(2).label = 'right-handed females';
opt_mes_R.measure_group(2).field_subset = {'gender','hand'};
opt_mes_R.measure_group(2).val_subset = {'F','R'};

opt_mes_R.flag_vec = false;

mes_R = niak_build_measure(data,opt_mes_R);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Average correlation matrices for right-handed men and right-handed females %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

opt_mes_A.measure_ind.type = 'correlation';
opt_mes_A.measure_ind.field_argin1 = 'tseries';

opt_mes_A.measure_group(1).type = 'average';
opt_mes_A.measure_group(1).label = 'right-handed males';
opt_mes_A.measure_group(1).field_subset = {'gender','hand'};
opt_mes_A.measure_group(1).val_subset = {'M','R'};

opt_mes_A.measure_group(2).type = 'average';
opt_mes_A.measure_group(2).label = 'right-handed females';
opt_mes_A.measure_group(2).field_subset = {'gender','hand'};
opt_mes_A.measure_group(2).val_subset = {'F','R'};

opt_mes_A.flag_vec = true;

mes_A = niak_build_measure(data,opt_mes_A);
