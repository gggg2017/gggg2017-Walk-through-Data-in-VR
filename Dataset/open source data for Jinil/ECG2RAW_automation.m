clc;clear;

L = 650000;             % Size of whole dataset
Total_time = 1805.231;   % Time length of whole dataset in seconds
Fs = L/Total_time;      % Sampling frequency   
T = 1/Fs;               % Sampling period       
t = (0:L-1)*T;          % Time vector

% define number of columns in a terrain
NumCol = 2048;

for index_csvFile = 100 : 234
    csvFileName = [num2str(index_csvFile) '.csv'];
	if isfile(csvFileName)
		% read data from csv, only using MLII
        data = csvread(csvFileName,1,1);
        data = data(:,1);
	else
		fprintf('File %s does not exist.\n', csvFileName);
    end
    


% apply FFT
data_noiseremoved = abs(FFT_ECG (data));

% find peaks of each cycle
MinPD = 200;
[pks,locs] = findpeaks(data_noiseremoved,'MinPeakDistance',MinPD);
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

offset = 750;               % define the offset when display data in Unity

for i = 1:NumRow
     if ((NumPeaks_perRow*i + 2) <= NumCycles)
         data_end(i) = floor(pwave * locs(NumPeaks_perRow*i+1) + (1-pwave) * locs(NumPeaks_perRow*i+2));
     else
         data_end(i) = floor(pwave * locs(NumCycles-1) + (1-pwave) * locs(NumCycles));
     end
     data_length(i) = data_end(i) - data_start(i);
     data_zero(i) = NumCol - data_length(i);
          
     if i < NumRow
         data_start(i+1) = data_end(i) + 1;
     end
end

for i = 1:NumRow
    data_start_value(i) = data_noiseremoved(data_start(i));
    data_end_value(i) = data_noiseremoved(data_end(i));
end

median_start = median(data_start_value);
median_end = median(data_end_value);

for i = 1:NumRow
    for j = 1:NumCol
         if j < data_zero(i)/2
             raw(i,j) = median_start - offset;
         elseif j > (NumCol - data_zero(i)/2)
             raw(i,j) = median_end - offset;
         else
             raw(i,j) = data_noiseremoved(data_start(i) + floor(j - data_zero(i)/2)) - offset;
         end
     end
end

% cross correlation with time shift based on the full trace in the previous row
raw_aligned(1,:) = raw(1,:);
for i = 2:NumRow
    [c,lags] = xcorr(raw(i-1,:), raw(i,:));
    [x,y] = max(c);
    Li = lags(y);
    
    raw_aligned(i,:) = circshift(raw(i,:),Li);
     
    if (Li >= 0)
        raw_aligned(i,1:Li) = median_start - offset;
    else
        raw_aligned(i, end+Li+1:end) = median_end - offset;
    end
end

% invert the terrain for display purpose
for i = 1:NumRow
    for j = 1:NumCol
        raw_inverted(i,j) = raw_aligned(i,NumCol-j+1);
    end
end

% duplicate each row to evenly distribute data in the whole terrain
for i = 1:NumRow
    for j = 1:NumDuplicate
        k = (i - 1) * NumDuplicate + j;
        raw_duplicated(k,:) = raw_inverted(i,:);
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
    fid(i) = fopen([num2str(index_csvFile),'_',num2str(i),'.raw'],'w+');
    cnt = fwrite(fid(i),cmodel,'uint8');
    fclose(fid(i));
end

%{
% generate the location of peak points for anomaly analysis
% remove the last 2 rows data for accuracy
[m,n] = size (raw_duplicated);
% initial the anomaly map to white (1,1,1)
planeR = zeros(m,n)+1;
planeG = zeros(m,n)+1;
planeB = zeros(m,n)+1;

[m,n] = size (raw_inverted);
locs = zeros(m-2,NumPeaks_perRow);

for i = 1:NumRow-2
    [pks,locs(i,:)] = findpeaks(raw_inverted(i,:),'MinPeakDistance',MinPD); 
end

[m,n] = size (locs);
length_anomaly = 300;
for j = 1:NumPeaks_perRow
    x = 1:m; 
    y = locs(:,j)'; 
    [p,S] = polyfit(x,y,2);

    [y_fit,delta] = polyval(p,x,S);
    
    for i = 1:NumRow-2
        if (y(i) >  y_fit(i) + 2*delta) | (y(i) <  y_fit(i) - 2*delta)
            for h = 1:NumDuplicate
                for k = 1:length_anomaly
                    % highlight the abnomalies in red (1,0,0)
                    planeG (i*NumDuplicate-1+h, y(i)-length_anomaly/2 + k) = 0;
                    planeB (i*NumDuplicate-1+h, y(i)-length_anomaly/2 + k) = 0;
                end
            end
        end
    end
end

% highlight the anomalies in red and write into pictures
for i = 1:NumTerrain
    anomaly = cat(3,planeR((i-1)*NumCol+1:(i-1)*NumCol+NumCol,:), planeG((i-1)*NumCol+1:(i-1)*NumCol+NumCol,:), planeB((i-1)*NumCol+1:(i-1)*NumCol+NumCol,:));
    jpgFileName = strcat('112.', num2str(i),'_anomaly.jpg');
    imwrite(anomaly,jpgFileName,'jpg','Comment','My JPEG file');  
end
%}

% plot(x,y,'bo')
% hold on
% plot(x,y_fit,'r-')
% plot(x,y_fit+2*delta,'m--',x,y_fit-2*delta,'m--')
% title('Linear Fit of Data with 95% Prediction Interval')
% legend('Data','Linear Fit','95% Prediction Interval')

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




