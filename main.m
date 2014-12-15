% % % % % % % % % % % % %
% Copy Move Experiment  %
% % % % % % % % % % % % %

% By Anthony Sutardja and Kevin Tee

IMAGE_PATH = './images/cattle_copy.png';

% Descriptor options (Don't touch unless you're adding a descriptor!)
DESCRIPTOR_BOX = 1;
DESCRIPTOR_MOPS = 2;  % to be implemented
DESCRIPTOR_SIFT = 3;  % to be implemented
DESCRIPTOR_HOG = 5;   % to be implemented


% Options
ENABLE_ANMS = true;  % adaptive non-maximal supression
ENABLE_RANSAC = true; % RANSAC to find transformation estimation
ADD_ORIENTATION = true;

DESCRIPTOR = DESCRIPTOR_BOX;


% Load image
im = im2single(imread(IMAGE_PATH));

%% Get interesting points
disp('Finding harris corners..');
interest_points = harris(im);

% Show harris interest points
figure(1), imagesc(rgb2gray(im)); colormap(gray);
hold on; plot(interest_points(:,2),interest_points(:,1),'r.'); hold off;

if ENABLE_ANMS
    interest_points = anms(interest_points, 2000, 0.9);

    % Show ANMS interest points
    figure(2), imagesc(rgb2gray(im)); colormap(gray);
    hold on; plot(interest_points(:,2),interest_points(:,1),'r.'); hold off;
end

%% Find descriptors
% Descriptors should output a struct containing a 'descriptors key'
% e.g. descriptors.descriptors = [
%     features on point 1;
%     features on point 2;
%     ... 
% ]
if DESCRIPTOR == DESCRIPTOR_BOX
    disp('Extracting box descriptors..');
    if ADD_ORIENTATION
        descriptors = box_descriptor_rotate(im, interest_points, 8, 5);
    else
        descriptors = box_descriptor(im, interest_points, 8, 5);
    end
elseif DESCRIPTOR == DESCRIPTOR_MOPS
    disp('Extracting MOPS descriptors..');
elseif DESCRIPTOR == DESCRIPTOR_SIFT
    disp('Extracting SIFT descriptors..');
 elseif DESCRIPTOR == DESCRIPTOR_HOG
    disp('Extracting HOG descriptors..');
end

% figure(3), imagesc(rgb2gray(im)), colormap(gray); hold on; plot(descriptors.points(:,2), descriptors.points(:,1), 'r.'); hold off;



%% Matching
disp('Matching points..');
% Automatically use nearest neighbor outlier rejection
matches = nn_outlier_rejection(descriptors, descriptors, 0.40);

%% Filtering the matches
% This could be by matches that conform to transformation estimation or
% measuring vector magnitudes and directions.

% (Optional) Run ransac here or something to filter matches
if ENABLE_RANSAC
    matches = ransac(matches, 10000, 75);
end

%% Plot matches
plot_matches(im, matches);