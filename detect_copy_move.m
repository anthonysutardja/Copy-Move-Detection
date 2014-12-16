function [is_copy_move] = detect_copy_move(matches)
% This function takes in a series of points and determines
% if there is a copy move.

is_copy_move = false;

epsilon = 0.15;

src_points = matches.source;
target_points = matches.target;
[n, ~] = size(target_points);

% Run kmeans to get clusters of points
k = 2;
[idx, ~, sumd] = kmeans(target_points, k);
num_points = zeros(k,1);

% Find the number of points in each cluster
for i = 1:size(idx)
    num_points(idx(i)) = num_points(idx(i))+1;
end

% Find average distance of each cluster
for i = 1:k
    sumd(i) = sumd(i) / num_points(i)^2;
end

% Sort the average distances
% Get the average distance of the first and second lowest
% If less than epsilon -> copy move
sort(sumd);
if sumd(1)/sumd(2) < epsilon
    is_copy_move = true;
end

% Find distances between corresponding points
distances = zeros(n,1);
for i = 1:n
    src = src_points(i,:);
    target = target_points(i,:);
    dist = pdist([src(2) src(1); target(2) target(1)]);
    distances(i) = dist;
end

% Here, we bucket the distances
% Then a copy match occurs if there is a bucket after the first
% that has over the threshold amount of the total points
num_buckets = 10;
threshold = 0.8;
h = hist(distances, num_buckets);
for i = 2:size(h,2)
    if h(i)/n > threshold
        is_copy_move = true;
    end
end


end

