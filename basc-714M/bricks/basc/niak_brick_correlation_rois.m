function [files_in,files_out,opt] = niak_brick_correlation_rois(files_in,files_out,opt)
% Extract the temporal correlation matrix for ROIs in a 3D+t fMRI dataset.
%
% SYNTAX:
% [FILES_IN,FILES_OUT,OPT] = NIAK_BRICK_CORRELATION_ROIS(FILES_IN,FILES_OUT,OPT)
%
% _________________________________________________________________________
% INPUTS:
%
% FILES_IN        
%   (structure) with the following fields : 
%
%   FMRI 
%       (cell of string) A collection of fMRI datasets. They need to be all 
%       in the same world and voxel space. Alternatively, the input files
%       can be .mat files with a variable TSERIES which contains the
%       regional time series in columns. 
%
%   MASK 
%       (string, default 'gb_niak_omitted') A mask of regions of interest
%       (region I is defined by MASK==I). This field is mandatory
%       if fMRI datasets are used in FILES_IN.FMRI, and is not used if
%       .mat files are used instead.
%
% FILES_OUT
%   (string, default {<BASE_FMRI>_<BASE_MASK>.mat})  
%   A .mat file with the following variables :
%
%   TSERIES 
%       (2D array) the time series of the ROIs concatenated for all fMRI 
%       datasets. TSERIES(:,I) is the time series of region I. This
%       variable will be present only if OPT.FLAG_TSERIES is true (see
%       below).
%
%   TIMING
%       (vector) TIMING(T) is the recording time of TSERIES(T). This
%       variable will be present only if OPT.FLAG_TSERIES is true (see
%       below).
%
%   MAT_R
%       (vector or matrix) the correlation matrix between regional time
%       series. The matrix is vectorized if OPT.FLAG_VEC is true (see
%       below).
%
% OPT           
%   (structure) with the following fields.  
%
%   FLAG_TSERIES
%       (boolean, default false) if FLAG_TSERIES is true, the TSERIES
%       and variable is saved in the outputs. 
%
%   FLAG_VEC
%       (boolean, default true) If FLAG_VEC is true, use NIAK_MAT2VEC to
%       vectorize the matrix (only the upper non-diagonal elements are
%       stored). Use NIAK_VEC2MAT to get the square form back.
%
%   FOLDER_OUT 
%       (string, default: path of FILES_IN.MASK) If present, all default 
%       outputs will be created in the folder FOLDER_OUT. The folder 
%       needs to be created beforehand.
%
%   FLAG_VERBOSE 
%       (boolean, default 1) if the flag is 1, then the function prints 
%       some infos during the processing.
%
%   FLAG_TEST 
%       (boolean, default 0) if FLAG_TEST equals 1, the brick does not 
%       do anything but update the default values in FILES_IN, FILES_OUT 
%       and OPT.
%           
% _________________________________________________________________________
% OUTPUTS:
%
% The structures FILES_IN, FILES_OUT and OPT are updated with default
% valued. If OPT.FLAG_TEST == 0, the specified outputs are written.
%              
% _________________________________________________________________________
% SEE ALSO:
% NIAK_BUILD_CORRELATION, NIAK_BUILD_TSERIES
%
% _________________________________________________________________________
% COMMENTS
%
% Copyright (c) Pierre Bellec
%               Centre de recherche de l'institut de Gériatrie de Montréal
%               Département d'informatique et de recherche opérationnelle
%               Université de Montréal, 2010.
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : medical imaging, fMRI, time series, correlation

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialization and syntax checks %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Syntax
if ~exist('files_in','var')|~exist('files_out','var')
    error('fnak:brick','syntax: [FILES_IN,FILES_OUT,OPT] = NIAK_BRICK_CORRELATION_ROIS(FILES_IN,FILES_OUT,OPT).\n Type ''help niak_brick_correlation_rois'' for more info.')
end

%% Inputs
list_fields   = {'fmri' , 'mask'            };
list_defaults = {NaN    , 'gb_niak_omitted' };
files_in = psom_struct_defaults(files_in,list_fields,list_defaults);
[path_f,name_f,ext_f] = niak_fileparts(files_in.fmri{1});
flag_mat = strcmp(ext_f,'.mat');
if ~flag_mat && strcmp(files_in.mask,'gb_niak_omitted')
    error('Please specify FILES_IN.MASK')
end

%% Options
list_fields   = {'flag_tseries' , 'flag_vec' , 'flag_verbose' , 'flag_test' , 'folder_out' };
list_defaults = {false          , true       , true           , false       , ''           };
opt = psom_struct_defaults(opt,list_fields,list_defaults);

%% Check the output files structure
if ~ischar(files_out)
    error('FILES_OUT should be a string');
end

%% Building default output names
[path_f,name_f] = niak_fileparts(files_in.mask);
if strcmp(opt.folder_out,'')
    opt.folder_out = path_f;
end
if isempty(files_out)
    [path_t,name_t] = niak_fileparts(files_in.fmri{1});
    files_out = [opt.folder_out filesep name_t '_' name_f '.mat'];
end

%% If the test flag is true, stop here !
if opt.flag_test == 1
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% The core of the brick starts here %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if opt.flag_verbose
    msg = sprintf('Extracting regional time series and correlation');
    stars = repmat('*',[length(msg) 1]);
    fprintf('\n%s\n%s\n%s\n',stars,msg,stars);
end

%% Reading mask
if ~flag_mat
    if opt.flag_verbose
        fprintf('Reading mask %s ...\n',files_in.mask);
    end
    [hdr_mask,mask] = niak_read_vol(files_in.mask);
    mask = round(mask);
end

%% Reading time series
opt_tseries.correction.type = 'mean_var';
for num_f = 1:length(files_in.fmri)
    if opt.flag_verbose
        fprintf('Extracting time series in %s...\n',files_in.fmri{num_f});
    end
    if flag_mat
        data = load(files_in.fmri{num_f});
        if ~isfield(data,'tseries')
            error('I could not find the TSERIES variables in FILES_IN.FMRI')
        end
        tseries_tmp = data.tseries;
        nt = size(tseries_tmp,1);
        if isfield(data,'timing')
            timing_tmp = data.timing;
        else
            timing_tmp = (0:(nt-1))';
        end
    else
        [hdr,vol] = niak_read_vol(files_in.fmri{num_f}); % read fMRI data
        tr = hdr.info.tr;
        nt = size(vol,4);
        timing_tmp = ((0:(nt-1))*tr)';
        tseries_tmp = niak_build_tseries(vol,mask,opt_tseries); % extract the time series in the mask
    end
    if num_f == 1
	if ~flag_mat
	    [nx,ny,nz,nt] = size(vol);
        end
        timing = timing_tmp;
        tseries = tseries_tmp; 
    else
        if ~flag_mat&&((tr~=hdr.info.tr)||(nx~=size(vol,1))||(ny~=size(vol,2))||(nz~=size(vol,3)))
            error('All fMRI datasets should have the same TR and spatial resolution');
        end
        timing  = [timing ; timing_tmp];
        tseries = [tseries ; tseries_tmp]; % Concatenate the time series
    end    
end

%% Building the correlation matrix
if opt.flag_verbose
    fprintf('Building correlation matrix ...\n');
end
mat_r = niak_build_correlation(tseries,opt.flag_vec);

%% Save outputs
if opt.flag_verbose
    fprintf('Saving outputs in %s ...\n',files_out);
end
if opt.flag_tseries
    save(files_out,'mat_r','tseries','timing');
else
    save(files_out,'mat_r');
end
