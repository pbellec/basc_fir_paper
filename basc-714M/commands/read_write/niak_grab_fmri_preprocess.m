 function files = niak_grab_fmri_preprocess(path_data,opt)
% Grab files created by NIAK_PIPELINE_FMRI_PREPROCESS
%
% SYNTAX:
% FILES = NIAK_GRAB_FMRI_PREPROCESS(PATH_DATA,OPT)
%
% _________________________________________________________________________
% INPUTS:
%
% PATH_DATA
%   (string, default [pwd filesep], aka './') full path to the outputs of 
%   NIAK_PIPELINE_REGION_GROWING. There should be a file "brain_rois.EXT" 
%   where EXT can be .mnc or .nii possibly compressed (see GB_NIAK_ZIP_EXT 
%   in NIAK_GB_VARS.M for the extension, usually it is .gz). There should 
%   also be a collection of files named with the following pattern : 
%   tseries_rois_<SUBJECT>_run<I>.mat
%
% OPT
%   (structure, optional) with the following fields :
%
%   MAX_TRANSLATION
%       (scalar, default 3) the maximal transition (difference between two
%       adjacent volumes) in translation motion parameters within-run (in 
%       mm).
%
%   MAX_ROTATION
%       (scalar, default 3) the maximal transition (difference between two
%       adjacent volumes) in rotation motion parameters within-run (in 
%       degrees).
%
%   MIN_XCORR_FUNC
%       (scalar, default 0.5) the minimal accceptable XCORR measure of
%       spatial correlation between the individual mean functional volume 
%       in non-linear stereotaxic space and the population average.
%
%   MIN_XCORR_ANAT
%       (scalar, default 0.5) the minimal accceptable XCORR measure of
%       spatial correlation between the individual anatomical volume in
%       non-linear stereotaxic space and the population average.
%
%   EXCLUDE_SUBJECT
%       (cell of string, default {}) A list of labels of subjects that will
%       be excluded from the analysis.
%
%   INCLUDE_SUBJECT
%       (cell of string, default {}) if non-empty, a list of the labels of
%       subjects that will be included in the analysis. Ignored if empty.
%
%   TYPE_FILES
%       (string, default 'rest') how to format FILES. This depends of the
%       purpose of subsequent analysis. Available options :
%
%           'rest' : FILES is ready to feed into
%           NIAK_PIPELINE_STABILITY_REST.
%      
% _________________________________________________________________________
% OUTPUTS:
%
% FILES
%   (structure) the exact fields depend on OPT.TYPE_FILES. 
%
%   case 'rest' :
%
%       DATA
%           (structure) with the following fields :
%
%           <SUBJECT>
%               (cell of strings) a list of fMRI datasets, acquired for the 
%               same subject. The field names <SUBJECT> can be any arbitrary 
%               strings. The fMRI datasets are found in the 'fmri'
%               subfolder of PATH_DATA.
%
%       MASK
%           (string, default AREAS>0) a file name of a binary mask common 
%           to all subjects and runs. The mask is the file located in 
%           quality_control/group_coregistration/anat_mask_group_stereonl.<
%           ext>
%
% _________________________________________________________________________
% SEE ALSO:
% NIAK_PIPELINE_STABILITY_REST
%
% _________________________________________________________________________
% COMMENTS:
%
% This "data grabber" is designed to work with the pipelines mentioned in
% the "SEE ALSO" section, based on the output folder of 
% NIAK_PIPELINE_FMRI_PREPROCESS
%
% Copyright (c) Pierre Bellec
%               Centre de recherche de l'institut de Gériatrie de Montréal,
%               Département d'informatique et de recherche opérationnelle,
%               Université de Montréal, 2011.
% Maintainer : pbellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : clustering, stability, bootstrap, time series

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

%% Default path for the database
if (nargin<1)||isempty(path_data)
    path_data = [pwd filesep];
end

if ~strcmp(path_data(end),filesep)
    path_data = [path_data filesep];
end

%% Default options
list_fields   = { 'max_translation' , 'max_rotation' , 'min_xcorr_func' , 'min_xcorr_anat' , 'exclude_subject' , 'include_subject' , 'type_files' };
list_defaults = { 3                 , 3              , 0.5              , 0.5              , {}                , {}                , 'rest'       };
if nargin > 1
    opt = psom_struct_defaults(opt,list_fields,list_defaults);
else
    opt = psom_struct_defaults(struct(),list_fields,list_defaults);
end

%% Grab the list of subjects
path_qc = [path_data 'quality_control' filesep];
list_qc = dir(path_qc);
nb_subject = 0;
for num_q = 1:length(list_qc)
    if ~ismember(list_qc(num_q).name,{'group_motion','group_coregistration','.','..'})&list_qc(num_q).isdir
        nb_subject = nb_subject + 1;
        list_subject{nb_subject} = list_qc(num_q).name;
    end
end
mask_keep = false([nb_subject 1]);

%% check max motion
file_motion = [path_qc 'group_motion' filesep 'qc_motion_group.csv'];
[tab_motion,labx,laby] = niak_read_csv(file_motion);
for num_s = 1:nb_subject
    ind_s = find(ismember(labx,list_subject{num_s}));
    if ~isempty(ind_s)
    	tsl   = tab_motion(ind_s,2);
    	rot   = tab_motion(ind_s,1);
    	flag_keep = (tsl<opt.max_translation)&(rot<opt.max_rotation);
    	if ~flag_keep&isempty(opt.include_subject)
        	fprintf('Subject %s was excluded because of excessive motion\n',list_subject{num_s});
    	end
    	mask_keep(num_s) = flag_keep;
    else
	fprintf('I could not find subject %s for quality control of max motion (rotation)\n',list_subject{num_s});
    end
    
end

%% Check function coregistration
file_regf = [path_qc 'group_coregistration' filesep 'func_tab_qc_coregister_stereonl.csv'];
[tab_regf,labx,laby] = niak_read_csv(file_regf);
for num_s = 1:nb_subject
    ind_s = find(ismember(labx,list_subject{num_s}));
    corrf = tab_regf(ind_s,2);   
    flag_keep = (corrf>opt.min_xcorr_func);
    if ~flag_keep&isempty(opt.include_subject)
        fprintf('Subject %s was excluded because of poor functional coregistration\n',list_subject{num_s});
    end
    mask_keep(num_s) = mask_keep(num_s) & flag_keep;
end

%% Check anatomical coregistration
file_rega = [path_qc 'group_coregistration' filesep 'anat_tab_qc_coregister_stereonl.csv'];
[tab_rega,labx,laby] = niak_read_csv(file_rega);
for num_s = 1:nb_subject
    ind_s = find(ismember(labx,list_subject{num_s}));
    corrf = tab_rega(ind_s,2);    
    flag_keep = (corrf>opt.min_xcorr_anat);
    if ~flag_keep&isempty(opt.include_subject)
        fprintf('Subject %s was excluded because of poor anatomical coregistration\n',list_subject{num_s});
    end
    mask_keep(num_s) = mask_keep(num_s) & flag_keep;
end

%% User forces removing of a list of subject
mask_keep(ismember(list_subject,opt.exclude_subject)) = false;
for num_s = 1:length(opt.exclude_subject)
    fprintf('User manually forced the exclusion of subject %s \n',list_subject{num_s});
end

%% Select the subjects
if ~isempty(opt.include_subject)
    list_subject = opt.include_subject;
else
    list_subject = list_subject(mask_keep);    
end
nb_subject = length(list_subject);

%% generate file names
path_fmri = [path_data 'fmri' filesep];
files_fmri = dir(path_fmri);
files_fmri = {files_fmri.name};
for num_s = 1:nb_subject
    mask_s = ~cellfun('isempty',regexp(files_fmri,['^fmri_' list_subject{num_s} '_']));    
    if ~isempty(mask_s)
        if strcmp(opt.type_files,'rest')
            files_tmp = files_fmri(mask_s);
            files.data.(list_subject{num_s}) =cell([length(files_tmp) 1]);
            for num_f = 1:length(files_tmp)
                files.data.(list_subject{num_s}){num_f} = [path_fmri files_tmp{num_f}];
            end
        else
            error('%s is an unsupported type of output format for the files structure')            
            files_s = files_fmri(mask_s);
            [path_f,name_f,ext_f] = niak_fileparts(files_s{num_s});
            for num_f = 1:length(files_s)
                pos = regexp(name_f,'run\d$');
                if isempty(pos)
                    pos = regexp(name_f,'run\d\d$');
                elseif isempty(pos)
                    pos = regexp(name_f,'run\d\d$');
                end
            end
            session_name = name_f(length(['fmri_' list_subject{num_s} '_'])+1:(pos-2));
        end
    else
        error('I could not find any fMRI preprocessed datasets for subject %s',list_subject{num_s});        
    end
end
files.mask = [path_qc 'group_coregistration' filesep 'func_mask_group_stereonl.mnc.gz'];
