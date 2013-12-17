function [part,gi,mse] = niak_neural_gas(data,opt);
%
% _________________________________________________________________________
% SUMMARY NIAK_NEURAL_GAS
%
% Neural-gas clustering, as implemented in the "Sparse Coding Neural Gas"
% toolbox :
% http://www.inb.uni-luebeck.de/tools-demos/scng
%
% SYNTAX:
% [PART,GI,I_INTRA,I_INTER] = NIAK_NEURAL_GAS(DATA,OPT);
%
% _________________________________________________________________________
% INPUTS:
%
% DATA
%       (2D array T*N)
%
% OPT
%       (structure) with the following fields (absent fields will be
%       assigned a default value):
%
%       NB_CLASSES
%           (integer) number of clusters
%
%       NB_EPOCHS
%           (integer, default 1)  number of training epochs (number of 
%           training iterations = epochs *  size of data)
%
%       ALPHA0
%           (real value, default ?) initial learining rate.
%
%       LAMBDA0
%           (real value, default ?)  initial neighbourhood-size.
%
%
%       FLAG_VERBOSE
%           (boolean, default 1) if the flag is 1, then the function prints
%           some infos during the processing.
%
% _________________________________________________________________________
% OUTPUTS:
%
% PART
%       (vector N*1) partition (find(part==i) is the list of regions belonging
%       to cluster i.
%
% GI
%       (2D array) gi(:,i) is the center of gravity of cluster i.
%
% MSE
%       (real value) mean squared error.
%
% _________________________________________________________________________
% SEE ALSO:
% 
% NIAK_KMEANS_CLUSTERING, NIAK_HIERARCHICAL_CLUSTERING
% _________________________________________________________________________
% COMMENTS:
%
% NOTE 1:
%
%   This function is just a "NIAKified" wrap around the NG.m function from
%   the "Sparse Coding Neural Gas" toolbox :
%   http://www.inb.uni-luebeck.de/tools-demos/scng
%
%   The function needs the toolbox to be installed in order to operate. 
%
% NOTE 2:
%   See the following reference for a description of neural-gas :
%
%   T. M. Martinetz, S. G. Berkovich, K. J. Schulten. "Neural-gas" network 
%   for vector quantization and its application to time-series prediction. 
%   IEEE transactions on neural networks / a publication of the IEEE Neural 
%   Networks Council In Neural Networks, IEEE Transactions on, Vol. 4, 
%   No. 4. (1993), pp. 558-569.
%
% Copyright (c) Pierre Bellec, Montreal Neurological Institute, 2009.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : Neural-gas, clustering

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

%% Options
gb_name_structure = 'opt';
gb_list_fields = {'nb_classes','nb_epochs','alpha0','lambda0','flag_verbose'};
gb_list_defaults = {NaN,1,[],[],true};
niak_set_defaults

if isempty(alpha0)
    [gi,part,mse] = NG(data,nb_classes,nb_epochs);
else
    if isempty(lambda0)
        [gi,part,mse] = NG(data,nb_classes,nb_epochs,alpha0);
    else
        [gi,part,mse] = NG(data,nb_classes,nb_epochs,alpha0,lambda0);
    end
end
part = part + 1; % Assign the labels from 1 to the number of clusters
