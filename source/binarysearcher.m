%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            VIDEO LECTURE DECONSTRUCTION             %
%                                                     %
%  This script takes video files (*.m4v files) and    %
%  scans for the moments when the lecturer changes    %
%  slides. Timestamps are saved in a *.txt file and   %
%  color images are extracted from those timepoints   %
%  so they can be printed out and written on.         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic
%% reset memory of stored vars from previous run
clc; 
close all; 
clear all; 
workspace;

%% CHANGE THESE VALUES FOR OPTIMIZING PROCESSING SPEED 
sampleinterval=600; %SAMPLE EVERY 150 FRAMES (15 seconds)
msethreshold=1;
resizedimensions = [50 80]; % [50 80] is starting compression


%% prompt user for directory containing list of .m4v videos to process
fdir = uigetdir; 
myFiles = dir(fullfile(fdir,'*.m4v')); %gets all wav files in struct

%% for each video file in the directory...
for k = 1:length(myFiles)
  fname = myFiles(k).name;
  fpath = fullfile(fdir, fname);

  mov=VideoReader(fpath);       %set 'mov' as pointer variable to file
  nFrames=mov.NumberOfFrames;   %set 'nFrames' as total # of frames
  nframesamples=floor(nFrames/sampleinterval); %NUMBER OF SAMPLES
  X=zeros(1,500); %pre-allocating memory for results array X as large matrix to incrs process speed
  initialframe=1;
  X(1)=initialframe;
  loopcount=2;

  %% FRAME CHANGE DETECTION VIA BINARY SEARCH
while (initialframe+sampleinterval<nFrames)

    initialImage=rgb2gray(imresize(read(mov, initialframe),resizedimensions));
   
   if(framecomparison(mov,initialImage,initialframe+sampleinterval, resizedimensions, msethreshold)==1)
       %if != @ max int, test @ int/2
       %|-------------|-------------^-------------|-------------|
       if(framecomparison(mov,initialImage,initialframe+floor(sampleinterval*4/8), resizedimensions, msethreshold)==1) 
           %if != @ int/2, test @ int/4 
           %|-------------^-------------|-------------|-------------|
           if(framecomparison(mov,initialImage,initialframe+floor(sampleinterval*2/8), resizedimensions, msethreshold)==1) 
               %if != @ int/4, test @ int/8
               %|------^-------|-------------|-------------|-------------|
               if(framecomparison(mov,initialImage,initialframe+floor(sampleinterval*1/8), resizedimensions, msethreshold)==1) 
                   %if != @ int/8, SET new initial frame to initialframe+sampleinterval*1/16
                   %|--*-----------|-------------|-------------|-------------|
                   framechanged=initialframe+floor(sampleinterval*1/16);
                   X(loopcount) = framechanged;
                   loopcount=loopcount+1;
                   initialframe=framechanged;
               else
                   %if == @ int/8, SET new initial frame to initialframe+sampleinterval*3/16
                   %|----------*---|-------------|-------------|-------------|
                   framechanged=initialframe+floor(sampleinterval*3/16);
                   X(loopcount) = framechanged;
                   loopcount=loopcount+1;
                   initialframe=framechanged;
               end           
           else
               %if == @ int/4, test @ int*3/8
                %|-------------|------^-------|-------------|-------------|
               if(framecomparison(mov,initialImage,initialframe+floor(sampleinterval*3/8), resizedimensions, msethreshold)==1) 
                   %if != @ int*3/8, SET new initial frame to initialframe+sampleinterval*5/16
                   %|--*-----------|---*----------|-------------|-------------|
                   framechanged=initialframe+floor(sampleinterval*5/16);
                   X(loopcount) = framechanged;
                   loopcount=loopcount+1;
                   initialframe=framechanged;
               else
                   %if == @ int/8, SET new initial frame to initialframe+sampleinterval*7/16
                   %|----------*---|----------*---|-------------|-------------|
                   framechanged=initialframe+floor(sampleinterval*7/16);
                   X(loopcount) = framechanged;
                   loopcount=loopcount+1;
                   initialframe=framechanged;
               end                 
          
           end        
       else
           %if == @ int/2, test @ int*3/4
           %|-------------|-------------|-------------^-------------|
           if(framecomparison(mov,initialImage,initialframe+floor(sampleinterval*3/4), resizedimensions, msethreshold)==1)
               %if != @ int*3/4, test @ int*5/8
               %|-------------|-------------|------^-------|-------------|
               if(framecomparison(mov,initialImage,initialframe+floor(sampleinterval*5/8), resizedimensions, msethreshold)==1)
                   %if != @ int*5/8, SET new initial frame to initialframe+sampleinterval*9/16
                   %|-------------|-------------|---*----------|-------------|
                       framechanged=initialframe+floor(sampleinterval*9/16);
                       X(loopcount) = framechanged;
                       loopcount=loopcount+1;
                       initialframe=framechanged;
               else
                   %if == @ int*5/8, SET new initial frame to initialframe+sampleinterval*11/16
                   %|-------------|-------------|----------*---|-------------| 
                       framechanged=initialframe+floor(sampleinterval*11/16);
                       X(loopcount) = framechanged;
                       loopcount=loopcount+1;
                       initialframe=framechanged;
               end
           else 
               %if == @ int*3/4, test @ int*7/8
               %|-------------|-------------|-------------|-------^------|
               if(framecomparison(mov,initialImage,initialframe+floor(sampleinterval*7/8), resizedimensions, msethreshold)==1)
                      %if != @ int*7/8, SET new initial frame to initialframe+sampleinterval*13/16
                      %|-------------|-------------|-------------|---*----------| 
                      framechanged=initialframe+floor(sampleinterval*13/16);
                       X(loopcount) = framechanged;
                       loopcount=loopcount+1;
                       initialframe=framechanged;
               else
                      %if == @ int*7/8, SET new initial frame to initialframe+sampleinterval*15/16
                      %|-------------|-------------|-------------|----------*---| 
                      framechanged=initialframe+floor(sampleinterval*15/16);
                       X(loopcount) = framechanged;
                       loopcount=loopcount+1;
                       initialframe=framechanged;
                       
               end
           end
       end
   else
                      %if == @ int, SET new initial frame to initialframe+sampleinterval*15/16
                      %|-------------|-------------|-------------|-------------^
                      % BUT DO NOT WRITE THE NEWFRAME# INTO ARRAY X!
                       framechanged=initialframe+sampleinterval;
                       initialframe=framechanged;        
   end
   
end
X(loopcount)=nFrames; %last frame is the last 'frame change'

% remove excess array elements in X that were pre-allocated for memory
remove=loopcount+1:length(X);
X(remove)=[];


%% quality control
i=1
while i<length(X)
 if (mean2(rgb2gray(imresize(read(mov, X(i)), resizedimensions ))-rgb2gray(imresize(read(mov, X(i+1)), resizedimensions))) < msethreshold)
    X(i)=[];
 else
     i=i+1;
 end
end

%% write to file
dlmwrite(sprintf('%s\\%s-timestamps.txt',fdir,fname),X)

initialFrame=read(mov, 1);
relframes=initialFrame(:,:,1);
mkdir(sprintf('%s\\%s.pages',fdir,fname))
for i=2:length(X)
    imwrite(read(mov, X(1,i)),sprintf('%s\\%s.pages\\%s-%i.jpeg',fdir,fname,fname,i))
end

end
toc

