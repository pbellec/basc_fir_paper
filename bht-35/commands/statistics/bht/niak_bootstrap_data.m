function data_boot = niak_bootstrap_data(data,opt_boot)
%
% _________________________________________________________________________
% SUMMARY NIAK_BOOTSTRAP_DATA
%
% Apply a sequence of resampling schemes on a database.
%
% SYNTAX:
% DATA_BOOT = NIAK_BOOTSTRAP_DATA(DATA,OPT_BOOT)
%
% _________________________________________________________________________
% INPUTS:
%
% * DATA   
%       (structure) DATA is a database organized into a matlab structure,
%       with an arbitrary number of fields and entries. The only 
%       restriction is that the current implementation does not allow the 
%       user to resample subfields in the database.
%
% * OPT_BOOT
%       
%       (structure) Each entry of OPT_BOOT describes one resampling scheme. 
%       The schemes will all be applied sequentially in the same order as 
%       the entries. Each entry has two fields :
%
%       TYPE
%           (string) the resampling scheme. Available options :
%
%           'SB'
%               The stratified bootstap resamples the entries of DATA with 
%               replacement and a uniform distribution independently within 
%               each one of multiple strata defined through a set of 
%               categorical data.
%
%           'CBB'
%               The circular block bootstrap applies to a time*space 2D 
%               array. Blocks of samples are sampled rather than single 
%               observations. Edges effects are adressed by "periodicizing" 
%               time series.
%
%           'PERM_VAL'
%               Permute the values associated to one field, potentially
%               independently within each one of multiple strata.
%              
%           'PERM'
%               Permute one or both dimensions of a 2D array aka matrix.
%
%       OPT
%           (structure) the fields of OPT_BOOT(I).OPT are dependent on 
%           OPT_BOOT(I).TYPE:
%
%           * If OPT_BOOT(I).TYPE == 'SB'
%
%               STRATA
%                   (cell of strings, default {}) That field will be used 
%                   only when resampling structures. The values of the 
%                   fieldnames listed in STRATA wil be used to partition 
%                   the entries of FIELD, and resampling scheme will be 
%                   applied independently in each strata.
%
%           * If OPT_BOOT(I).TYPE == 'CBB'
%       
%               FIELD
%                   (string) the field of the database that will be 
%                   resampled. That field should correspond to a time*space
%                   array. Note that different entries of the database will
%                   be sampled independently.
%
%               BLOCK_LENGTH
%                   (integer, default sqrt(number of dimension length))
%                   window width used in the circular block bootstrap.
%
%               INDEPENDENCE
%                   (boolean, default false) if INDEPENDENCE == 1, in 
%                   multidimensional arrays the temporal bootstrap 
%                   distributions are independent from each other for 
%                   different spatial locations. Otherwise, the same 
%                   temporal windows are used at all spatial locations,
%                   thus preserving possible spatial dependencies.
%
%           * If OPT_BOOT(I).TYPE = 'PERM_VAL'
%
%               FIELD
%                   (string) the field of the database that will be 
%                   resampled. The values of this field are permuted in the
%                   database.
%
%               STRATA
%                   (cell of strings, default {}) The values of the 
%                   fieldnames listed in STRATA wil be used to partition 
%                   the entries of the database, and the permutation will
%                   be applied independently in each strata.
%
%               FLAG_SAME
%                   (boolean, default false) if FLAG_SAME is true, the same
%                   permutation will be used for all strata 
%
%           * If OPT_BOOT(I).TYPE = 'PERM'
%
%               FIELD
%                   (string) the field of the database that will be 
%                   resampled. That field should correspond to 2D array. 
%                   Note that different entries of the database will
%                   be sampled independently.
%
%               DIMENSION
%                   (string) which dimension of the array will be permuted.
%                   Availble options : 'first', 'second', 'both', 'same'
%                   Note that with 'same', the *same* permutation is
%                   applied to both dimension.
%
% _________________________________________________________________________
% OUTPUTS :
%
% DATA_BOOT  
%       (structure) 
%       A bootstrap replication of DATA.
%
% _________________________________________________________________________
% SEE ALSO:
%
% NIAK_BOOTSTRAP_TSERIES
%
% _________________________________________________________________________
% COMMENTS: 
%
% See NIAK_DEMO_BOOTSTRAP_DATA for examples.
%
% Copyright (c) Pierre Bellec, McConnell Brain Imaging Center,Montreal 
%               Neurological Institute, McGill University, 2008.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : bootstrap, time series, hypothesis testing, stratified data,
% block bootstrap

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
if ~exist('data','var')|~exist('opt_boot','var')
    error('niak:brick','syntax: DATA_BOOT = NIAK_BOOTSTRAP_DATA(DATA,OPT_BOOT) .\n Type ''help bootstrap_data'' for more info.')
end

%% Checking inputs

if ~isstruct(opt_boot)
    error('OPT_BOOT should be a structure')
end

if ~isstruct(data)
    error('DATA should be a structure')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Resampling starts here %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nb_schemes = length(opt_boot);
data_boot = data;

for num_s = 1:nb_schemes
    
    name_scheme = opt_boot(num_s).type;
    opt_scheme = opt_boot(num_s).opt;

    switch name_scheme
        
        case 'SB'
            
            %% default values
            gb_name_structure = 'opt_scheme';
            gb_list_fields = {'strata'};
            gb_list_defaults = {{}};
            niak_set_defaults
            
            %% Extract the strata
            nb_entries = length(data_boot(:));
            if ~isempty(opt_scheme.strata)
                nb_features = length(opt_scheme.strata);
                part_strata = zeros([nb_entries,nb_features],'int32');
                for num_f = 1:nb_features
                    field_val = {data_boot(:).(opt_scheme.strata{num_f})};
                    [tmp,tmp2,part_tmp] = unique(field_val);
                    part_strata(:,num_f) = part_tmp(:)';
                end
                [tmp,tmp2,mask_strata] = unique(part_strata,'rows');
            else
                mask_strata = ones([nb_entries 1]);
            end
            nb_strata = max(mask_strata);
            
            %% Perform the iid bootstrap in each stratum
            for num_s = 1:nb_strata
                list_num = find(mask_strata==num_s);
                list_num_boot = list_num(ceil(length(list_num)*rand([length(list_num) 1])));
                data_boot(list_num) = data_boot(list_num_boot);
            end     
            
        case 'CBB'
            
            %% default values
            gb_name_structure = 'opt_scheme';
            gb_list_fields = {'field','block_length','independence'};
            gb_list_defaults = {NaN,[],false};
            niak_set_defaults
            
            field_name = opt_scheme.field;
            opt_scheme = rmfield(opt_scheme,'field');
            opt_scheme.dgp = 'CBB';
            
            for num_f = 1:length(data_boot);                                
                
                data_boot(num_f).(field_name) = niak_bootstrap_tseries(data_boot(num_f).(field_name),opt_scheme);
                
            end

        case 'PERM_VAL'
            
            %% default values
            gb_name_structure = 'opt_scheme';
            gb_list_fields = {'strata','field'};
            gb_list_defaults = {{},NaN};
            niak_set_defaults

            field_name = opt_scheme.field;
            
            %% Extract the strata 
            nb_entries = length(data_boot(:));
            nb_features = length(opt_scheme.strata);            
            part_strata = zeros([nb_entries,nb_features],'int32');
            for num_f = 1:nb_features
                field_val = {data_boot(:).(opt_scheme.strata{num_f})};
                [tmp,tmp2,part_tmp] = unique(field_val);
                part_strata(:,num_f) = part_tmp(:)';
            end
            [tmp,tmp2,mask_strata] = unique(part_strata,'rows');
            nb_strata = max(mask_strata);
            
            %% Perform the iid bootstrap in each stratum
            for num_s = 1:nb_strata
                data_strata = data_boot(mask_strata==num_s);
                perm_field = randperm(length(data_strata));
                [data_boot(mask_strata==num_s).(field_name)] = deal(data_strata(perm_field).(field_name));
            end                             
            
        case 'PERM'            
            
            field_name = opt_scheme.field;
            
            for num_f = 1:length(data_boot);                                
                
                switch opt_scheme.dimension
                    
                    case 'first'

                        data_boot(num_f).(field_name) = data_boot(num_f).(field_name)(randperm(size(data_boot(num_f).(field_name),1)),:);
                        
                    case 'second'
                        
                        data_boot(num_f).(field_name) = data_boot(num_f).(field_name)(:,randperm(size(data_boot(num_f).(field_name),2)));
                        
                    case 'both'
                        
                        data_boot(num_f).(field_name) = data_boot(num_f).(field_name)(randperm(size(data_boot(num_f).(field_name),1)),randperm(size(data_boot(num_f).(field_name),2)));

                    case 'same'
                        
                        perm_dim = randperm(size(data_boot(num_f).(field_name),1));
                        data_boot(num_f).(field_name) = data_boot(num_f).(field_name)(perm_dim,perm_dim);
                        
                end
            end

        otherwise
            
            error('%s is an unkown resampling scheme',name_scheme);

    end
            
end       