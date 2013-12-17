% This is a demo for NIAK_PIPELINE_REGION_GROWING
%
% SYNTAX:
% Just type in NIAK_DEMO_PIPELINE_REGION_GROWING
%
% _________________________________________________________________________
% OUTPUT
%
% It will apply a fixed-effect parcelation into a 25-50 voxels functional 
% subdivision of the AAL areas to two subjects in ~/data_demo/
%
% _________________________________________________________________________
% COMMENTS
%
% NOTE 1
% This script will clear the workspace !!
%
% NOTE 2
% Note that the path to access the demo data is stored in a variable
% called GB_NIAK_PATH_DEMO defined in the script NIAK_GB_VARS.
% 
% NOTE 3
% The demo database exists in multiple file formats.NIAK looks into the demo 
% path and is supposed to figure out which format you are intending to use 
% by himself.You can the format by changing the variable GB_NIAK_FORMAT_DEMO 
% in the script NIAK_GB_VARS.
% _________________________________________________________________________
% Copyright (c) Pierre Bellec, Montreal Neurological Institute, 2008.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : region growing, fMRI

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
niak_gb_basc

%% Setting input/output files
list_num_subject = [561 562];

%switch gb_niak_format_demo
    
     %case 'minc1' % If data are in minc1 format
     
     num_e = 1;
     for num_s = list_num_subject
         name_subj = sprintf('mni_%i',num_s);
         files_in.fmri{num_e} = [gb_basc_demo_path name_subj '_fmr_1_mc_a_f_p_res_s.mnc.gz'];
         opt.labels{num_e} = [name_subj];
         num_e = num_e+1;
     end
        
    %otherwise 
        
     %   error('niak:demo','%s is an unsupported file format for this demo. See help to change that.',gb_niak_format_demo)
        
%end

%% Options : Misc
opt.flag_test = false; 
opt.folder_out = [gb_basc_demo_path,filesep,'basc',filesep];

%% Options : PSOM
opt.psom.mode = 'session';
opt.psom.max_queued = 1;
opt.psom.mode_pipeline_manager = 'session';

%% Options : region growing
opt.ind_rois = [2001 2002]; 

pipeline = niak_pipeline_region_growing(files_in,opt);

%% Note that opt.interpolation_method has been updated, as well as files_out
