function supp = niak_part2supp(part);
%
% _________________________________________________________________________
% SUMMARY NIAK_PART2SUPP
%
% Convert a partition of objects using labels into a matrix representation
% SUPP where SUPP(:,K) is a binary support vector of the Kth cluster.
%
% SYNTAX:
% SUPP = NIAK_PART2SUPP(PART)
%
% _________________________________________________________________________
% INPUTS:
%
% PART
%       (vector length N) a vector of integer labels coding for a partition.
%
% _________________________________________________________________________
% OUTPUTS:
%
% SUPP
%       (matrix M*K) where K is the number of labels in PART. 
%
% _________________________________________________________________________
% SEE ALSO:
%
% NIAK_PART2MAT
%
% _________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Pierre Bellec, McConnell Brain Imaging Center, Montreal 
%               Neurological Institute, McGill University, 2007.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : 

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

N = length(part);

K = max(part(:));

supp = false([N,K]);
for num_k = 1:K
    supp(part == num_k,num_k) = true;
end