% % % % % % % % % % % % %
% Copy Move Experiment  %
% % % % % % % % % % % % %

% By Anthony Sutardja and Kevin Tee

IMG_NAME = 'tree';

IMAGE_PATH = strcat(strcat('./p_images/', IMG_NAME), '/modified.png');
MASK_PATH = strcat(strcat('./p_images/', IMG_NAME), '/mask.png');

start_time = cputime;

% Descriptor options (Don't touch unless you're adding a descriptor!)
DESCRIPTOR_BOX = 1;
DESCRIPTOR_MOPS = 2;  % to be implemented
DESCRIPTOR_SIFT = 3;  % to be implemented
DESCRIPTOR_HOG = 5;   % to be implemented


% Options
ENABLE_ANMS = false;       % Adaptive non-maximal supression
ENABLE_HIGH_POINTS = true;
ENABLE_RANSAC = true;     % RANSAC to find transformation estimation
LOOK_FOR_MULTIPLE = false; % Look for multiple transformations in RANSAC 
ADD_ORIENTATION = false;   % Rotation invariance

DESCRIPTOR = DESCRIPTOR_SIFT;


% Load image
im = im2single(imread(IMAGE_PATH));

% Load mask
mask = im2single(imread(MASK_PATH));

%% Get interesting points
disp('Finding harris corners..');
interest_points_original = harris(im);

% Show harris interest points
figure(1), imagesc(rgb2gray(im)); colormap(gray);
hold on; plot(interest_points_original(:,2),interest_points_original(:,1),'r.'); hold off;

if ENABLE_ANMS
    disp('Filtering by ANMS..');
    interest_points = anms(interest_points_original, 3000, 0.9); % before was 0.9
elseif ENABLE_HIGH_POINTS
    disp('Filtering by highest corners..');
    interest_points = highest_corners(interest_points_original, 8000);
else
    interest_points = interest_points_original;
end

% interest_points = cat(1, interest_points, highest_corners(interest_points_original, 500));

% Show filtered interest points
figure(3), imagesc(rgb2gray(im)); colormap(gray);
hold on; plot(interest_points(:,2),interest_points(:,1),'r.'); hold off;
%%
% Auto rotate
if ADD_ORIENTATION
    interest_points = find_orientations(interest_points, im, 40);
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
    descriptors = sift_keypoint_descriptor(im, interest_points);
elseif DESCRIPTOR == DESCRIPTOR_HOG
    disp('Extracting HOG descriptors..');
end

% figure(3), imagesc(rgb2gray(im)), colormap(gray); hold on; plot(descriptors.points(:,2), descriptors.points(:,1), 'r.'); hold off;



%% Matching
disp('Matching points..');
% Automatically use nearest neighbor outlier rejection
matches = nn_outlier_rejection(descriptors, descriptors, 0.5);
matches = filter_small_matches(matches, 4.5);
%% Filtering the matches
% This could be by matches that conform to transformation estimation or
% measuring vector magnitudes and directions.

% (Optional) Run ransac here or something to filter matches
if ENABLE_RANSAC
    if ~LOOK_FOR_MULTIPLE
        matches = ransac(matches, 80000, 75);
    else
        matches = ransac_multi(matches, 80000, 75);
    end
end

%% Plot matches
plot_matches(im, matches);

%% Evaluate Metrics
disp('Metrics...');
[num_points, frac_points] = metrics(mask, matches);
disp(strcat('Matched points: ', num2str(num_points)));
disp(strcat('Fraction of matched points: ', num2str(frac_points)));
disp(strcat('Total time: ', num2str(cputime - start_time)));
