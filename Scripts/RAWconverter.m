clc;clear;

B = imread('test2.gif');

cmodel=B;
fid=fopen('test2.raw','w+');
cnt=fwrite(fid,cmodel,'uint8');
fclose(fid);