function im_enh = cbf(image, alpha_r, alpha_b, gamma, sigma, beta)

    if ~exist('alpha_r', 'var')
        alpha_r = 1;
    end

    if ~exist('alpha_b', 'var')
        alpha_b = 1;
    end

    if ~exist('gamma', 'var')
        gamma = 2.0;
    end

    if ~exist('sigma', 'var')
        sigma = 2.0;
    end

    if ~exist('beta', 'var')
        beta = 0.4;
    end
    
    % Perform underwater white balance
    im_uwb = uwb(image, alpha_r, alpha_b); 
    
    % Acquire contrasted fusion input via gamma correction
    im_gamma = gc(im_uwb, gamma);
    
    % Acquire sharpened fusion input via unsharp masking
    im_sh = ims(im_uwb, sigma, beta);
    
    % Compute normalized weights
    [w_norm_sh, w_norm_gc] = wc(im_sh, im_gamma);
    
    % Blend inputs via multiscale fusion with normalized weights
    im_enh = msf(im_sh, im_gamma, w_norm_sh, w_norm_gc);

end