function [is_copy_move] = detect_copy_move(im, matches)
% This function takes in a series of points and determines
% if there is a copy move.

is_copy_move = false;

epsilon = 0.2;

[height, width, ~] = size(im);
points = matches.target;
[n, ~] = size(points);
density = zeros(height, width);

% Plot the points on some image
for i = 1:n
    point = points(i,:);
    x = point(2);
    y = point(1);
    density(y,x) = 0.1;
end

% Run kmeans to get clusters of points
k = 2;
[idx, ~, sumd] = kmeans(points, k);
num_points = zeros(k,1);

% Find the number of points in each cluster
for i = 1:size(idx)
    num_points(idx(i)) = num_points(idx(i))+1;
end

for i = 1:k
    sumd(i) = sumd(i) / num_points(i)^2;
end

% Get the lowest and second lowest
% If less than epsilon -> copy move
sort(sumd);
if sumd(1)/sumd(2) < epsilon
    is_copy_move = true;
end

disp(num_points);
disp(sumd);

end

