function mask_subset = niak_subset_data(data,field_subset,val_subset);
%
% _________________________________________________________________________
% SUMMARY NIAK_SUBSET_DATA
%
% Create a logical mask of the entries of a database for which the values
% of a set of fields are matching some specified values.
%
% SYNTAX:
% MASK_SUBSET = NIAK_SUBSET_DATA(DATA,FIELD_SUBSET,VAL_SUBSET)
%
% _________________________________________________________________________
% INPUTS:
%
% DATA
%       (structure) DATA is a database organized into a matlab structure,
%       with an arbitrary number of fields and entries. 
%
% FIELD_SUBSET
%       (cell of strings) a list of field names that are used to select a 
%       subset of entries in the database. If left empty, all entries of
%       the database are included in the subset.
%
% VAL_SUBSET
%       (cell of string/integer/cell of strings/array of integers)
%       DATA(J) is included in the subset if all the values 
%       DATA(J).(FIELD_SUBSET{K}) are members of VAL_SUBSET{K}. The values
%       of the fields can be strings or integers. If VAL_SUBSET{K} is a
%       cell of string or a vector of integers, more than one value for the
%       field will be allowed.
%       
% _________________________________________________________________________
% OUTPUTS:
%
% MASK_SUBSET
%       (boolean) MASK_SUBSET(I) == true if the entry DATA(I) of the
%       database matches the conditions FIELD_SUBSET and VAL_SUBSET.
%
% _________________________________________________________________________
% SEE ALSO:
%
% NIAK_DEMO_DATA, NIAK_BOOTSTRAP_DATA
%
% _________________________________________________________________________
% EXAMPLE:
%
% niak_demo_data % generate an example database
%
% % find the data for subjects aged of 22 or 29 years
% find(niak_subset_data(data,{'age'},{[22,19]}))
%
% % find the data for subjects aged of 22 or 29 years, in 'motor' condition
% find(niak_subset_data(data,{'age','condition'},{[22,19],'motor'}))
%
% % find the data for subjects 'subj1' and 'subj2'
% find(niak_subset_data(data,{'subject'},{{'subj1','subj2'}}))
%
% _________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Pierre Bellec, McConnell Brain Imaging Center, Montreal 
%               Neurological Institute, McGill University, 2007.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : database, bht

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

mask_subset = true(size(data));

for num_t = 1:length(field_subset);

    if isnumeric(data(1).(field_subset{num_t}))||islogical(data(1).(field_subset{num_t}))
        mask_tmp = ismember([data.(field_subset{num_t})],val_subset{num_t});        
    elseif ischar(data(1).(field_subset{num_t}))
        mask_tmp = ismember({data.(field_subset{num_t})},val_subset{num_t});
    else
        error('DATA.(FIELD_SUBSET{%i}) should be either a string or numeric.',num_t)
    end
    mask_tmp = reshape(mask_tmp,size(data));
    mask_subset = mask_subset & mask_tmp;

end
