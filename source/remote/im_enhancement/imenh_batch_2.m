% Underwater Image Enhancement towards available data

clear
clc

fprintf('Image Processing - Selected Images\n'); 

tic

% Current Folder - Location of script
currentFolder = pwd;

% Images Folder
% Dataset Directory - Location of Image Files
datasetFolder = 'C:\Users\ERDT\Documents\2_processing_m\datasetC_prepro';
%datasetFolder = 'C:\Users\ERDT\Documents\7_analysis_m\datasetC_analysis\sampled'; 

% Subfolder list
subfoldersList = dir(fullfile(datasetFolder));
subfoldersList = subfoldersList(~ismember({subfoldersList.name},{'.','..'}));
num_subfolders = length(subfoldersList);

% CHANGE!!!
% Processed Folder
mainproFolder = fullfile(currentFolder, 'datasetC_prepro_UWB'); 
if ~exist(mainproFolder, 'dir')
    mkdir(mainproFolder);
end

tic

 for i = 1:num_subfolders

    %imeval = struct;
    
    subfolder_name = subfoldersList(i).name;
    
    imageFolder = fullfile(datasetFolder, subfolder_name);
    imagefilesList = dir(fullfile(imageFolder, '*.jpg'));
    num_files = length(imagefilesList);
    
    imeval_cell = cell(num_files, 14); 

    
    subproFolder = fullfile(mainproFolder, subfolder_name); 
    if ~exist(subproFolder, 'dir')
        mkdir(subproFolder);
    end
    
    %fprintf('CBF on ');
    %fprintf(subproFolder);
    
    parfor j = 1:num_files
       
        fprintf('Image %d of %d\n', j, num_files);
       
        imeval_row = imeval_cell(j,:);
        
        % READ IMAGE
        % FolderName 
        imeval_row{1} = subfolder_name;
        
        % ImageName 
        image_filename = imagefilesList(j).name;
        imeval_row{2} = image_filename;
        im_raw = imread(fullfile(imageFolder, image_filename)); 
        
        %imeval(j).FolderName = subfolder_name;
        %imeval(j).ImageName = imagefilesList(j).name;
        %im_raw = imread(fullfile(imageFolder, imagefilesList(j).name)); 
        fprintf('Read Image\n');
        
        % ENHANCE IMAGE
        % IMAGE ENHANCEMENT METHODS
        % COLOR BALANCE AND FUSION (Ancuti et al.)
        %im_enh = cbf(im_raw);
        
        % COLOR BALANCE AND FUSION ELEMENTS
        % UWB
        im_enh = uwb(im_raw, 1, 1);
        
        % GWA
        %im_enh = gwa(im_raw);
        
        % GAMMA
        %im_enh = ims(im_raw, 2, 0.4);
        
        % Rescale into 256 levels
        im_enh = uint8(rescale(im_enh, 0, 255));
        
        % SAVE IMAGE
        enh_im_filename = strcat(image_filename(1:end - 4), '_enh.jpg');
        imwrite(im_enh, fullfile(subproFolder, enh_im_filename));
        fprintf('Saved Image\n');
        
        % SAVE METRICS
        [imeval_row{3}, imeval_row{4}, imeval_row{5}, imeval_row{6}] = computeEntropy(im_enh);
        [imeval_row{7}, imeval_row{8}, imeval_row{9}, imeval_row{10}] = computeMean(im_enh);
        [imeval_row{11}, imeval_row{12}, imeval_row{13}, imeval_row{14}] = computeAG(im_enh);
        
        imeval_cell(j,:) = imeval_row;
        
        %[imeval(j).enh_h_r, imeval(j).enh_h_g, imeval(j).enh_h_b, imeval(j).enh_h] = computeEntropy(im_enh);
        %[imeval(j).enh_mean_r, imeval(j).enh_mean_g, imeval(j).enh_mean_b, imeval(j).enh_mean] = computeMean(im_enh);
        %[imeval(j).enh_AG_r, imeval(j).enh_AG_g, imeval(j).enh_AG_b, imeval(j).enh_AG] = computeAG(im_enh);
        fprintf('Saved Evaluation Metrics per image\n');
        
    end
    
    % Save all files
    % Change cell array to struct array
    struct_fields =  {'FolderName', 'ImageName', 'enh_h_r', 'enh_h_g', 'enh_h_b', 'enh_h', 'enh_mean_r', 'enh_mean_g', 'enh_mean_b', 'enh_mean', 'enh_AG_r', 'enh_AG_g', 'enh_AG_b', 'enh_AG'};
    imeval_struct = cell2struct(imeval_cell, struct_fields, 2);
    
    % CHANGE!!!!
    imeval_filename = strcat('datasetC_prepro_', subfolder_name, '_uwb_eval.mat'); 
    parsave(imeval_filename,imeval_struct);
    imeval_struct = struct;
    fprintf('Saved Evaluation Metrics structure in mat file\n');
    
    toc
    
 end
 
 function parsave(enh_filename,enh_metrics)
    
    save(enh_filename,'enh_metrics');
 
 end
 
