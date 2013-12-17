function ci = niak_tests2ci(tests,pce)
%
% _________________________________________________________________________
% SUMMARY OF NIAK_TEST2CI
%
% Derive confidence intervals on a measure based on the cumulative
% distribution functions derived through NIAK_BHT.
%
% SYNTAX:
% CI = NIAK_TESTS2CI(TESTS,PCE)
%
% _________________________________________________________________________
% INPUTS:
%
% TESTS
%       (structure) see the outputs of NIAK_BHT.
%
% PCE
%       (real number, default 0.05) the per-comparison error associated
%       with the bootstrap (bilateral) confidence interval.
%       
% _________________________________________________________________________
% OUTPUTS:
%
% CI
%       (matrix) CI(1,NUM_M) is the lower bound of the confidence interval
%       of the NUM_Mth component of the measure, and CI(2,NUM_M) is the
%       upper bound.
%
% _________________________________________________________________________
% SEE ALSO:
%
% NIAK_BHT
%
% _________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Pierre Bellec, McConnell Brain Imaging Center, Montreal 
%               Neurological Institute, McGill University, 2007.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : correlation, functional connectivity, time series

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

if nargin < 2
    pce = 0.05;
end

y = [pce/2 1-(pce/2)];
nb_m = size(tests.cdfs,2);
ci = zeros([2 nb_m]);

for num_m = 1:nb_m
    ci(:,num_m) = interp1(tests.cdfs(:,num_m),tests.bins_measure(:,num_m),y);
end  