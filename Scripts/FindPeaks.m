clc;clear;

data = csvread('112.csv',1,1);
data = data(:,1);

L = 650000;             % Length of signal
Fs = 360.06;           % Sampling frequency   
T = 1/Fs;              % Sampling period       
t = (0:L-1)*T;         % Time vector


[pks,locs] = findpeaks(data,'MinPeakDistance',200);

% plot ECG data in time domain
range = 1000;
plot(t(1:range),data(1:range),t(locs(1:4)),pks(1:4),'or') 
title('ECG data in time domain ')
xlabel('t (s)')
ylabel('MLII (mV)')
legend('original ECG','ECG after filtering');
axis tight