function [pipeline,opt] = niak_demo_brick_fir(path_demo)
%
% _________________________________________________________________________
% SUMMARY NIAK_DEMO_BRICK_FIR
%
% This is a script to demonstrate the usage of :
% NIAK_PIPELINE_BASC
%
% SYNTAX:
% [] = NIAK_DEMO_BRICK_FIR(PATH_DEMO)
%
% _________________________________________________________________________
% INPUTS:
%
% PATH_DEMO
%       (string, default GB_NIAK_PATH_DEMO in the file NIAK_GB_VARS) 
%       the full path to the NIAK demo dataset in Talairach space. 
%       The dataset can be found in multiple file formats at the following 
%       address : 
%       http://www.bic.mni.mcgill.ca/users/pbellec/demo_niak_tal/
%
% _________________________________________________________________________
% OUTPUT
%
% The script will run a FIR estimation on the motor experiment for subject
% 1.
%
% _________________________________________________________________________
% COMMENTS
%
% The demo database exists in multiple file formats. NIAK looks into the demo 
% path and is supposed to figure out which format you are intending to use 
% by himself. 
%
% _________________________________________________________________________
% Copyright (c) Pierre Bellec, Montreal Neurological Institute, 2008.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : medical imaging, FIR, fMRI

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

niak_gb_vars

if ~exist('path_demo','var')
    path_demo = '';
end

if isempty(path_demo)
    path_demo = gb_niak_path_demo;
end

if ~strcmp(path_demo(end),filesep)
    path_demo = [path_demo filesep];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setting input/output files %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% In which format is the niak demo ?
format_demo = 'minc2';
if exist(cat(2,path_demo,'func_mask_group_stereonl.mnc'))
    format_demo = 'minc2';
elseif exist(cat(2,path_demo,'func_mask_group_stereonl.mnc.gz'))
    format_demo = 'minc1';
elseif exist(cat(2,path_demo,'func_mask_group_stereonl.nii.gz'))
    format_demo = 'nii';
end

switch format_demo
    
    case 'minc1' % If data are in minc1 format
        
        %% Subject 1
        files_in.fmri{1} = cat(2,path_demo,filesep,'func_motor_subject1_a_mc_f_p_res_s.mnc.gz');        

        %% Functional mask
        files_in.mask = cat(2,path_demo,filesep,'func_mask_group_stereonl.mnc.gz');
        
        %% Output
        files_out = cat(2,path_demo,filesep,'func_motor_subject1_fir.mnc.gz');
        
    case 'minc2' % If data are in minc1 format
        
        %% Subject 1
        files_in.fmri{1} = cat(2,path_demo,filesep,'func_motor_subject1_a_mc_f_p_res_s.mnc');       

        %% Functional mask
        files_in.mask = cat(2,path_demo,filesep,'func_mask_group_stereonl.mnc');
        
        %% Output
        files_out = cat(2,path_demo,filesep,'func_motor_subject1_fir.mnc');
        
    case 'nii' % If data are in nifti format
        
        %% Subject 1
        files_in.fmri{1} = cat(2,path_demo,filesep,'func_motor_subject1_a_mc_f_p_res_s.nii.gz');        
        
        %% Functional mask
        files_in.mask = cat(2,path_demo,filesep,'func_mask_group_stereonl.nii.gz');
                
        %% Output
        files_out = cat(2,path_demo,filesep,'func_motor_subject1_fir.nii');
        
    otherwise 
        
        error('niak:demo','%s is an unsupported file format for this demo. See help to change that.',format_demo)
        
end

files_in.timing{1} = cat(2,path_demo,filesep,'timing_motor.mat');
time_frames = (0:47)*2.33;
time_events = [43.98 ; 103.98];
opt.time_window = 4;
opt.time_sampling = 0.5;
save(files_in.timing{1},'time_frames','time_events');

niak_brick_fir(files_in,files_out,opt);
