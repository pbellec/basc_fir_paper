function [files_in,files_out,opt] = niak_brick_stability_glm(files_in,files_out,opt)
% Estimate the stability of a clustering on linear model coefficients.
%
% SYNTAX:
% [FILES_IN,FILES_OUT,OPT] = NIAK_BRICK_STABILITY_GLM(FILES_IN,FILES_OUT,OPT)
%
% _________________________________________________________________________
% INPUTS:
%
% FILES_IN 
%   (cell of strings) each entry is the name of a .mat file (generally
%   generated through NIAK_BRICK_STABILITY_GLM_CORES, with one variable
%   STAB (the vectorized stability matrices at every scales), one
%   variable NB_SAMPS (the number of employed samples) and one
%   variable NB_CLASSES (the employed numbers of clusters, or scales).
%   The number of classes needs to be identical for all files (but notice
%   the number of samples).
%
% FILES_OUT
%   (string) A .mat file which contains the following variables :
%
%   STAB
%       (array) STAB(:,s) is the vectorized version of the stability matrix
%       associated with OPT.NB_CLASSES(s) clusters.
%
%   NB_CLASSES
%       (vector) Identical to NB_CLASSES in FILES_IN (see above).
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
%   FLAG_TEST
%       (boolean, default 0) if the flag is 1, then the function does not
%       do anything but update the defaults of FILES_IN, FILES_OUT and OPT.
%
%   FLAG_VERBOSE 
%       (boolean, default 1) if the flag is 1, then the function prints 
%       some infos during the processing.
%
% _________________________________________________________________________
% OUTPUTS:
%
% The structures FILES_IN, FILES_OUT and OPT are updated with default
% valued. If OPT.FLAG_TEST == 0, the specified outputs are written.
%
% _________________________________________________________________________
% SEE ALSO:
% NIAK_PIPELINE_STABILITY_GLM
%
% _________________________________________________________________________
% COMMENTS:
%
% For more details, see the description of the stability analysis on a
% individual fMRI time series in the following reference :
%
% P. Bellec; P. Rosa-Neto; O.C. Lyttelton; H. Benalib; A.C. Evans,
% Multi-level bootstrap analysis of stable clusters in resting-State fMRI. 
% Neuroimage 51 (2010), pp. 1126-1139 
%
% Copyright (c) Pierre Bellec, Centre de recherche de l'institut de 
% Gériatrie de Montréal, Département d'informatique et de recherche 
% opérationnelle, Université de Montréal, 2010.
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : clustering, stability, GLM, functional connectivity

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialization and syntax checks %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Syntax
if ~exist('files_in','var')|~exist('files_out','var')|~exist('opt','var')
    error('niak:brick','syntax: [FILES_IN,FILES_OUT,OPT] = NIAK_BRICK_STABILITY_GLM(FILES_IN,FILES_OUT,OPT).\n Type ''help niak_brick_stability_glm'' for more info.')
end

%% Files in
if ~iscellstr(files_in)
    error('FILES_IN should be a cell of strings')
end

%% Files out
if ~ischar(files_out)
    error('FILES_OUT should be a string!')
end

%% Options
opt_consensus.type   = 'hierarchical';
list_fields   = { 'consensus'   , 'flag_verbose' , 'flag_test'  };
list_defaults = { opt_consensus , true           , false        };
opt = psom_struct_defaults(opt,list_fields,list_defaults);

%% If the test flag is true, stop here !
if opt.flag_test == 1
    return
end

%% Stability matrix

if opt.flag_verbose
    fprintf('Reading stability matrices ...\n');
end
for num_f = 1:length(files_in)
    if opt.flag_verbose
        fprintf('    %s ...\n',files_in{num_f});
    end
    data = load(files_in{num_f});
    if num_f == 1
        stab = data.stab * data.nb_samps;
        nb_classes = data.nb_classes;
        nb_samps = data.nb_samps;
    else
        if ~psom_cmp_var(nb_classes,data.nb_classes)
            error('All entries of FILES_IN should have identical NB_CLASSES');
        end
        stab = stab + data.stab * data.nb_samps;
        nb_samps = nb_samps + data.nb_samps;
    end
end
stab = stab/nb_samps;

%% Consensus clustering
if opt.flag_verbose
    fprintf('Consensus clustering ...\n');   
end
opt_c.clustering = opt.consensus;
opt_c.flag_verbose = opt.flag_verbose;
[part,order,sil,intra,inter,hier] = niak_consensus_clustering(stab,opt_c);

%% Save outputs
if opt.flag_verbose
    fprintf('Save outputs ...\n');
end
save(files_out,'stab','nb_classes','part','hier','order','sil','intra','inter')
