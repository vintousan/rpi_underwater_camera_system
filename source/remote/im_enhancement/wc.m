function [w1, w2] = wc(im_sharp, im_gamma)

    % Regularization
    delta = 0.1;

    im_sharp_lab = rgb2lab(im_sharp);
    im_gamma_lab = rgb2lab(im_gamma);

    % Sharpened Image
    R1 = double(im_sharp_lab(:, :, 1)) / 255;
   
    % calculate laplacian contrast weight
    lapw1 = sqrt((((im_sharp(:,:,1)) - (R1)).^2 + ...
                ((im_sharp(:,:,2)) - (R1)).^2 + ...
                ((im_sharp(:,:,3)) - (R1)).^2) / 3);
    
    % calculate the saliency weight
    salw1 = saliency_detection(im_sharp);
    salw1 = salw1/max(salw1,[],'all');
    
    % calculate the saturation weight
    satw1 = sqrt(1/3*((im_sharp(:,:,1)-R1).^2+(im_sharp(:,:,2)-R1).^2+(im_sharp(:,:,3)-R1).^2));
    
    % Gamma Corrected Image
    R2 = double(im_gamma_lab(:, :, 1)) / 255;
    
    % calculate laplacian contrast weight
    lapw2 = sqrt((((im_gamma(:,:,1)) - (R2)).^2 + ...
                ((im_gamma(:,:,2)) - (R2)).^2 + ...
                ((im_gamma(:,:,3)) - (R2)).^2) / 3);
    
    % calculate the saliency weight
    salw2 = saliency_detection(im_gamma);
    salw2 = salw2/max(salw2,[],'all');

    % calculate the saturation weight
    satw2 = sqrt(1/3*((im_gamma(:,:,1)-R1).^2+(im_gamma(:,:,2)-R1).^2+(im_gamma(:,:,3)-R1).^2));

    % calculate the normalized weight
    w1 = (lapw1 + salw1 + satw1 + delta) ./ ...
        (lapw1 + salw1 + satw1 + lapw2 + salw2 + satw2 + delta*2);
    w2 = (lapw2 + salw2 + satw2 + delta) ./ ...
        (lapw1 + salw1 + satw1 + lapw2 + salw2 + satw2 + delta*2);
    
end