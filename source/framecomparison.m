function output = framecomparison(mov,iImage,fframe, imgcompression,msethreshold)

fImage=rgb2gray(imresize(read(mov, fframe), imgcompression));

%[rows, columns] = size(iImage(:,:,1));
%mseImage = (double(iImage(:,:,1)) - double(fImage(:,:,1))) .^ 2;
%mse = sum(sum(mseImage)) / (rows * columns);
%PSNR = 10 * log10( 256^2 / mse);


mse = mean2(fImage-iImage);

if(mse>=msethreshold)
    output=1; %different
else
    output=0; %same
end
