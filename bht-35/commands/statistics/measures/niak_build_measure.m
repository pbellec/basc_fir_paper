function mes = niak_build_measure(data,opt)
% Estimate individual measures on each entry of a database and combine 
% them into one or multiple group-level measures.
%
% SYNTAX :
% MES = NIAK_BUILD_MEASURE(DATA,OPT)
%
% _________________________________________________________________________
% INPUTS:
%
% DATA
%       (structure) DATA is a database organized into a matlab structure,
%       with an arbitrary number of fields and entries. The only 
%       restriction is that the current implementation does not allow 
%       the user to estimate measures on subfields in the database.
%
% OPT
%       (structure) with the following fields : 
%
%       MEASURE_IND
%           (structure) with the following fields :
%
%           TYPE
%               (string) a measure that will be applied to each entry of 
%               the database. Available options :
%
%               'mean'
%                   The mean value of time series. 
%
%               'correlation'
%                   correlation matrix between time series. See
%                   NIAK_BUILD_CORRELATION.
%
%              'covariance'
%                   covariance matrix between time series.  See
%                   NIAK_BUILD_COVARIANCE.
%
%               'concentration'
%                   concentration matrix between time series.  See
%                   NIAK_BUILD_CONCENTRATION.
%
%              'partial_correlation'
%                   partial correlation matrix between time series.  See
%                   NIAK_BUILD_PARTIAL_CORRELATION.
%
%               'integration'
%                   integration between networks.  See
%                   NIAK_BUILD_INTEGRATION.
%
%              'AFC'
%                   average functional connectivity between networks.  See
%                   NIAK_BUILD_AFC.
%   
%              'copy'
%                   Copy a field from the database named
%                   OPT.MEASURE_IND.FIELD_ARGIN1
%
%              'stability'
%                   Derive a bootstrap estimate of the stability of
%                   association between two units in a clustering analysis.
%                   See the function NIAK_BUILD_STABILITY of the BASC
%                   project. The second argument of the call is
%                   OPT.MEASURE_IND.OPT_MES (see below).
%
%               'niak_mat2vec'
%                   Vectorize a matrix stored in FIELD_ARGIN1.
%
%           FIELD_ARGIN1
%               (string) The name of the field of the database to use as a
%               first input argument for the measure.
%             
%           FIELD_ARGIN2
%               (string) The name of the field of the database to use as a
%               second input argument for the measure.
%
%           OPT_MES
%               (structure) a structure that may be passed over to the
%               measure function for certain measure types.
%
%       MEASURE_GROUP
%           (structure) with multiple entries. Each entry corresponds to
%           one measure on the database. MEASURE_GROUP has the following
%           fields : 
%
%           TYPE
%               (string) the type of group-level measure. Available 
%               options : 
%
%                   'average'
%                       The measures are averaged over a number of entries
%                       of the database. Note that all measures must have
%                       the same dimensions in order to be averaged.
%
%                   'copy'
%                       just copy all the individual measures for the 
%                       specified subsets.
%               
%           LABEL
%               (string) a label for the group-level measure.
%
%           FIELD_SUBSET, VAL_SUBSET
%               Those two fields are used to define the entries 
%               of the database that will be included in the group-level 
%               measure. See NIAK_SUBSET_DATA for a description.
%
%
%       FLAG_VEC 
%           (boolean, default true) if FLAG_VEC == true, the measure MES 
%           will be "vectorized". Use NIAK_VEC2MEASURE to get a more 
%           readable version.
%
% _________________________________________________________________________
% OUTPUTS:
%
% MES
%       (vector or structure) 
%
%       case FLAG_VEC == false
%
%           MES(I).LABEL
%               (string) equal to OPT.MEASURE_GROUPE(I).LABEL
%
%           MES(I).VAL
%               The group level connectivity measure corresponding to
%               OPT.MEASURE_GROUP(I).
%
%       case FLAG_VEC == true
%
%           all the elements of the connectivity measures have been
%           vectorized.
%       
% _________________________________________________________________________
% SEE ALSO:
% NIAK_VEC2COMP, NIAK_COMP2VEC, NIAK_BUILD_CORRELATION, NIAK_BUILD_AFC,
% NIAK_BUILD_INTEGRATION
%
% _________________________________________________________________________
% COMMENTS:
%
% This function is an extra layer on top of other functions NIAK_BUILD*, and
% is used to unify the application of these functions to multiple entries 
% in a database.
%
% This function has no default values for arguments and hardly check on the 
% syntax. That means that the user may get highly non-informative error 
% messages. The rationale for that poor behavior is to avoid wasting time 
% checking arguments 1000000 times when bootstraping the measure.
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

%%%%%%%%%%%%%%%%%%%%%%%%%
%% set default inputs %%%
%%%%%%%%%%%%%%%%%%%%%%%%%

%% Syntax
if ~exist('data','var')|~exist('opt','var')
    error('niak:brick','syntax: MES = NIAK_BUILD_MEASURE(DATA,OPT).\n Type ''help niak_build_measure'' for more info.')
end

if isfield(opt,'flag_test')
    flag_test = opt.flag_test;
else
    flag_test = false;
end

if isfield(opt,'flag_vec')
    flag_vec = opt.flag_vec;
else
    flag_vec = true;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% mask of subsets of the database %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nb_entries = length(data);
nb_mes = length(opt.measure_group);
mask_subsets = false([nb_mes nb_entries]);
for num_m = 1:nb_mes
    mask_subsets(num_m,:) = niak_subset_data(data,opt.measure_group(num_m).field_subset,opt.measure_group(num_m).val_subset);
end

list_entries = find(max(mask_subsets,[],1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Individual measure estimation %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mes_ind = struct('val_ind',repmat({[]},[nb_entries 1]));

for num_e = list_entries  
    
    switch opt.measure_ind.type
                
        case 'mean'
            
            mes_ind(num_e).val_ind = mean(data(num_e).(opt.measure_ind.field_argin1))';
            
        case 'covariance'            

            mes_ind(num_e).val_ind = niak_build_covariance(data(num_e).(opt.measure_ind.field_argin1),true);
        
        case 'correlation'            

            mes_ind(num_e).val_ind = niak_build_correlation(data(num_e).(opt.measure_ind.field_argin1),true);
        
        case 'concentration'            

            mes_ind(num_e).val_ind = niak_build_concentration(data(num_e).(opt.measure_ind.field_argin1),true);

        case 'partial_correlation'            

            mes_ind(num_e).val_ind = niak_build_partial_correlation(data(num_e).(opt.measure_ind.field_argin1),true);
            
        case 'integration'
            
            mes_ind(num_e).val_ind = niak_build_integration(data(num_e).(opt.measure_ind.field_argin1),data(num_e).(opt.measure_ind.field_argin2),true);

        case 'AFC'
            
            mes_ind(num_e).val_ind = niak_build_afc(data(num_e).(opt.measure_ind.field_argin1),data(num_e).(opt.measure_ind.field_argin2),true);

        case 'copy'
            
            mes_ind(num_e).val_ind = data(num_e).(opt.measure_ind.field_argin1);

        case 'stability'

            mes_ind(num_e).val_ind = niak_build_stability(data(num_e).(opt.measure_ind.field_argin1),opt.measure_ind.opt_mes);
            
        case 'niak_mat2vec'

            mes_ind(num_e).val_ind = niak_mat2vec(data(num_e).(opt.measure_ind.field_argin1));

        otherwise
            
            error('%s is an unkown type of individual measure',opt.measure_ind.type)
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Group-level measure estimation %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for num_m = 1:length(opt.measure_group)
    
    list_subset = find(mask_subsets(num_m,:));
    mes(num_m).label = opt.measure_group(num_m).label;
    
    switch opt.measure_group(num_m).type
        
        case 'average'
            
            val_mean = zeros(size(mes_ind(list_subset(1)).val_ind));
            
            for num_e = list_subset
                
                val_mean = val_mean + mes_ind(list_subset(num_e)).val_ind;
                
            end
            
            val_mean = val_mean / length(list_subset);
            
            mes(num_m).val_group = val_mean;
            
        case 'copy'
            
            mes(num_m).val_group = mes_ind(list_subset);
            
        otherwise
            
            error('%s is an unkown type of group-level measure',opt.measure_group(num_m).type)
            
    end
    
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Put the measure in vectorized or unvectorized format %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~flag_vec

    for num_m = 1:length(mes)

        switch opt.measure_group(num_m).type

            case 'average'

                mes(num_m).val_group = sub_vec2comp(mes(num_m).val_group,opt.measure_ind.type);

            case 'copy'

                for num_e = 1:length(mes(num_m).val_group)

                    mes(num_m).val_group(num_e).val_ind = sub_vec2comp(mes(num_m).val_group(num_e).val_ind,opt.measure_ind.type);

                end

        end
    end
    
else

    length_vec = 0;
    
    for num_m = 1:length(mes)

        switch opt.measure_group(num_m).type

            case 'average'

                length_vec = length_vec + length(mes(num_m).val_group);                                

            case 'copy'

                for num_e = 1:length(mes(num_m).val_group)
                    
                    length_vec = length_vec + length(mes(num_m).val_group(num_e).val_ind);                   

                end

        end
    end
    
    pos_vec = 0;
    vec_mes = zeros([length_vec 1]);
    
    for num_m = 1:length(mes)

        switch opt.measure_group(num_m).type

            case 'average'

                vec_mes(pos_vec+1:pos_vec+length(mes(num_m).val_group)) = mes(num_m).val_group;
                pos_vec = pos_vec + length(mes(num_m).val_group);
                
            case 'copy'

                for num_e = 1:length(mes(num_m).val_group)
                    
                    vec_mes(pos_vec+1:pos_vec+length(mes(num_m).val_group(num_e).val_ind)) = mes(num_m).val_group(num_e).val_ind;
                    pos_vec = pos_vec + length(mes(num_m).val_group(num_e).val_ind);
                
                end

        end
    end
    mes = vec_mes;
end

%%%%%%%%%%%%%%%%%%
%% Subfunctions %%
%%%%%%%%%%%%%%%%%%

function comp = sub_vec2comp(vec,type)

switch type
    
    case {'correlation','partial_correlation'}
        
        comp = niak_vec2mat(vec);
        
    case {'covariance','concentration','AFC'}
        
        comp = niak_lvec2mat(vec);
        
    case {'integration'}
        
        comp = niak_vec2int(vec);
end
