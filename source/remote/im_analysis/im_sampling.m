% IMAGE ANALYSIS and PROCESSING

clear;
clc;

% 1 - Directory Initialization

currentFolder = pwd;

workingDirFolder = fullfile(currentFolder, 'workingdir', 'raw');
workingDirFolderList = dir(fullfile(workingDirFolder));
workingDirFolderList = workingDirFolderList(~ismember({workingDirFolderList.name},{'.','..'})); % Remove first two entries in dir results
num_folders = numel(workingDirFolderList);

% 2 - Stratified Random Sampling
% 500 images/day

% Get dataset info per date
dataset_info = cell(4,3); % 1 - name, 2 - folder_count, 3 - image count 

dataset_info_iter = 1;
foldersperday_count = 0; 
total_num_images = 0;

% Count number of folders per date
for i = 1:1:num_folders
    
    imageFolderName = workingDirFolderList(i).name;
    
    if isempty(dataset_info{dataset_info_iter,1})
        dataset_info{dataset_info_iter,1} = imageFolderName(1:end-6);
    end
    
    if dataset_info{dataset_info_iter,1} == imageFolderName(1:end-6)
        foldersperday_count = foldersperday_count + 1; 
    else
        foldersperday_count = 0;
        foldersperday_count = foldersperday_count + 1; 
        dataset_info_iter = dataset_info_iter + 1;
    end
    
    dataset_info{dataset_info_iter,2} = foldersperday_count;
    
end
    
% Count number of images per date
dataset_info_iter = 1;
total_num_images = 0;

for i = 1:1:num_folders
    
    imageFolderName = workingDirFolderList(i).name;
    
    imageFolder = fullfile(workingDirFolder, imageFolderName);
    imageList = dir(fullfile(imageFolder, '*.jpg'));
    num_images = numel(imageList);
    
    if dataset_info{dataset_info_iter,1} == imageFolderName(1:end-6)
        total_num_images = total_num_images + num_images;
    else   
        total_num_images = 0;
        total_num_images = total_num_images + num_images;
        dataset_info_iter = dataset_info_iter + 1;
    end
    
    dataset_info{dataset_info_iter,3} = total_num_images;
    
end

% Determine the number of images to be sampled per folder
num_images_per_folder = zeros(num_folders,1);
num_images_per_day = 500;
num_images_per_day_count = 500;
num_of_folder_iter = 1;
dataset_info_iter = 1;


for i = 1:1:num_folders
    
    imageFolderName = workingDirFolderList(i).name;
    
    imageFolder = fullfile(workingDirFolder, workingDirFolderList(i).name);
    imageList = dir(fullfile(imageFolder, '*.jpg'));
    num_images = numel(imageList);
    
    if num_of_folder_iter < dataset_info{dataset_info_iter,2}
        num_images_per_folder_temp = floor((num_images/dataset_info{dataset_info_iter,3}) * num_images_per_day);
        num_images_per_day_count = num_images_per_day_count - num_images_per_folder_temp;
        num_of_folder_iter = num_of_folder_iter + 1;
    else
        num_images_per_folder_temp = num_images_per_day_count;
        num_of_folder_iter = 1;
        dataset_info_iter = dataset_info_iter + 1;
        num_images_per_day_count = 500;
    end
    
    num_images_per_folder(i,1) = num_images_per_folder_temp;
        
end

% Stratified Random Sampling

for i = 1:1:num_folders

    imageFolder = fullfile(workingDirFolder, workingDirFolderList(i).name);
    imageList = dir(fullfile(imageFolder, '*.jpg'));
    num_images = numel(imageList);
    
    idx = randperm(num_images, num_images_per_folder(i,1));
    idx = sort(idx);
    
    selectedimageFolder = fullfile(currentFolder, 'workingdir', 'selected', workingDirFolderList(i).name);
    if ~exist(selectedimageFolder, 'dir')
        mkdir(selectedimageFolder);
    end
    
    for j = 1:1:num_images_per_folder(i,1)
        imagefile = fullfile(imageFolder, imageList(idx(j)).name);
        copyfile(imagefile, selectedimageFolder);
        fprintf('Sampled Images from Captures\n'); 
    end
        
end


