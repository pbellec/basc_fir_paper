function [files_in,files_out,opt] = fir_brick_stat_peaks(files_in,files_out,opt)
% Estimate the significance of the difference in peaks between preparation/execution
%
% SYNTAX:
% [FILES_IN,FILES_OUT,OPT] = FIR_BRICK_STAT_PEAKS(FILES_IN,FILES_OUT,OPT)
%
% _________________________________________________________________________
% INPUTS:
%
% FILES_IN
%    (structure) with the following fields:
% 
%    FIR_ALL
%        (string or cell of strings) The name of a .mat file, which contains 
%        one variable FIR_ALL. FIR_ALL(:,I,J) is the time series of region I 
%        at trial J. If FIR_ALL is a cell of strings, The FIR_ALL variables 
%        will be averaged across all entries.
%
%    ATOMS
%        (string) the name of a file with a 3D volume defining the atoms for 
%        analysis.
%
%    PARTITION
%        (string) the name of a file with a 3D volume defining a partition.
%
% FILES_OUT
%   (structure) with the following fields:
%
%   FDR
%       (string) A .mat file which contains two variables TEST_FIR
%       and TEST_DIFF.
%
% OPT           
%   (structure) with the following fields:
%
%   NB_SAMPS
%       (integer, default 100) the number of samples to use in the 
%       bootstrap approximation of the cumulative distribution functions
%       and the FDR.
%
%   NORMALIZE
%       (structure, optional) the temporal normalization to apply on the 
%       FIR estimates, with the following options :
%
%       TYPE
%           (string) the type of applied normalization of the response. 
%           Available options:
%           'fir' : correction to a zero mean at the beginning of the 
%               response.
%           'fir_shape' : correction to a zero mean at the beginning
%               of the response and a unit energy of the response.  
%    
%       TIME_NORM
%           (scalar) the number of seconds of signal at the begining of 
%           each response which are used to set the baseline to zero.
%
%    LIST_NETWORK
%        (vector, default []) a list of NETWORK. The analysis will be restricted
%        to these networks. 
%
%   RAND_SEED
%       (scalar, default []) The specified value is used to seed the random
%       number generator with PSOM_SET_RAND_SEED. If left empty, no action
%       is taken.
%
%   FLAG_TEST
%       (boolean, default 0) if the flag is 1, then the function does not
%       do anything but update the defaults of FILES_IN, FILES_OUT and OPT.
%
%   FLAG_VERBOSE 
%       (boolean, default 1) if the flag is 1, then the function 
%       prints some infos during the processing.
%           
% _________________________________________________________________________
% OUTPUTS:
%
% The structures FILES_IN, FILES_OUT and OPT are updated with default
% valued. If OPT.FLAG_TEST == 0, the specified outputs are written.
%              
% _________________________________________________________________________
% SEE ALSO:
% NIAK_BUILD_FIR, NIAK_PIPELINE_STABILITY_FIR
%
% _________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Pierre Bellec, Centre de recherche de l'institut de 
% Gériatrie de Montréal, Département d'informatique et de recherche 
% opérationnelle, Université de Montréal, 2010-2011.
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : clustering, stability, bootstrap, FIR

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

%% Syntax
if ~exist('files_in','var')|~exist('files_out','var')|~exist('opt','var')
    error('niak:brick','syntax: [FILES_IN,FILES_OUT,OPT] = NIAK_BRICK_FDR_FIR(FILES_IN,FILES_OUT,OPT).\n Type ''help niak_brick_fdr_fir'' for more info.')
end
   
%% Files in
list_fields   = {'fir_all' , 'atoms' , 'partition' };
list_defaults = {NaN       , NaN     , NaN         };
files_in = psom_struct_defaults(files_in,list_fields,list_defaults);

%% Files out
list_fields   = {'fdr'             };
list_defaults = {'gb_niak_omitted' };
files_out = psom_struct_defaults(files_out,list_fields,list_defaults);

%% Options
opt_normalize.type = 'fir_shape';
opt_normalize.time_norm = 1;
list_fields   = {'list_network' , 'rand_seed' , 'normalize'   , 'nb_samps' , 'flag_verbose' , 'flag_test'  };
list_defaults = {[]             , []          , opt_normalize , 100        , true           , false        };
opt = psom_struct_defaults(opt,list_fields,list_defaults);

%% If the test flag is true, stop here !
if opt.flag_test == 1
    return
end

%% Seed the random generator
if ~isempty(opt.rand_seed)
    psom_set_rand_seed(opt.rand_seed);
end

%% Read the FIR estimates
if opt.flag_verbose
    fprintf('Read the FIR estimates ...\n');
end
if ischar(files_in.fir_all)
    load(files_in.fir_all)
else
    for num_e = 1:length(files_in.fir_all)
        if opt.flag_verbose
            fprintf('    %s\n',files_in.fir_all{num_e})
        end
        data = load(files_in.fir_all{num_e});
        if num_e == 1
            [nt,nr,ne] = size(data.fir_all);
            fir_all = zeros([nt,nr,length(files_in.fir_all)]);
            time_samples = data.time_samples;
            time_sampling = time_samples(2)-time_samples(1); % The TR of the temporal grid (assumed to be regular) 
            opt.normalize.time_sampling = time_sampling;
        end
        fir_all(:,:,num_e) = niak_normalize_fir(mean(data.fir_all,3),opt.normalize);
    end
    clear data
end
[nt,nr,ne] = size(fir_all);
time_sampling = time_samples(2)-time_samples(1); % The TR of the temporal grid (assumed to be regular)

%% Read the atoms 
if opt.flag_verbose
    fprintf('Read the volume of atoms ...\n');
end
[hdr,atoms] = niak_read_vol(files_in.atoms);

%% Read the partition
if opt.flag_verbose
    fprintf('Read the partition volume ...\n')
end
[hdr,vol_part] = niak_read_vol(files_in.partition);
if ~isempty(opt.list_network)
    vol_tmp = zeros(size(vol_part));
    for num_n = 1:length(opt.list_network)
        vol_tmp(vol_part==opt.list_network(num_n)) = num_n;
    end
    vol_part = vol_tmp;
end

%% Extract average FIR responses
list_networks = unique(vol_part(:));
list_networks = list_networks(list_networks~=0);
nn = length(list_networks);
fir_net = zeros([nt nn ne]);
for num_n = 1:nn
    list_a = unique(atoms(vol_part==list_networks(num_n)));
    list_a = list_a(list_a~=0);
    fir_net(:,num_n,:) = mean(fir_all(:,list_a,:),2); 
end

%% Run the FDR tests: significance of the peak difference in exec - prep
opt_cit.bootstrap.name_boot = 'niak_stability_fir_boot';
opt_cit.measure.name_mes = 'fir_significance_diff_peaks';
opt_cit.measure.opt_mes.time_sampling = time_sampling;
opt_cit.measure.opt_mes.time_norm = opt.normalize.time_norm;
opt_cit.measure.opt_mes.type = opt.normalize.type;
opt_cit.nb_samps = opt.nb_samps;
opt_cit.side = 'two-sided';
opt_cit.type_fdr = 'BY';
if opt.flag_verbose
    fprintf('Testing the significance of differences execution (peak) - preparation (peak) ...\n')
end
opt_cit.measure.opt_mes.flag_diff = false;
test_peaks = niak_conf_interv_test(fir_net,0,opt_cit);

%% Now the diffs
opt_cit.measure.opt_mes.flag_diff = true;
test_diff = niak_conf_interv_test(fir_net,0,opt_cit);

%% Save outputs
if opt.flag_verbose
    fprintf('Saving outputs ...\n')
end
if ~strcmp(files_out.fdr,'gb_niak_omitted')
    save(files_out.fdr,'test_peaks','test_diff')
end
