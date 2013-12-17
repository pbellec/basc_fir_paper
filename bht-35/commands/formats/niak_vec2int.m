function int = niak_vec2int(vec);
%
% _________________________________________________________________________
% SUMMARY OF NIAK_VEC2INT
%
% Convert a vectorized measure of integration into a structure form.
%
% SYNTAX:
% MAT = NIAK_VEC2MAT(VEC)
%
% _________________________________________________________________________
%
% INPUTS:
%
% VEC           
%       (vector) a vectorized measure of integration.
%
% _________________________________________________________________________
% OUTPUTS:
%
% INT           
%       (structure) 
%
%           INT.TOTAL 
%               (scalar) the total integration of the system.
%
%           INT.INTRA
%               (scalar) the total intra-system integration.
%
%           INT.INTER
%               (scalar) the total inter-system integration.
%
%           INT.MAT
%               (matrix) the matrix of intra/inter system integration. 
%
% _________________________________________________________________________
% SEE ALSO:
%
% NIAK_BUILD_INTEGRATION
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

int.total = vec(1);
int.intra = vec(2);
int.inter = vec(3);
int.mat = niak_lvec2mat(vec(4:end));