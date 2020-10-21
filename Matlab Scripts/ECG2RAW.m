clc;clear;

L = 650000;             % Size of whole dataset
Total_time = 1805.231;   % Time length of whole dataset in seconds
Fs = L/Total_time;      % Sampling frequency   
T = 1/Fs;               % Sampling period       
t = (0:L-1)*T;          % Time vector

% define number of columns in a terrain
NumCol = 2048;

% read data from csv, only using MLII
data = csvread('112.csv',1,1);
data = data(:,1);

% apply FFT
data_noiseremoved = abs(FFT_ECG (data));

% find peaks of each cycle
[pks,locs] = findpeaks(data_noiseremoved,'MinPeakDistance',200);
cycles = diff(locs);
meanCycle = mean(cycles);
NumCycles = numel(pks);

% generate RR data from ECG data
% for i=2:NumCycles
%     RR(i-1,1) = (locs(i) - locs(i-1))/Fs;    
% end
% csvwrite('RR data.csv',RR);

% plot ECG data in time domain
% range = 2048;
% plot(t(1:range),data(1:range),t(locs(1:8)),pks(1:8),'or') 
% title('ECG data in time domain ')
% xlabel('t (s)')
% ylabel('MLII (mV)')
% legend('original ECG','ECG after filtering');
% axis tight

% plot(t(256000:260000),data(256000:260000),t(locs(1013:1030)),pks(1013:1030),'or') 
% title('ECG data in time domain ')
% xlabel('t (s)')
% ylabel('MLII (mV)')
% legend('original ECG','ECG after filtering');
% axis tight


% convert data into 2-D array
NumPeaks_perRow = 6;        % user-defined parameter
NumRow = ceil(NumCycles/NumPeaks_perRow);
NumDuplicate = 8;
NumTerrain = floor((NumRow * NumDuplicate)/NumCol) + 1;

pwave = 0.6;                % estimated length in % for p wave between two peaks
data_start(1) = floor(pwave * locs(1) + (1-pwave) * locs(2));

for i = 1:NumRow
     if ((NumPeaks_perRow*i + 2) <= NumCycles)
         data_end(i) = floor(pwave * locs(NumPeaks_perRow*i+1) + (1-pwave) * locs(NumPeaks_perRow*i+2));
     else
         data_end(i) = floor(pwave * locs(NumCycles-1) + (1-pwave) * locs(NumCycles));
     end
     data_length(i) = data_end(i) - data_start(i);
     data_zero(i) = NumCol - data_length(i);
     
     for j = 1:NumCol
         if j < data_zero(i)/2
             raw(i,j) = 0;
         elseif j > (NumCol - data_zero(i)/2)
             raw(i,j) = 0;
         else
             raw(i,j) = data_noiseremoved(data_start(i) + floor(j - data_zero(i)/2)) - 750;
         end
     end
     
     if i < NumRow
         data_start(i+1) = data_end(i) + 1;
     end
end

% cross correlation with time shift based on the full trace in the previous row
raw_aligned(1,:) = raw(1,:);
cycle = 200;
for i = 2:NumRow
    [c,lags] = xcorr(raw(i-1,:), raw(i,1:end-cycle * 2));
    [x,y] = max(c);
    Li = lags(y);
    
    raw_aligned(i,:) = circshift(raw(i,:),Li);
     
    if (Li >= 0)
        %raw_aligned(i,1:Li) = raw(i-1, end-Li+1:end);
        raw_aligned(i,1:Li) = 0;
    else
        %raw_aligned(i, end+Li+1:end) = raw(i+1, 1:-Li);
        raw_aligned(i, end+Li+1:end) = 0;
    end
end

% align the first peak in each row
% raw_aligned(1,:) = raw(1,:);
% [M,L] = max(raw(1,1:cycle));
% for i = 2:NumRow
%     [Mi,Li] = max(raw(i,1:cycle));
%     
%     raw_aligned(i,:) = circshift(raw(i,:),-Li+L);
%      
%     if (-Li+L >= 0)
%         raw_aligned(i,1:-Li+L) = raw(i-1, end+Li-L+1:end);
%     else
%         raw_aligned(i, end-Li+L+1:end) = raw(i+1, 1:Li-L);
%     end
% end


% duplicate each row to evenly distribute data in the whole terrain
for i = 1:NumRow
    for j = 1:NumDuplicate
        k = (i - 1) * NumDuplicate + j;
        raw_duplicated(k,:) = raw_aligned(i,:);
    end
end
% duplicate the rest terrain
rest = NumCol * NumTerrain -  NumRow * NumDuplicate;
for i = 1:rest
    raw_duplicated(NumDuplicate * NumRow + i,:) = raw_duplicated(NumDuplicate * NumRow,:);
end

% write terrain into raw files
for i = 1:NumTerrain
    cmodel = raw_duplicated(NumCol * i - NumCol + 1:NumCol * i,:);
    fid(i) = fopen(['terrain',num2str(i),'.raw'],'w+');
    cnt = fwrite(fid(i),cmodel,'uint8');
    fclose(fid(i));
end

% using FFT to remove certain noise from original data
function edited_data = FFT_ECG (original_data)
    Y = fft(original_data);
    L = length(original_data);

    % low pass filter - cutoff frequency is 100 Hz where i = 180527
    for i = 180527:L
        Y(i) = 0;
    end
	% high pass filter to mitigate breathing impact
    for i = 2:1806  % cutoff frequency is 1 Hz where i = 1806
        Y(i) = 0;
    end
    
    edited_data = ifft(Y);
end

% plot(raw_aligned(167,:)) 
% hold on
% plot(raw_aligned(168,:))
% title('ECG data in time domain ')
% xlabel('t (s)')
% ylabel('MLII (mV)')
% legend('167','168');
% axis tight

