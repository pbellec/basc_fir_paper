function dist = fir_significance_diff_peaks(fir_all,opt);
% Statics for testing significance of difference in peaks preparation vs execution
%
% SYNTAX:
% DIST = FIR_SIGNIFICANCE_DIFF_PEAKS(FIR_ALL,OPT)
%
% _________________________________________________________________________
% INPUTS:
%
% FIR_ALL
%    (array T*N*R) T time samples, N regions, R repetitions. Each column is 
%    a sample of the response to a stimulus in a brain region.
%
% OPT
%    (structure) with the following fields:
%
%    TYPE
%        (string) the type of applied normalization of the response. 
%        Available options:
%        'fir' : correction to a zero mean at the beginning of the 
%            response.
%        'fir_shape' : correction to a zero mean at the beginning
%            of the response and a unit energy of the response.  
%    
%    TIME_SAMPLING
%        (scalar) the time between two samples of the response.
%    
%    TIME_NORM
%        (scalar) the number of seconds of signal at the begining of 
%        each response which are used to set the baseline to zero.
%
%    FLAG_DIFF
%        (boolean) if FLAG_DIFF is false, then DIST is the vector of difference
%        between the peaks at execution and preparation, otherwise it is a vectorized
%        version of the matrix of difference in the difference in peaks across regions. 
%
% _________________________________________________________________________
% OUTPUTS:
%
% DIST
%    (vector) the difference peak execution - peak preparation (FLAG_DIFF is false) 
%    or the vectorized version of the matrix of difference in the difference in peaks 
%    across regions.
%
% _________________________________________________________________________
% SEE ALSO:
%
% _________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Pierre Bellec
% Département d'informatique et de recherche opérationnelle
% Centre de recherche de l'institut de Gériatrie de Montréal
% Université de Montréal, 2012
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : statistics, correlation

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

fir_mean = niak_normalize_fir(mean(fir_all,3),opt);
fir_diff =  max(fir_mean(12:16,:),[],1) - max(fir_mean(4:8,:),[],1);
dist = fir_diff(:);

if (nargin>1) && isfield(opt,'flag_diff') && opt.flag_diff
    dist = repmat(dist,[1 length(dist)]) - repmat(dist',[length(dist) 1]);
    dist = niak_mat2vec(dist);
end

%% Normalize the FIR responses to zero mean on a small temporal window and unit
%% energy for the average, and get back the mean/std responses
function [fir_mean,fir_std] = sub_correct_fir_mean(fir_all,type_norm,nb_vol)

fir_mean = mean(fir_all,3);    
fir_std = std(fir_all,[],3)/sqrt(size(fir_all,3));
fir_mean = fir_mean-repmat(mean(fir_mean(1:nb_vol,:),1),[size(fir_mean,1) 1]);
if strcmp(type_norm,'fir_shape')        
    weights = repmat(sqrt(sum(fir_mean.^2,1)),[size(fir_mean,1) 1]);
    fir_mean = fir_mean./weights;
    fir_std = fir_std./weights;    
end
