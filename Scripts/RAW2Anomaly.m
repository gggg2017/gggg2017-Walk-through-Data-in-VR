


% highlight the anomalies in red and write into pictures
anomaly = cat(3,planeR((i-1)*NumCol+1:(i-1)*NumCol+NumCol,:), planeG((i-1)*NumCol+1:(i-1)*NumCol+NumCol,:), planeB((i-1)*NumCol+1:(i-1)*NumCol+NumCol,:));
jpgFileName = strcat('112.', num2str(i),'_anomaly.jpg');
imwrite(anomaly,jpgFileName,'jpg','Comment','My JPEG file');  
