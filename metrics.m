function [num_points, frac_points, avg_dist] = metrics(mask, matches)

points = matches.target;
[n, ~] = size(points);

% Number of points in the mask
num_points = 0;
for i = 1:n
    point = points(i,:);
    x = point(2);
    y = point(1);
    if mask(y,x) > 0
        num_points = num_points+1;
    end
end

% Percentage of the points in the mask
frac_points = num_points/n;

% Average distance of points in the mask (spread)
dist = 0;

for i = 1:n
    point1 = points(i,:);
    x1 = point1(2);
    y1 = point1(1);
    if mask(y1,x1) > 0
        for j = 1:n
            point2 = points(j,:);
            x2 = point2(2);
            y2 = point2(1);
            if mask(y2,x2) > 0
                dist = dist+sqrt((x2-x1)^2+(y2-y1)^2);
            end
        end
    end
end

if num_points > 0
    avg_dist = dist/num_points^2;
else
    avg_dist = 0
end

end

