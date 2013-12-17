%
% _________________________________________________________________________
% SUMMARY NIAK_DEMO_FIR_SIMUS
%
% This is a script to demonstrate the usage of :
% NIAK_BUILD_FIR
%
% SYNTAX:
% Just type in NIAK_DEMO_FIR_SIMUS
%
% _________________________________________________________________________
% OUTPUT
%
% The demo will generate two groups of 100 time series with 200 time
% points each. The first group includes the hemodynamic response to ten
% events, as generated using a parametric model (see NIAK_FMRIDESIGN).
%
% A FIR estimate of the response will be derived for both groups based on
% the event times.
%
% _________________________________________________________________________
% COMMENTS
%
% NOTE 1
% This script will clear the workspace !!
%
% _________________________________________________________________________
% Copyright (c) Pierre Bellec, Montreal Neurological Institute, 2008.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : fMRI, HRF, FIR

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

clear

%% Generate simulated HRF
time_events = 0:20:180;
duration_events = 1;
opt_design.events = [ones([length(time_events) 1]) time_events(:) duration_events*ones([length(time_events) 1])];
opt_design.frame_times = 0:199;
opt_design.slice_times = 0;
X_cache = niak_fmridesign(opt_design);
response = squeeze(X_cache.x(:,1,1));

%% Generate time series
sig = 0.5;
max_r = max(response);
response = response/max_r;
tseries = zeros([200 5]);
tseries(:,1:5) = repmat(response,[1 5]) + sig * randn([200 5]);
tseries(:,6:10) = sig * randn([200 5]);

%% run the estimation
opt_fir.time_frames = opt_design.frame_times;
opt_fir.time_events = opt_design.events(:,2);
opt_fir.time_window = 10;
opt_fir.time_sampling = 0.5;
opt_fir.interpolation = 'linear';
[fir_mean,fir_std,fir_all,time_samples] = niak_build_fir(tseries,opt_fir);

%% Make a nice figure : time series
figure
subplot(1,2,1)
plot(opt_fir.time_frames,tseries(:,1:5))
axis([0 199 -1 2.5])
subplot(1,2,2)
plot(opt_fir.time_frames,tseries(:,6:10))
axis([0 199 -1.5 2.5])

%% Make a nice figure : FIR estimates
figure
opt_design.frame_times = time_samples;
opt_design.events = [1 0 duration_events];
X_cache = niak_fmridesign(opt_design);
hrf = squeeze(X_cache.x(:,1,1));
hrf = hrf/max(hrf);
for num_s = 1:size(fir_mean,2)
    subplot(2,size(fir_mean,2)/2,num_s)
    if num_s<=(size(fir_mean,2)/2)
        plot(time_samples,hrf);
    else
        plot(time_samples,zeros(size(time_samples)));
    end
    hold on
    axis([0 10 -1 2])
    errorbar(time_samples',fir_mean(:,num_s),2*fir_std(:,num_s),'r')
end