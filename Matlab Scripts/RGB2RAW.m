clc;clear;

Nkeep=256;  % size to keep

original = imread('518x470x3.jpg');

% [a,b,c]=size(original);
% 
% for i = 1:a
%     for j = 1:b
%         converted(i,j) = 0.3*original(i,j,1) + 0.59*original(i,j,2) + 0.11*original(i,j,3);
%     end
% end

converted = rgb2gray(original);

converted_cropped = converted (1:Nkeep,1:Nkeep);

cmodel = converted_cropped;
fid=fopen('518x470x3.raw','w+');
cnt=fwrite(fid,cmodel,'uint8');
fclose(fid);