% Extract the atoms and the associated average FIR on a resting-state run 
%
% SYNTAX:
% Just type in FIR_PIPELINE_ROI_REST
%
% _________________________________________________________________________
% OUTPUT
%
% _________________________________________________________________________
% COMMENTS
%
% NOTE 1
% This script will clear the workspace !!
%
% _________________________________________________________________________
% Copyright (c) Pierre Bellec, Montreal Neurological Institute, 2008-2010.
%               Centre de recherche de l'institut de Gériatrie de Montréal
%               Département d'informatique et de recherche opérationnelle
%               Université de Montréal, 2010-2011.
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : BASC, FIR, ROIs

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
path_data = '/home/pbellec/database/BASC_FIR/';
path_preprocess = [path_data 'fmri_preprocess/']; % Where to find the preprocessed datasets
path_timing = [path_data 'timing/']; % Where to find the timing files
path_out = [path_data 'fir_rois_rest/']; % Where to store the results

%% Setting input/output files 
list_subject = {'ALDR','ANBE','ANDA','BEDR2','FRHU','GUSM2','JECH','JELA','KABO','MAPA','PHMA','SELA','THCH','THVO','TRVO','VIAL','VIBE'};
nb_subject   = length(list_subject);

for num_s = 1:nb_subject
   subject                             = list_subject{num_s};
   files_in.data.(subject).fmri{1}     = [path_preprocess 'fmri' filesep 'fmri_' subject '_session1_run1.mnc.gz'];
   files_in.data.(subject).timing{1}   = [path_timing subject '_timing_rest.mat'];
   files_in.data.(subject).extra.none  = {};
end
files_in.mask = [path_preprocess 'quality_control' filesep 'group_coregistration' filesep 'func_mask_group_stereonl.mnc.gz'];
files_in.areas = [path_data 'roi_aal_3mm.mnc.gz'];% Options

%% FIR estimation options
opt.fir.type_norm     = 'fir';
opt.fir.time_norm     = 1;
opt.fir.time_window   = 20;
opt.fir.time_sampling = 1;

%% Pipeline options
opt.folder_out = path_out;
opt.flag_roi = true;

%% Run the pipeline
[pipeline,opt] = niak_pipeline_stability_fir(files_in,opt); 
