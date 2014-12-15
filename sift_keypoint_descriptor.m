function [descriptor] = sift_keypoint_descriptor(im, points)

% Initialize
[height, width] = size(im);
[n, ~] = size(points);
descriptors = zeros(n, 128);
orientations = zeros(height, width, 2);
% for i = 1:width
%     for j = 1:height
%         orientations(j,i) = find_orientation([i,j], im);
%     end
% end

for p = 1:n
    % Get the point of interest
    point = points(p,:);
    y = point(1);
    x = point(2);
    disp(point);
    
    % Weighting
    weights = fspecial('gaussian', 16, 8);
    e = 1;
    descriptor = zeros(128, 1);

    for i = x-8:4:x+7
        for j = y-8:4:y+7
            bins = zeros(8,1);
            for k = i:i+3
                for l = j:j+3
                    theta = orientations(l,k,1);
                    magnitude = orientations(l,k,2);
                    bin_num = int8(theta/45)+1; % Find which bin
                    weight = weights(k-x+9,l-y+9); % Find the weight
                    % Update that bin
                    bins(bin_num) = bins(bin_num) + magnitude*weight;
                end
            end
            descriptor(e*8+1:(e+1)*8) = bins;
        end
    end

    descriptors(p,:) = descriptor/norm(descriptor);
end

end

