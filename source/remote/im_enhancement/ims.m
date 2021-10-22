function im_sh = ims(im_uwb, sigma, beta)

    im_gauss = im_uwb;
    
    %{
````N = 1;
    
    for iter=1:N
        im_gauss = imgaussfilt(im_gauss,sigma);
        im_gauss = min(im_uwb, im_gauss);
    end
    %}
    
    im_gauss = imgaussfilt(im_gauss,sigma);
    
    %gain = 1; %in the paper is not mentioned, but sometimes gain <1 is better. 
    norm = (im_uwb - beta.*im_gauss);
    
    %Norm
    for n = 1:3
        norm(:,:,n) = histeq(norm(:,:,n)); 
    end
    
    im_sh = (im_uwb + norm)/2;
    
end