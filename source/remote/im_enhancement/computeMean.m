function [mean_r, mean_g, mean_b, mean_color] = computeMean(image)

    mean_r = mean(image(:,:,1), 'all');
    mean_g = mean(image(:,:,2), 'all');
    mean_b = mean(image(:,:,3), 'all');

    mean_color = (mean_r + mean_g + mean_b)/3; 
    
end
