function im_msf = msf(im_sh, im_gamma, w_norm_sh, w_norm_gc)

    level = 10;

    % calculate the gaussian pyramid
    %level = 10;
    Weight1 = gaussian_pyramid(w_norm_sh, level);
    Weight2 = gaussian_pyramid(w_norm_gc, level);

    % calculate the laplacian pyramid
    % Sharpened Image
    R1 = laplacian_pyramid(im_sh(:, :, 1), level);
    G1 = laplacian_pyramid(im_sh(:, :, 2), level);
    B1 = laplacian_pyramid(im_sh(:, :, 3), level);
    
    % Gamma Corrected Image
    R2 = laplacian_pyramid(im_gamma(:, :, 1), level);
    G2 = laplacian_pyramid(im_gamma(:, :, 2), level);
    B2 = laplacian_pyramid(im_gamma(:, :, 3), level);

    Rr = {size(R1)};
    Rg = {size(G1)};
    Rb = {size(B1)};
    
    % fusion
    for k = 1 : level
        Rr{k} = Weight1{k} .* R1{k} + Weight2{k} .* R2{k};
        Rg{k} = Weight1{k} .* G1{k} + Weight2{k} .* G2{k};
        Rb{k} = Weight1{k} .* B1{k} + Weight2{k} .* B2{k};
    end

    % reconstruct & output
    R = pyramid_reconstruct(Rr);
    G = pyramid_reconstruct(Rg);
    B = pyramid_reconstruct(Rb);
    
    im_msf = cat(3, R, G, B);

end