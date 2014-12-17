function [output] = sift_keypoint_descriptor(im, points)

% Initialize
[height, width, ~] = size(im);
[n, ~] = size(points);
descriptors = zeros(n, 128);
all_points = zeros(height*width, 3);
mapping = zeros(height, width);

e = 1;
for i = 1:width
    for j = 1:height
        all_points(e,:) = [j,i,0];
        mapping(j,i) = e;
        e=e+1;
    end
end
%orientations = find_orientations(all_points, im, 15);
%orientations = zeros(height*width, 4);
[mag, dir] = imgradient(rgb2gray(im));

for p = 1:n
    % Get the point of interest
    point = points(p,:);
    y = point(1);
    x = point(2);
    %disp(point);
    
    % Weighting
    weights = fspecial('gaussian', 16, 8);
    e = 0;
    descriptor = zeros(128, 1);

    for i = x-8:4:x+7
        for j = y-8:4:y+7
            bins = zeros(8,1);
            for k = i:i+3
                for l = j:j+3
                    theta = dir(l,k);
                    magnitude = mag(l,k);
                    bin_num = mod(int8(theta/45),8)+1; % Find which bin
                    weight = weights(k-x+9,l-y+9); % Find the weight
                    % Update that bin
                    bins(bin_num) = bins(bin_num) + magnitude*weight;
                end
            end
            descriptor(e*8+1:(e+1)*8) = bins;
            e = e+1;
        end
    end

    descriptors(p,:) = descriptor/norm(descriptor);
end

output = struct('descriptors', descriptors, 'points', points);

end

