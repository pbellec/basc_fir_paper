function pce_thre = niak_fdr2pce(bins_pce,fdr,fdr_thre)
%
% _________________________________________________________________________
% SUMMARY NIAK_FDR2PCE
%
% Converts a threshold on false-discovery rate into a threshold on
% per-comparison error.
%
% SYNTAX:
% PCE_THRE = NIAK_FDR2PCE(BINS_PCE,FDR,THRE)
%
% _________________________________________________________________________
% INPUTS:
%
% BINS_PCE
%       (vector [NB_BINS 1]) the bins used on the PCE values.
%
% FDR      
%       (vector [NB_BINS 1]) FDR(I) is the estimated FDR for a PCE
%       threshold equals to BINS_PCE(I).
%
% FDR_THRE 
%       (scalar) the threshold on an acceptable false-discovery rate
%
% _________________________________________________________________________
% OUTPUTS:
%
% PCE_THRE
%       (scalar) The threshold on an acceptable per-comparison error.
% _________________________________________________________________________
% SEE ALSO:
%
% NIAK_BUILD_FDR, NIAK_BHT
%
% _________________________________________________________________________
% COMMENTS:
%
% PCE_THRE = -Inf means that the requested FDR level cannot be achieved for
% any threshold on the per-comparison error.
%
% Copyright (c) Pierre Bellec, McConnell Brain Imaging Center, Montreal 
%               Neurological Institute, McGill University, 2007.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : false-discovery rate, false-positive rate

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

ind = 0;
while (ind+1 <= length(fdr))&&(fdr(ind+1) <= fdr_thre)
    ind = ind+1;
end

if ind == 0
    pce_thre = -Inf;
else
    pce_thre = bins_pce(ind);
end