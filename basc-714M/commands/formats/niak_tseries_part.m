function [tseries_roi,ind] = niak_tseries_part(tseries,mask,part,opt)
% Extract average time series in a partition
%
% [TSERIES_ROI,IND] = NIAK_TSERIES_PART(VOL,MASK,PART,OPT)
%
% _________________________________________________________________________
% INPUTS:
%
% TSERIES
%     (array T*N) each column J is a times series associated with MASK==J
%
% MASK
%     (3D volume or vector) with integer values defining regions of 
%     interest. 0s are ignored.
%
% PART
%     (3D volume or vector) with integer values defining regions of 
%     interest. 0s are ignored.
%
% OPT       
%       (structure, optional) each field of OPT is used to specify an 
%       option. If a field was not specified, then the default value is
%       assumed.
%
%       CORRECTION
%           (structure, default CORRECTION.TYPE = 'none') the temporal 
%           normalization to apply on the individual time series before 
%           averaging in each ROI. See OPT in NIAK_NORMALIZE_TSERIES.
%
% _________________________________________________________________________
% OUTPUTS:
%
% TSERIES   
%       (array) TSERIES(:,I) is the average time series of all regions of
%       MASK that have an overlap with PART==I.
%
% _________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Pierre Bellec, 
% Département d'informatique et de recherche opérationnelle
% Centre de recherche de l'institut de Gériatrie de Montréal
% Université de Montréal, 2011
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : ROI, time series, fMRI

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

%% Setting up default inputs
opt_norm.type = 'none';
list_fields   = {'correction'};
list_defaults = {opt_norm};
if nargin < 4
  opt = psom_struct_defaults(struct(),list_fields,list_defaults);
else
  opt = psom_struct_defaults(opt,list_fields,list_defaults);
end

ind = unique(part(part>0));
for num_p = 1:length(ind)
    tmp = unique(mask(part==ind(num_p)));
    tmp = tmp(tmp~=0);
    tseries_roi(:,num_p) = mean(tseries(:,tmp),2);
end