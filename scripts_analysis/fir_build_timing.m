% Extract the timing of events in the BASC-FIR analysis
%
% SYNTAX:
% Just type in FIR_BUILD_TIMING_FINAL
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
% NOTE 2
%  trois types d'événements ont été distingués. Les échecs vs les séquences
%  correctes d'abord. Les séquences "typiques" vs "atypiques" ensuite (on 
% exclut les séquences pour lesquelles le temps de préparation et/ou 
% d'exécution s'éloigne de plus de 1.96 un écart-type robuste (MAD) de la 
% médiane des essais réussis, cela étant fait sujet par sujet.
%
% _________________________________________________________________________
% Copyright (c) Pierre Bellec, 
% Centre de recherche de l'institut de Gériatrie de Montréal
% Département d'informatique et de recherche opérationnelle
% Université de Montréal, 2011
% Maintainer : pierre.bellec@criugm.qc.ca
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
    file_timing_raw = [path_data 'timing' filesep subject_id '_1.mat'];
    file_timing = [path_data 'timing' filesep subject_id '_timing.mat']; % The raw onset times
    file_timing_OK = [path_data 'timing' filesep subject_id '_timing_OK.mat']; % The onset times of successful trials    
    file_timing_O = [path_data 'timing' filesep subject_id '_timing_O.mat']; % The onset times of successful trials with normal preparation/execution time AND the others (in separate variables)
    load(file_timing_raw)
    
    %% The raw timing
    time_events = onset.prep';
    time_frames = (0:766)*2;
    save(file_timing,'time_events','time_frames');
    
    %% The timing of successfull sequences
    mask = ismember(keysSeq,[4     5     2     4     3     2     5     3],'rows');        
    time_events_failed = time_events(~mask);
    prep_failed = onset.prepDur(~mask)';
    seq_failed = onset.seqDur(~mask)';
    time_events = time_events(mask);   
    save(file_timing_OK,'time_events','time_frames');
    
    %% The mainstream events
    prep = onset.prepDur(mask)';
    seq = onset.seqDur(mask)';
    mask_p = (prep>=median(prep)-1.96*niak_mad(prep));
    mask_p = mask_p&(prep<=median(prep)+1.96*niak_mad(prep));
    mask_s = (seq>=median(seq)-1.96*niak_mad(seq));
    mask_s = mask_s&(seq<=median(seq)+1.96*niak_mad(seq));
    time_events_no = time_events(~(mask_s&mask_p));
    prep_no = prep(~(mask_s&mask_p));   
    seq_no = seq(~(mask_s&mask_p));   
    time_events = time_events(mask_s&mask_p);   
    prep = prep(mask_s&mask_p);   
    seq = seq(mask_s&mask_p);   
    fprintf('%s : %i/%i mainstream/correct sequences\n',list_subject{num_s},length(time_events),sum(mask));        
    save(file_timing_O,'time_events','time_frames','prep','seq','time_events_no','prep_no','seq_no','time_events_failed','prep_failed','seq_failed');
end

