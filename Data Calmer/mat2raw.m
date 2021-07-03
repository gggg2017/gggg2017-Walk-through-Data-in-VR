mat_folder = {pwd};

Fs = 1000;              % smaple rate
start_extract_hour = 0.5;
extract_hour = 3;
start_extract_index = start_extract_hour * 60 * 60 * Fs;
end_extract_index = (start_extract_hour + extract_hour) * 60 * 60 * Fs;
extract_data_length = end_extract_index - start_extract_index;

%ii=1;
for ii=1:length(mat_folder)
	fn_lst = dir(fullfile(mat_folder{ii}, '*.mat'));
%jj=3;
	for j=1:length(fn_lst)
        mat_fn = fullfile(mat_folder{ii}, fn_lst(jj).name);
        load(mat_fn);
        [p f] = fileparts(mat_fn);
        jpg_fn = fullfile(mat_folder{ii}, [f '.jpg']);

        % check the number of data collected in each mat
        % data_size = size(acq.data);
        % mat_data_size(j) = data_size(1);

        data = acq.data(start_extract_index:end_extract_index-1);

        % apply FFT
        data_noiseremoved = FFT_ECG (data);
      
        % find peaks of each cycle
        MinPD = 300;
        [pks,locs] = findpeaks(data_noiseremoved,'MinPeakDistance',MinPD);
        cycles = diff(locs);
        meanCycle = mean(cycles);
        NumCycles = numel(pks);
        
        % convert data into 2-D array 20000x20000
        NumCol = 20000;
        NumPeaks_perRow = 40;        % user-defined parameter
        NumRow = ceil(NumCycles/NumPeaks_perRow);
        NumDuplicate = 30;
        NumTerrain = floor((NumRow * NumDuplicate)/NumCol) + 1;

        pwave = 0.6;                % estimated length in % for p wave between two peaks
        data_start(1) = floor(pwave * locs(1) + (1-pwave) * locs(2));

        offset = 0;               % define the offset when display data in Unity
        
        data_start = floor(pwave * locs(1) + (1-pwave) * locs(2));
        data_end =  floor(locs(NumCycles-1) + (1-pwave) * (locs(NumCycles)-locs(NumCycles-1)));
        
        raw = zeros(NumRow, NumCol);
        for i = 1:NumRow
            row_start_loc_index(i) = floor(pwave * locs(1 + NumPeaks_perRow*(i-1)) + (1-pwave) * locs(2 + NumPeaks_perRow*(i-1)));
            
            if (2 + NumPeaks_perRow*(i) > NumCycles)
                row_end_loc_index(i) =  data_end;
            else
                row_end_loc_index(i) = floor(locs(1 + NumPeaks_perRow*(i)) + (1-pwave) * (locs(2 + NumPeaks_perRow*(i))-locs(1 + NumPeaks_perRow*(i)))) - 1;
            end
            
            row_length(i) = row_end_loc_index(i) - row_start_loc_index(i);
            
            for j = 1:row_length(i)
                raw(i, j+floor((NumCol-row_length(i))/2)-1) = data_noiseremoved(row_start_loc_index(i)+j-1);
            end
        end
        
        % cross correlation with time shift based on the full trace in the previous row
        raw_aligned(1,:) = raw(1,:);
        for i = 2:NumRow
            [c,lags] = xcorr(raw(1,:), raw(i,:), ceil(meanCycle)*2, 'normalized');
            [x,y] = max(c);
            Li = lags(y);

            raw_aligned(i,:) = circshift(raw(i,:),Li);
        end
        
        % duplicate each row to evenly distribute data in the whole terrain
        raw_duplicated = zeros(NumCol, NumCol);
        for i = 1:NumRow
            for j = 1:NumDuplicate
                k = (i - 1) * NumDuplicate + j;
                raw_duplicated(k,:) = raw_aligned(i,:);
            end
        end
        
        image = mat2gray(raw_duplicated);
        imwrite(image,jpg_fn)

    end
end



% histogram(mat_data_size);

% plot(data(1:10000))
% % hold on
% % plot(data_noiseremoved(1:50000))
% % hold on
% % plot(locs(1:100),pks(1:100),'o')
% hold on
% plot(raw(1,:))
% hold on
% plot(raw(111,:))

% using FFT to remove certain noise from original data
function edited_data = FFT_ECG (original_data)
    Y = fft(original_data + 10);
    L = length(original_data);

    % low pass filter - cutoff frequency is 100 Hz where i = 1080000
    for i = 5080000:L
        Y(i) = 0;
    end
	% high pass filter to mitigate breathing impact
    for i = 5400:6480  % cutoff frequency is 0.5 ~ 0.6 Hz where i = 5400~6480
        Y(i) = 0;
    end
        
    edited_data = abs(ifft(Y)) - 10;
end