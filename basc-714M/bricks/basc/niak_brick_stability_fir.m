function [files_in,files_out,opt] = niak_brick_stability_fir(files_in,files_out,opt)
% Estimate the stability of a clustering of finite impulse response.
%
% SYNTAX:
% [FILES_IN,FILES_OUT,OPT] = NIAK_BRICK_STABILITY_FIR(FILES_IN,FILES_OUT,OPT)
%
% _________________________________________________________________________
% INPUTS:
%
% FILES_IN 
%   (string) The name of a .mat file, which contains one variable FIR_ALL. 
%   FIR_ALL(:,I,J) is the time series of region I at trial J. 
%
% FILES_OUT
%   (string) A .mat file which contains the following variables :
%
%   STAB
%       (array) STAB(:,s) is the vectorized version of the stability matrix
%       associated with OPT.NB_CLASSES(s) clusters.
%
%   NB_CLASSES
%       (vector) Identical to OPT.NB_CLASSES (see below).
%
%   PART
%       (matrix N*S) PART(:,s) is the consensus partition associated with 
%       STAB(:,s), with the number of clusters optimized using the summary
%       statistics.
%
%   ORDER
%       (matrix N*S) ORDER(:,s) is the order associated with STAB(:,s) and
%       PART(:,s) (see NIAK_PART2ORDER).
%
%   SIL
%       (matrix S*N) SIL(s,n) is the mean stability contrast associated with
%       STAB(:,s) and n clusters (the partition being defined using HIER{s}, 
%       see below).
%
%   INTRA
%       (matrix, S*N) INTRA(s,n) is the mean within-cluster stability
%       associated with STAB(:,s) and n clusters (the partition being defined 
%       using HIER{s}, see below).
%
%   INTER
%       (matrix, S*N) INTER(s,n) is the mean maximal between-cluster stability 
%       associated with STAB(:,s) and n clusters (the partition being defined 
%       using HIER{s}, see below).
%
%   HIER
%       (cell of array) HIER{S} is the hierarchy associated with STAB(:,s)
%
% OPT           
%   (structure) with the following fields:
%
%   NB_CLASSES
%       (vector of integer) the number of clusters (or classes) that will
%       be investigated. This parameter will overide the parameters
%       specified in CLUSTERING.OPT_CLUST
%
%   NB_SAMPS
%       (integer, default 100) the number of samples to use in the 
%       bootstrap Monte-Carlo approximation of stability.
%
%   NB_SAMPS_BIAS
%       (integer, default 100) the number of samples to derive the 
%       estimation of the bias on the distance between average 
%       responses under the null hypothesis of no significant 
%       average responses.
%
%   STD_NOISE
%       (integer, default 4) the standard deviation of the noise
%       added to each sample to cover up the effect of spatially
%       coherent spontaneous fluctuations.
%
%   SAMPLING
%
%       TYPE
%           (string, default 'bootstrap') how to resample the average FIR 
%           response.
%           Available options : 'bootstrap', 'subsample'
%
%       OPT
%           (structure) the options of the sampling. Depends on
%           OPT.SAMPLING.TYPE : 
%               'bootstrap' : none. It is an i.i.d. bootstrap.
%               'subsample' : a scalar representing the percentage of
%                   trials that are used to produce a sample of average
%                   response (default 0.5).
%
%   NORMALIZE
%       (structure, optional) the temporal normalization to apply on the 
%       FIR estimates, with the following options :
%
%       TYPE 
%           (string, default 'fir_shape') The type of temporal
%           normalization. Available options are : 
%           'fir' : correction to a zero mean at the beginning of the 
%                response.
%            'fir_shape' : correction to a zero mean at the beginning
%                of the response and a unit energy of the response.  
%
%       TIME_NORM
%           (scalar, default 1) the number of seconds of signal at the begining 
%           of each response which are used to set the baseline to zero.
%
%   CLUSTERING
%       (structure, optional) with the following fields :
%
%       TYPE
%           (string, default 'hierarchical') the clustering algorithm
%           Available options : 'hierarchical'
%
%       OPT
%           (structure, optional) options that will be  sent to the
%           clustering command. The exact list of options depends on
%           CLUSTERING.TYPE:
%               'hierarchical' : see OPT in NIAK_HIERARCHICAL_CLUSTERING
%
%   CONSENSUS
%       (structure, optional) This structure describes
%       the clustering algorithm used to estimate a consensus clustering on 
%       each stability matrix, with the following fields :
%
%       TYPE
%           (string, default 'hierarchical') the clustering algorithm
%           Available options : 'hierarchical'
%
%       OPT
%           (structure, default see NIAK_HIERARCHICAL_CLUSTERING) options 
%           that will be  sent to the  clustering command. The exact list 
%           of options depends on CLUSTERING.TYPE:
%              'hierarchical' : see NIAK_HIERARCHICAL_CLUSTERING
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
% The input file also has to contain a variable TIME_SAMPLES that is used
% to determine the parameters of the temporal normalization of the FIR
% response. TIME_SAMPLES(T) is the time associated with the Tth row of 
% FIR_ALL. Note that time 0 would correspond to the event time.
%
% Copyright (c) Pierre Bellec, Centre de recherche de l'institut de 
% Gériatrie de Montréal, Département d'informatique et de recherche 
% opérationnelle, Université de Montréal, 2010.
% Maintainer : pbellec@criugm.qc.ca
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
    error('niak:brick','syntax: [FILES_IN,FILES_OUT,OPT] = NIAK_BRICK_STABILITY_FIR(FILES_IN,FILES_OUT,OPT).\n Type ''help niak_brick_stability_fir'' for more info.')
end
   
%% Files in
if ~ischar(files_in)
    error('FILES_IN should be a string!')
end

%% Files out
if ~ischar(files_out)
    error('FILES_OUT should be a string!')
end

%% Options
opt_normalize.type   = 'fir_shape';
opt_normalize.time_norm    = 1;
opt_clustering.type = 'hierarchical';
opt_clustering.opt  = struct();
opt_sampling.type   = 'bootstrap';
opt_sampling.opt    = [];
opt_consensus.type   = 'hierarchical';
list_fields   = {'std_noise' , 'nb_samps_bias' , 'rand_seed' , 'normalize'   , 'nb_samps' , 'nb_classes' , 'clustering'   , 'sampling'   , 'consensus'   , 'flag_verbose' , 'flag_test'  };
list_defaults = {4           , 100             , []          , opt_normalize , 100        , NaN          , opt_clustering , opt_sampling , opt_consensus , true           , false        };
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
load(files_in)

%% Stability analysis
opt_s = rmfield(opt,{'flag_test','consensus','rand_seed'});
[stab,bias_mean,bias_std,plugin] = niak_stability_fir(fir_all,time_samples,opt_s);

%% Consensus clustering
opt_c.clustering = opt.consensus;
opt_c.flag_verbose = opt.flag_verbose;
[part,order,sil,intra,inter,hier] = niak_consensus_clustering(stab,opt_c);

%% Save outputs
if opt.flag_verbose
    fprintf('Save outputs ...\n');
end
nb_classes = opt.nb_classes;
save(files_out,'stab','nb_classes','part','hier','order','sil','intra','inter','bias_mean','bias_std','plugin')
