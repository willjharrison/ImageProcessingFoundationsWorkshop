function makeImsBlackAndWhite(folder,imExt)

files = dir([folder '*' imExt]);

for fileLoop = 1:length(files)

    thisFile = fullfile(folder,files(fileLoop).name);
    thisIm = imread(thisFile);
    thisIm = rgb2gray(thisIm);
    thisIm = double(thisIm);
    thisIm = thisIm / 255;

    newFilename = ['bw_' files(fileLoop).name];

    imwrite(thisIm, fullfile(folder,newFilename));

end