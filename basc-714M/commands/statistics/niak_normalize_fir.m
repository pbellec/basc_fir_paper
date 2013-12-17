function fir_c = niak_normalize_fir(fir,opt)
% Normalize finite-impulse response functions
%
% SYNTAX:
% FIR_C = NIAK_NORMALIZE_FIR(FIR,OPT)
%
% _________________________________________________________________________
% INPUTS:
%
% FIR
%    (array T*N) T time samples, N regions. Each column is 
%    a (mean) response to a stimulus in a brain region.
%
% OPT
%    (structure) with the following fields:
%
%    TYPE
%        (string) the type of applied normalization of the response. 
%        Available options:
%        'fir' : correction to a zero mean at the beginning of the 
%            response.
%        'fir_shape' : correction to a zero mean at the beginning
%            of the response and a unit energy of the response.  
%        'none' : no correction at all
%    
%    TIME_SAMPLING
%        (scalar) the time between two samples of the response.
%    
%    TIME_NORM
%        (scalar) the number of seconds of signal at the begining of 
%        each response which are used to set the baseline to zero.
%
% _________________________________________________________________________
% OUTPUTS:
%
% FIR_C
%    (array, T*N) same as FIR, expect that each FIR has been normalized.
%
% _________________________________________________________________________
% EXAMPLE:
% fir = randn([20 100]) + (1:20)'*(1+0.5*rand([1 100])) + 20*ones([20 1])*rand([1 100]);
% subplot(1,3,1)
% plot(fir)
% title('Raw responses')
% opt.type = 'fir';
% opt.time_sampling = 0.5;
% opt.time_norm = 2;
% fir_c = niak_normalize_fir (fir,opt);
% subplot(1,3,2)
% plot(fir_c)
% title('''fir'' normalization')
% opt.type = 'fir_shape';
% fir_c = niak_normalize_fir (fir,opt);
% subplot(1,3,3)
% plot(fir_c)
% title('''fir\_shape'' normalization')
% _________________________________________________________________________
% SEE ALSO:
% NIAK_PIPELINE_STABILITY_FIR, NIAK_STABILITY_FIR, NIAK_BRICK_FIR, 
% NIAK_BRICK_FIR_TSERIES
%
% _________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Pierre Bellec
% Département d'informatique et de recherche opérationnelle
% Centre de recherche de l'institut de Gériatrie de Montréal
% Université de Montréal, 2011
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : statistics, correlation

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

if strcmp(opt.type,'none')
    fir_c = fir;
    return
end
nb_vol = ceil(opt.time_norm/opt.time_sampling);
fir_c = fir - repmat(mean(fir(1:nb_vol,:),1),[size(fir,1) 1]);
if strcmp(opt.type,'fir_shape')        
    weights = repmat(sqrt(sum(fir_c.^2,1)*opt.time_sampling),[size(fir_c,1) 1]);
    fir_c = fir_c./weights;
elseif strcmp(opt.type,'fir')
else
    error('%s is an unknown type of normalization',opt.type);
end
