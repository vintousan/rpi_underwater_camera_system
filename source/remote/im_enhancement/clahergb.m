function im_enh = clahergb(image)

    im_lab = rgb2lab(image);
    im_l = im_lab(:,:,1);
    
    im_l = rescale(im_l); 
    im_enh_l = adapthisteq(im_l,'NumTiles',[8 8],'ClipLimit',0.005);
    
    im_enh_l = im_enh_l*100;
    
    im_enh_lab = cat(3, im_enh_l, im_lab(:,:,2), im_lab(:,:,3));
    
    im_enh = lab2rgb(im_enh_lab);

end