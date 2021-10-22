% Extract image statistics

% Initialize directories
% Current Directory - Location of Script
currentFolder = pwd;

% Dataset Directory - Location of Image Files
datasetFolder = 'C:\Users\ERDT\Documents\7_analysis_m\datasetB_analysis\selected';
%datasetFolder = fullfile(currentFolder, 'datasetC_analysis', 'sampled');

% List of subfolders within Dataset Directory
subfoldersList = dir(fullfile(datasetFolder));
subfoldersList = subfoldersList(~ismember({subfoldersList.name},{'.','..'}));
num_subfolders = length(subfoldersList);

% Create histogram folder
mainhistFolder = strcat(currentFolder, '\hist'); % CHANGE
if ~exist(mainhistFolder, 'dir')
    mkdir(mainhistFolder);
end

mainstatsFolder = strcat(currentFolder, '\stats'); % CHANGE
if ~exist(mainstatsFolder, 'dir')
    mkdir(mainstatsFolder);
end

%imstats = struct;

tic
for i =  1:num_subfolders
   
    imstats = struct;
    
    % Determine the number of images in each folder
    sampledimagesFolder = fullfile(datasetFolder, subfoldersList(i).name);
    sampledimagesList = dir(fullfile(sampledimagesFolder, '*.jpg'));
    num_images = numel(sampledimagesList);
    
    for j = 1:1:num_images
       
        imstats(j).FolderName = subfoldersList(i).name;
        imstats(j).ImageName = sampledimagesList(j).name;
        image = imread(fullfile(sampledimagesFolder, imstats(j).ImageName)); 
        
        [hist, r_bin, g_bin, b_bin, x] = histanalysis(image);
        
        % Save histogram as image file
        imagehistFolder = fullfile(mainhistFolder, imstats(j).FolderName);
        if ~exist(imagehistFolder, 'dir')
            mkdir(imagehistFolder);
        end

        im_hist_filename = strcat(imstats(j).ImageName(1:end - 4), '_hist.png');
        saveas(hist, fullfile(imagehistFolder, im_hist_filename));
        
        % Save histogram as vectors (bins)
        imstats(j).R = r_bin;    
        imstats(j).G = g_bin;    
        imstats(j).B = b_bin;

        image_r = image(:,:,1);       
        image_g = image(:,:,2);      
        image_b = image(:,:,3);

        % Compute for mean color intensity
        imstats(j).Rmean = mean(image_r, 'all');      
        imstats(j).Gmean = mean(image_g, 'all'); 
        imstats(j).Bmean = mean(image_b, 'all');
      
    end

    im_stats_filename = strcat(imstats(j).FolderName, '_stats.mat'); % CHANGE
    im_stats_filename_fullname = fullfile(mainstatsFolder, im_stats_filename);
    save(im_stats_filename_fullname,'imstats');
    
    fprintf('Cleared structure\n');
    
end