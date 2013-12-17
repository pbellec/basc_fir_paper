% Select events for the final BASC_FIR database
%
% SYNTAX:
% This script is designed to be executed block by block
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

%% Init
clear
fir_gb_vars

%% Load behavioural data
for num_s = 1:length(list_subject)
                
    clear onset       
    subject = cat(2,'subject',num2str(num_s));    
    subject_id = list_subject{num_s};
    file_timing_raw = [path_data 'timing' filesep subject_id '_1.mat'];
    load(file_timing_raw)
    data(num_s) = load(file_timing_raw);
    if num_s == 1
        all_prep = zeros([length(onset.prepDur) length(list_subject)]);
        all_seq =  zeros([length(onset.prepDur) length(list_subject)]);
        
    end
    all_prep(:,num_s) = onset.prepDur;
    all_seq(:,num_s) = onset.seqDur;    
    
end

%% Make plots of raw events
figure
subplot(2,1,1)
boxplot(all_prep)
title('Preparation time');
set(gca,'XTick',1:length(list_subject))
set(gca,'XTickLabel',list_subject)
subplot(2,1,2)
boxplot(all_seq)
title('Sequence time')
set(gca,'XTickLabel',list_subject)
set(gca,'XTick',1:length(list_subject))
print('summary_behaviour_raw.pdf','-dpdf')

%% Table of correct sequences
mask = false(size(all_prep));
for num_s = 1:length(list_subject)
    mask(:,num_s) = ismember(data(num_s).keysSeq,[4     5     2     4     3     2     5     3],'rows');
    fprintf('%s : %1.2f percents correct sequences\n',list_subject{num_s},100*sum(mask(:,num_s))/size(mask,1));        
end

%% Make plots of correct events
all_prep_ok = all_prep(mask);
all_seq_ok = all_seq(mask);
labels = double(mask).*repmat(1:length(list_subject),[size(mask,1) 1]);
labels = labels(mask);
figure
subplot(2,1,1)
boxplot(all_prep_ok,labels)
title('Preparation time');
set(gca,'XTick',1:length(list_subject))
set(gca,'XTickLabel',list_subject)
subplot(2,1,2)
boxplot(all_seq_ok,labels)
title('Sequence time')
set(gca,'XTickLabel',list_subject)
set(gca,'XTick',1:length(list_subject))
print('summary_behaviour_ok.pdf','-dpdf')

%% Get rid of outliers
for num_s = 1:length(list_subject)
    med_prep(num_s) = median(all_prep_ok(labels==num_s));
    std_prep(num_s) = niak_mad(all_prep_ok(labels==num_s));
    med_seq(num_s) = median(all_seq_ok(labels==num_s));
    std_seq(num_s) = niak_mad(all_seq_ok(labels==num_s));
%     med_prep(num_s) = median(all_prep_ok);
%     std_prep(num_s) = niak_mad(all_prep_ok);
%     med_seq(num_s) = median(all_seq_ok);
%     std_seq(num_s) = niak_mad(all_seq_ok);
end
labels_o = labels;
for num_s = 1:num_s
    ind = find(labels==num_s);
    mask_tmp = (all_prep_ok(labels==num_s)>=med_prep(num_s)-1.96*std_prep(num_s))&(all_prep_ok(labels==num_s)<=med_prep(num_s)+1.96*std_prep(num_s));
    mask_tmp = mask_tmp & (all_seq_ok(labels==num_s)>=med_seq(num_s)-1.96*std_seq(num_s))&(all_seq_ok(labels==num_s)<=med_seq(num_s)+1.96*std_seq(num_s));
    labels_o(ind(~mask_tmp)) = 0;
end
for num_s = 1:length(list_subject)    
    fprintf('%s : %i/%i mainstream/correct sequences\n',list_subject{num_s},sum(labels_o==num_s),sum(labels==num_s));        
end
all_prep_o = all_prep_ok(labels_o>0);
all_seq_o = all_seq_ok(labels_o>0);
labels_o = labels_o(labels_o>0);

%% Make plots of mainstream events
figure
subplot(2,1,1)
boxplot(all_prep_o,labels_o)
title('Preparation time');
set(gca,'XTick',1:length(list_subject))
set(gca,'XTickLabel',list_subject)
subplot(2,1,2)
boxplot(all_seq_o,labels_o)
title('Sequence time')
set(gca,'XTickLabel',list_subject)
set(gca,'XTick',1:length(list_subject))
print('summary_behaviour_o.pdf','-dpdf')
%print('summary_behaviour_s.pdf','-dpdf')


%% Test
%med_all_prep = median(all_prep(:));
%med_prep_trim = zeros([length(list_id_subjects) 1]);
%perc = 0.5;
%nb_points = ceil(perc*size(all_prep,1));
%for num_p = 1:nb_points
%    med_all_prep = 
%    for num_s = 1:length(list_id_subjects)
%        sig = all_prep(:,num_s);
%        med_prep_sub = median(sig);
%        dist = sig-med_all_prep;
%        if med_prep_sub < med_all_prep
%            [val,order] = sort(dist);
%            med_prep_trim(num_s) = median(sig(order(ceil(perc*length(sig)):end)));
%        else
%            [val,order] = sort(-dist);
%            med_prep_trim(num_s) = median(sig(order(ceil(perc*length(sig)):end)));
%    end
%end
