function [AG_r, AG_g, AG_b, AG_color] = computeAG(image)

    [Gmag_r,~] = imgradient(image(:,:,1),'prewitt');
    [Gmag_g,~] = imgradient(image(:,:,2),'prewitt');
    [Gmag_b,~] = imgradient(image(:,:,3),'prewitt');
    
    %mean_r = mean(image(:,:,1), 'all');
    %mean_g = mean(image(:,:,2), 'all');
    %mean_b = mean(image(:,:,3), 'all');

    AG_r = sum(sum(Gmag_r))./(sqrt(2)*(size(image(:,:,1),1)-1)*(size(image(:,:,1),2)-1));
    AG_g = sum(sum(Gmag_g))./(sqrt(2)*(size(image(:,:,1),1)-1)*(size(image(:,:,1),2)-1));
    AG_b = sum(sum(Gmag_b))./(sqrt(2)*(size(image(:,:,1),1)-1)*(size(image(:,:,1),2)-1));
    
    AG_color = (AG_r + AG_g + AG_b)/3;
    
end