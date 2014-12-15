function output = box_descriptor_rotate(im, points, descriptor_size, descriptor_resolution)
%BOX_DESCRIPTOR Summary of this function goes here
%   Detailed explanation goes here
    %% Gaussian
    % Downsample the image
    g_im = gaussian_stacks(rgb2gray(im), 5, 1.0);
    % TODO: use color?
    
    %% Resample
    sample_size = descriptor_size * descriptor_resolution;
    % sample each point for a 8x8 (really 40 x 40)
    A = []; points_usable = [];
    p = 1;
    for c=1:size(points, 1)
        % Find upper left corner
        y = points(c, 1);
        x = points(c, 2);
        theta = find_orientation([points(c, 2), points(c, 1)], g_im(:,:,5));
        tr_mat = [cos(theta), sin(theta); -sin(theta) cos(theta);];
        flag = false;
        box = zeros(sample_size * 2 + 1);
        sX = []; sY = [];

        for a=(-sample_size):(sample_size)
            for b=(-sample_size):(sample_size)
                % derp
                pts = tr_mat * [a; b];
                dx = pts(1); dy = pts(2);
                if is_in_im(y + dy, x + dx, size(g_im, 1), size(g_im, 2))
                    sX = [sX; x + dx;];
                    sY = [sY; y + dy;];
                    % box(b + sample_size + 1, a + sample_size + 1) = g_im(y+dy, x+dx, 2);
                else
                    flag = true;
                    break;
                end
            end
            if flag
                break;
            end
        end
        
        % Get the descriptor
        if ~flag
            box = interp2(g_im(:,:, 2), sX, sY);
            % imwrite(reshape(box, [sample_size * 2 + 1, sample_size * 2 + 1]), strcat(strcat('dump/', num2str(p)), '.jpg'));
            normal_box = (box - mean(box(:))) / std(box(:));
            A(p, :) = normal_box(:);
            points_usable(p, :) = [y, x];
            p = p + 1;
        end
    end
    output = struct('descriptors', A, 'points', points_usable);
end