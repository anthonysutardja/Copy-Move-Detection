function [G] = gaussian_stacks(im, N, base_sigma)
%STACKS Return a stack of gaussians with varying sigmas applied
%   im - the image
%   N  - the number of levels in the pyramid

% Pad the image
pad_size = 50;
height = size(im, 1);
width = size(im, 2);
im = padarray(im, [pad_size, pad_size], 'symmetric');

% Gaussian
G = zeros(height, width, N);
for i=0:N-1
    % Filter it!
    sigma = base_sigma * (i+1);
    g_im = imfilter(im, fspecial('gaussian', ceil(sigma * 4), sigma));
    
    % Crop it back down
    G(:,:,i+1) = g_im(pad_size + 1: pad_size + height, pad_size + 1:pad_size + width);
end

end
