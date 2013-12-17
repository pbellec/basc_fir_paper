% This is a script to demonstrate the usage of :
% NIAK_BRICK_CLUSTERING
%
% SYNTAX:
% Just type in NIAK_DEMO_BRICK_CLUSTERING
%
% OUTPUT:
%
% This script will clear the workspace !!
% It will derive a parcelation of the gray matter in the stereotaxic space
% common for the two subjects and two tasks of the "data demo", and it will
% extract the time series of these regions for each functional run.
%
% Note that the path to access the demo data is stored in a variable
% called GB_NIAK_PATH_DEMO defined in the NIAK_GB_VARS script.
% 
% The demo database exists in multiple file formats. By default, it is
% using 'minc2' files. You can change that by changing the variable
% GB_NIAK_FORMAT_DEMO in the file NIAK_GB_VARS.
%
% Copyright (c) Pierre Bellec, Montreal Neurological Institute, 2008.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : medical imaging, temporal filtering, fMRI

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
niak_gb_vars
gb_niak_path_demo = '/media/hda3/database/demo_niak/';

%% Setting input files
switch gb_niak_format_demo

    case {'minc1','minc2'} % If data are in minc2 format

        files_in.hom_roi = cat(2,gb_niak_path_demo,filesep,'fmri_preprocess/subject1/resample_vol/hom_roi_vol.mnc');
        files_in.tseries{1} = cat(2,gb_niak_path_demo,filesep,'fmri_preprocess/subject1/resample_vol/hom_roi_tseries_func_motor_subject1_mc_a_f_s_res.mat');
    
    otherwise 
        
        error('niak:demo','%s is an unsupported file format for this demo. See help to change that.',gb_niak_format_demo)
        
end

%% Setting output files
files_out.clusters = '';
files_out.tseries = '';
files_out.figure_tseries = '';

%% Setting options
opt.type_clustering = 'kmeans';
opt.clustering.nb_classes = 15;
opt.clustering.nb_iter = 10;
opt.clustering.type_death = 'none';
opt.flag_test = false; 

[files_in,files_out,opt] = niak_brick_clustering(files_in,files_out,opt);

%% Note that opt.interpolation_method has been updated, as well as files_out
