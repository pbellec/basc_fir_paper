function [data_s,measure_s] = niak_speed_measure(data,measure)
%
% _________________________________________________________________________
% SUMMARY OF NIAK_SPEED_MEASURE
%
% Reorganize a database and measure to speed up the computations big time.
%
% SYNTAX :
% [DATA_S,MEASURE_S] = NIAK_SPEED_MEASURE(DATA,MEASURE)
%
% _________________________________________________________________________
% INPUTS:
%
% * DATA
%
%       (structure) DATA is a database organized into a matlab structure,
%       with an arbitrary number of fields and entries. The only 
%       restriction is that the current implementation does not allow 
%       the user to estimate measures on subfields in the database.
%
% * MEASURE
%       
%       (structure) Each entry of MEASURE describes one measure estimation. 
%       See the help of NIAK_BUILD_MEASURE for details.
%
% _________________________________________________________________________
% OUTPUTS:
%
% DATA_S and MEASURE_S are the same as the inputs, except that all string
% field values used for defining averages or differences have been replaced
% by numbers, and that copy of fields have been removed, unless their 
% removal produced an error. 
%
% _________________________________________________________________________
% SEE ALSO:
%
% NIAK_BUILD_MEASURE
%
% _________________________________________________________________________
% COMMENTS:
%
% This function is used by NIAK_BHT and was not really meant to be used
% independently.
%
% Copyright (c) Pierre Bellec, McConnell Brain Imaging Center, Montreal
%               Neurological Institute, McGill University, 2007.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : medical imaging, statistics, connectivity measure

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

data_s = data;
measure_s = measure;

nb_measures = length(measure_s);
opt_measure.flag_vec = false;
opt_measure.flag_test = true;

%% Get rid of unnecessary copies of fields
for num_m = 1:nb_measures
    
    opt_m = measure_s(num_m).opt;
    
    if isfield(opt_m,'field_copy');
        
        for num_e = 1:length(opt_m.field_copy)           
            
            measure_tmp = measure_s;
            measure_tmp(num_m).opt.field_copy = measure_tmp(num_m).opt.field_copy(~ismember(measure_tmp(num_m).opt.field_copy,opt_m.field_copy{num_e}));

            try
                data_m = niak_build_measure(data_s,measure_tmp,opt_measure);
                measure_s = measure_tmp;
            end
        end
    end
    
end