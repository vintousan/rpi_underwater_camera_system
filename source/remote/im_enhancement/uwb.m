function im_uwb = uwb(im, alpha_r, alpha_b)

    % White Balance
    % Ancuti et al., 2018
    
    % Change image range from 0 - 255 to 0 - 1
    im = rescale(im);
    
    % Decompose color channels
    image_r = im(:,:,1);
    image_g = im(:,:,2);
    image_b = im(:,:,3);
    
    mean_r = mean(image_r,'all');
    mean_g = mean(image_g, 'all');
    mean_b = mean(image_b, 'all');
    
    % Apply color compensation
    
    %alpha_r = 1;
    %alpha_b = 1;
    
    cc_r = image_r + alpha_r*(mean_g-mean_r).*(1-image_r).*(image_g);
    cc_g = image_g; % Dominant/Superior Color Channel
    cc_b = image_b + alpha_b*(mean_g-mean_b).*(1-image_b).*(image_g);

    im_cc = cat(3,cc_r, cc_g, cc_b);    
    
    % Apply white balance by Gray World assumption
    J_cc_lin = rgb2lin(im_cc);
    percentiles = 10;
    illuminant = illumgray(J_cc_lin,percentiles);
    J_uwb_lin = chromadapt(J_cc_lin,illuminant,'ColorSpace','linear-rgb');
    
    im_uwb = lin2rgb(J_uwb_lin);
    %im_uwb = rescale(im_uwb,0,255);
    
end

