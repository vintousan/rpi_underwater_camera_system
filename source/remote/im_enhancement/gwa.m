function im_enh = gwa(image)

    image = rescale(image); 
    
    % Apply white balance by Gray World assumption
    image_lin = rgb2lin(image);
    percentiles = 10;
    illuminant = illumgray(image_lin,percentiles);
    image_lin = chromadapt(image_lin,illuminant,'ColorSpace','linear-rgb');
    
    im_enh = lin2rgb(image_lin);

end 