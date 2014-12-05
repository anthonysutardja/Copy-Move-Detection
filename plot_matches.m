function [ output_args ] = plot_matches( im, corresponding_points)
%PLOT_MATCHES Summary of this function goes here
%   Detailed explanation goes here
    figure(4), imshow(im);
    axis image; hold on;
    for i=1:size(corresponding_points.source, 1)
        ll = cat(1, corresponding_points.source(i,:), corresponding_points.target(i,:));
        plot(ll(:,2), ll(:,1), 'y-');
        plot(ll(:,2), ll(:,1), 'rx');
    end
    hold off;
    output_args = [];
end