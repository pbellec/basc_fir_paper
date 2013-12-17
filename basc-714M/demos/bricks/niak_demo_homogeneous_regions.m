% This is a script to demonstrate the usage of :
% NIAK_BRICK_HOMOGENEOUS_REGIONS
%
% SYNTAX:
% Just type in NIAK_BRICK_HOMOGENEOUS_REGIONS
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

        files_in.fmri{1} = cat(2,gb_niak_path_demo,filesep,'fmri_preprocess/subject1/resample_vol/func_motor_subject1_mc_a_f_s_res.mnc');
        %files_in.fmri{2} = cat(2,gb_niak_path_demo,filesep,'fmri_preprocess/subject1/resample_vol/func_rest_subject1_mc_a_f_s_res.mnc');
        %files_in.fmri{3} = cat(2,gb_niak_path_demo,filesep,'fmri_preprocess/subject2/resample_vol/func_motor_subject2_mc_a_f_s_res.mnc');
        %files_in.fmri{4} = cat(2,gb_niak_path_demo,filesep,'fmri_preprocess/subject2/resample_vol/func_rest_subject2_mc_a_f_s_res.mnc');
        files_in.mask = cat(2,gb_niak_path_demo,filesep,'roi_aal_res.mnc');       
    
    otherwise 
        
        error('niak:demo','%s is an unsupported file format for this demo. See help to change that.',gb_niak_format_demo)
        
end

%% Setting output files
files_out.hom_roi = '';
files_out.tseries = '';

%% Setting options
opt.thre_size = 30;
opt.flag_size = 1;
opt.flag_test = 0; % This is not a test, the slice timing is actually performed

[files_in,files_out,opt] = niak_brick_homogeneous_regions(files_in,files_out,opt);

%% Note that opt.interpolation_method has been updated, as well as files_out
