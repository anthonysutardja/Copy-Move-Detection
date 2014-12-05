function output = ransac(matches, iters, error_threshold)
%RANSAC Summary of this function goes here
%   Detailed explanation goes here
    corresponding_points1 = matches.source; corresponding_points2 = matches.target;
    best_inlier_indices = [];
    o = ones(size(corresponding_points1, 1), 1);
    for i=1:iters
        % Select 4 random points
        indices = ceil(rand * size(corresponding_points1, 1));
        H = compute_h(corresponding_points1(indices, :), corresponding_points2(indices, :));
        x = corresponding_points1(:, 1);  y = corresponding_points1(:, 2);
        query = cat(1, x', y', o');
        xp = corresponding_points2(:, 1); yp = corresponding_points2(:, 2);
        expected = cat(1, xp', yp', o');
        results = H * query;
        % Rescale results
        for j=1:size(corresponding_points1, 1)
            f = results(3, j);
            if f ~= 1.0
                results(:, j) = results(:, j) / f;
            end
        end
        
        % remove sqrt for speed improvements
        distances = sqrt(sum((results - expected) .^ 2, 1));
        inlier_indices = find(distances < error_threshold);

        if numel(inlier_indices) > numel(best_inlier_indices)
            % Replace if we found a better set of inliers
            best_inlier_indices = inlier_indices;
        end
    end

    % Gather all the inlier points for debugging
    cp1 = corresponding_points1(best_inlier_indices, :);
    cp2 = corresponding_points2(best_inlier_indices, :);
    H = compute_h(cp1, cp2);
    output = struct('H', H, 'source', cp1, 'target', cp2);

end

