%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            VIDEO LECTURE DECONSTRUCTION             %
%                                                     %
%  This script takes video files (*.m4v files) and    %
%  scans for the moments when the lecturer changes    %
%  slides. Timestamps are saved in a *.txt file and   %
%  color images are extracted from those timepoints   %
%  so they can be printed out and written on.         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% clear memory of stored vars from previous run
clc; 
close all; 
clear all; 
workspace;

% CHANGE THESE VALUES FOR OPTOMIZING PROCESSING SPEED 
samplerate=152; %SAMPLE EVERY 150 FRAMES (15 seconds)
msethreshold=750;
resizedimensions = [50 80]; % [50 80] is starting compression

% prompt user for directory containing list of .m4v videos to process
fdir = uigetdir; 
myFiles = dir(fullfile(fdir,'*.m4v')); %gets all wav files in struct

% for each video file in the directory...e
for k = 1:length(myFiles)
  fname = myFiles(k).name;
  fpath = fullfile(fdir, fname);

  mov=VideoReader(fpath);       %set 'mov' as pointer variable to file
  nFrames=mov.NumberOfFrames;   %set 'nFrames' as total # of frames

nframesamples=nFrames/samplerate; %NUMBER OF SAMPLES
X=1;
Y=1;
Z=1;

for i=0:nframesamples-1
initialFrame=read(mov, i*samplerate+1);
finalFrame=read(mov, (i+1)*samplerate);
initialImage = imresize(initialFrame(:,:,1), resizedimensions);
finalImage = imresize(finalFrame(:,:,1), resizedimensions);

[rows columns] = size(initialImage);
mseImage = (double(initialImage) - double(finalImage)) .^ 2;
mse = sum(sum(mseImage)) / (rows * columns);
PSNR = 10 * log10( 256^2 / mse);

%%IF FRAMES 1 and 150 ARE DIFFERENT, TEST AT 75 FRAME INTERVAL (1/2
%%SAMPLERT)
    if mse > msethreshold  
        finalFrame=read(mov, (i*samplerate+ceil(samplerate/2)));
        finalImage=imresize(finalFrame(:,:,1), resizedimensions);
        
        [rows columns] = size(initialImage);
        mseImage = (double(initialImage) - double(finalImage)) .^ 2;
        mse = sum(sum(mseImage)) / (rows * columns);
        PSNR = 10 * log10( 256^2 / mse);
        
%%IF FRAMES 1 and 75 ARE DIFFERENT, TEST AT 38 FRAME INTERVAL (1/4
%%SAMPLERT)
            if mse>msethreshold 
                finalFrame=read(mov, (i*samplerate+ceil(samplerate/4)));
                finalImage=imresize(finalFrame(:,:,1), resizedimensions);
                
                [rows columns] = size(initialImage);
                mseImage = (double(initialImage) - double(finalImage)) .^ 2;
                mse = sum(sum(mseImage)) / (rows * columns);
                PSNR = 10 * log10( 256^2 / mse);                
                
%%IF FRAMES 1 and 38 ARE DIFFERENT, SETTLE FOR FRAME 38 BEING START POINT OF
%%DIFFERENCE
                if mse>msethreshold 
                     X(end+1)=i*samplerate+ceil(samplerate/4);  %building up my results matrix by adding frame# to the end of the matrix
                     Y(end+1)= mse;
                     Z(end+1)=PSNR;
                else
 %%IF FRAMES 1 and 38 ARE SAME, SETTLE FOR FRAME 72 BEING START POINT OF
%%DIFFERENCE                   
                     X(end+1)=i*samplerate+ceil(samplerate/2);  %building up my results matrix by adding frame# to the end of the matrix
                     Y(end+1)= mse;
                     Z(end+1)=PSNR;
                     
                end
                
%%IF FRAMES 1 and 75 ARE SAME, TEST AT 75+38 FRAME INTERVAL (3/4
%%SAMPLERT)
            else
                finalFrame=read(mov,i*samplerate+ceil(samplerate*3/4));
                finalImage=imresize(finalFrame(:,:,1), resizedimensions);
                
                [rows columns] = size(initialImage);
                mseImage = (double(initialImage) - double(finalImage)) .^ 2;
                mse = sum(sum(mseImage)) / (rows * columns);
                PSNR = 10 * log10( 256^2 / mse);      
    %%IF FRAMES 1 and 75+38 ARE DIFFERENT, SETTLE FOR FRAME 75+38 AS
    %%ORIGIN OF CHANGE
                if mse>msethreshold
                     X(end+1)=i*samplerate+ceil(samplerate*3/4);  %building up my results matrix by adding frame# to the end of the matrix
                     Y(end+1)= mse;
                     Z(end+1)=PSNR;                    
                else
   %%IF FRAMES 1 and 75+38 ARE SAME, SETTLE FOR FRAME 150 AS
    %%ORIGIN OF CHANGE
                     X(end+1)=ceil((i+1)*samplerate);  %building up my results matrix by adding frame# to the end of the matrix
                     Y(end+1)= mse;
                     Z(end+1)=PSNR;
                end
     
            end
    end
end


dlmwrite(sprintf('%s\\%s-timestamps.txt',fdir,fname),X)


initialFrame=read(mov, 1);
relframes=initialFrame(:,:,1);
mkdir(sprintf('%s\\%s.pages',fdir,fname))
for i=2:length(X)
    imwrite(read(mov, X(1,i)),sprintf('%s\\%s.pages\\%s-%i.jpeg',fdir,fname,fname,i))
end



end