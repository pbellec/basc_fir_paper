function mc = niak_vec2comp(mv,data,opt)

% Transform a 'vectorized' measure of connectivity into a
% more readable format. The data and structure of options used to derive the
% vectorized measure need to be specified, but no computation is actually
% performed.
%
% SYNTAX:
% MC = FNAK_VEC2COMP(MV,DATA,OPT)
%
% INPUTS
% DATA,OPT  see INPUTS of FNAK_BUILD_MEASURE.
% MV            a vectorized connectivity measure, see OUTPUTS of
%               FNAK_BUILD_MEASURE.
% 
% OUTPUTS:
% MC        (structure) entry "i" of MC refers to entry "i" of DATA. Fields
%               of MC depend on OPT.MEASURE
%
% CASE OPT.MEASURE = 'R'
%           MC(i).MAT correlation matrix associated with DATA(i).
%           All fields of DATA other than TSERIES are copied in MC.
%
% CASE OPT.MEASURE = 'P'
%           MC(i).MAT partial correlation matrix associated with DATA(i).
%           All fields of DATA other than TSERIES are copied in MC.
%
% CASE OPT.MEASURE = 'int'
%           MC(i).TOTAL total integration associated with DATA(i).
%           MC(i).INTRA intra-network integration associated with
%                  DATA(i).
%           MC(i).INTER inter-network integration associated with
%                  DATA(i).
%           MC(i).MAT(m,n) is the inter-network integration between
%                  networks m and n.
%           All fields of DATA other than TSERIES and PART are copied in MC.           
%
% CASE OPT.MEASURE = 'afc'
%           MC(i).MAT(m,n) is the inter-network average functional 
%                  connectivity (afc) between networks m and n. 
%                  Intra-network afc is for m=n.
%           All fields of DATA other than TSERIES and PART are copied in MC.           
%
% SEE ALSO:
% FNAK_BUID_MEASURE, FNAK_*2*
%
% COMMENTS
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

if isfield(opt,'measure')
    measure = opt.measure;
else
    error('I cannot find the field ''measure'' in structure opt !')
end

num_l = 1;
list_fields = fieldnames(data);
nb_entries = length(data);

switch measure
    case {'R','P'}
        mc = rmfield(data,'tseries');
    case {'int','afc'}
        mc = rmfield(data,'tseries');
        mc = rmfield(mc,'part');
    otherwise
        error('%s : unknown measure type',measure)
end
    
optt = opt;
optt.flag_test = 1;
optt.flag_vec = 1;
for num_e = 1:nb_entries
    
    mtmp = niak_build_measure(data(num_e),optt);
    ml = mv(num_l:(num_l+length(mtmp)-1));
    num_l = num_l + length(mtmp);

    switch measure
        case {'R','P'}    
            mc(num_e).mat = niak_vec2mat(ml);
        case 'int'
            mc(num_e).total = ml(1);
            mc(num_e).intra = ml(2);
            mc(num_e).inter = ml(3);
            mc(num_e).mat = niak_lvec2mat(ml(4:end));
        case 'afc'
            mc(num_e).mat = niak_lvec2mat(ml);
    end
    
end