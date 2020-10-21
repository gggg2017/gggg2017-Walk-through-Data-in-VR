clc;clear;

data = csvread('112.csv',1,1);

L = 650000;             % Length of signal
Fs = 360.06;           % Sampling frequency   
T = 1/Fs;              % Sampling period       
t = (0:L-1)*T;         % Time vector
f = Fs*(0:(L/2))/L;

original_data = data(:,1);
original_data = original_data(1:L);

% implement FFT
Y = fft(original_data);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

% low pass filter - cutoff frequency is 100 Hz where i = 180527
for i = 180527:L
    Y(i) = 0;
end
% high pass filter to mitigate breathing impact
for i = 2:1806  % cutoff frequency is 1 Hz where i = 1806
    Y(i) = 0;
end

edited_data = abs(ifft(Y));

% plot ECG data in time domain
range = 2048;
plot(t(1:range),original_data(1:range)) 
hold on
plot(t(1:range),edited_data(1:range)) 
title('ECG data in time domain ')
xlabel('t (s)')
ylabel('MLII (mV)')
legend('original ECG','ECG after filtering');

% plot FFT (frequency domain)
% plot(f(1:1806),P1(1:1806)) 
% title('Single-Sided Amplitude Spectrum of S(t)')
% xlabel('f (Hz)')
% ylabel('|P1(f)|')


