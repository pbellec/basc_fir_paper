function part = niak_hier2part(hier);
%
% _________________________________________________________________________
% SUMMARY OF NIAK_HIER2PART
%
% Convert a hierarchy into a series of partitions
%
% SYNTAX:
% PART = NIAK_HIER2PART(HIER)
%
% _________________________________________________________________________
%
% INPUTS:
%
% HIER
%       (matrix) a hierarchy. See NIAK_HIERARCHICAL_CLUSTERING
%
% _________________________________________________________________________
% OUTPUTS:
%
% PART
%       (array) PART(N,:) is a partition into N clusters derived from the
%       hierarchy.
%
% _________________________________________________________________________
% SEE ALSO:
%
% _________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Pierre Bellec, McConnell Brain Imaging Center, Montreal 
%               Neurological Institute, McGill University, 2007.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : partition, hierarchy

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

N = size(hier,1)+1;
part_quick = zeros([N N]);
part_quick(1,:) = ones([1 N]);
part_quick(end,:) = 1:N;
labels = 1:N;

for num_n = 1:N-2
    
    num_c = N-num_n;
    cx = hier(num_n,2);
    cy = hier(num_n,3);
    cz = hier(num_n,4);
    part_tmp = part_quick(num_c+1,:);
    part_tmp(part_tmp==cx) = cz;
    part_tmp(part_tmp==cy) = cz;
    part_quick(num_c,:) = part_tmp;
end

part = part_quick;

for num_n = 1:N-2
    
    num_c = N-num_n;
    cz = hier(num_n,4);   
    part_tmp = part(num_c+1,:);
    part_tmp2 = part_quick(num_c,:);
    mask = part_tmp2 == cz;
    cx = min(part_tmp(mask));
    cy = max(part_tmp(mask));
    part_tmp(mask) = cx;
    part_tmp(part_tmp>cy) = part_tmp(part_tmp>cy)-1;
    part(num_c,:) = part_tmp;
end
