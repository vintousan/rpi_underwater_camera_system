function [h_r, h_g, h_b, h_color] = computeEntropy(image)

    h_r = entropy(image(:,:,1));
    h_g = entropy(image(:,:,2));
    h_b = entropy(image(:,:,3)); 
    
    h_color = sqrt(((h_r^2) + (h_g^2) + (h_b^2))/3);
    
end