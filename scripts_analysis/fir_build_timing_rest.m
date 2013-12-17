%
% _________________________________________________________________________
% SUMMARY FIR_PIPELINE_BASC_REST
%
% Convert the timing of the original BASC-FIR experiment to a resting-state
% run.
%
% SYNTAX:
% Just type in FIR_PIPELINE_BASC_FINAL
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
% Copyright (c) Pierre Bellec, Montreal Neurological Institute, 2008.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : BASC, FIR, Orban, final analysis

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
fir_gb_vars

nb_subject = length(list_subject);
for num_s = 1:nb_subject
                
    clear onset keysSeq
    
    %% Subject file names    
    subject_id = list_subject{num_s};
    file_timing_O    = [path_data 'timing' filesep subject_id '_timing_O.mat']; % The raw onset times
    file_timing_rest = [path_data 'timing' filesep subject_id '_timing_rest.mat']; % The raw onset times
    load(file_timing_O)
    
    %% The raw timing
    fprintf('%2.1f - %2.1s -%2.1s \n',min(time_events(2:end)-time_events(1:end-1)),mean(time_events(2:end)-time_events(1:end-1)),max(time_events(2:end)-time_events(1:end-1)))   
    time_frames = (0:299)*2;
    time_events = mod(time_events,600-20);           
    save(file_timing_rest,'time_events','time_frames');
end

