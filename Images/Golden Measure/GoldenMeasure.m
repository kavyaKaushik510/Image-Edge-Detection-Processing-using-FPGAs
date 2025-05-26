function [medianTime, sobelTime, totalTime, edgeDensity] = golden_image_processing_benchmark(inputImagePath, windowSize, threshold)
% GOLDEN_IMAGE_PROCESSING_BENCHMARK
% Performs median filtering and Sobel edge detection, returning benchmark metrics.
%
% Inputs:
%   inputImagePath: Path to input image (e.g., 'image.jpg')
%   windowSize: Median filter window size (e.g., 3)
%   threshold: Edge threshold (e.g., 0.1)
%
% Outputs:
%   medianTime: Time taken for median filtering (seconds)
%   sobelTime: Time taken for Sobel edge detection (seconds)
%   totalTime: Total processing time (seconds)
%   edgeDensity: Percentage of edge pixels (binary edge map)

% Extract base filename (without path or extension)
[~, baseFileName, ~] = fileparts(inputImagePath);

% Read and prepare image
inputImage = imread(inputImagePath);
inputImageDouble = im2double(inputImage);

% Get dimensions
[rows, cols, ~] = size(inputImageDouble);

% ----------------------------
% 1. Median Filtering
% ----------------------------
tic;
padSize = floor(windowSize / 2);
paddedImage = padarray(inputImageDouble, [padSize padSize], 'replicate');
summedImage = sum(paddedImage, 3);
medianFilteredImage = zeros(rows, cols, 3);

for i = 1:rows
    for j = 1:cols
        window = summedImage(i:i+windowSize-1, j:j+windowSize-1);
        medianValue = median(window(:));
        [r, c] = find(window == medianValue, 1);
        medianFilteredImage(i, j, :) = paddedImage(i+r-1, j+c-1, :);
    end
end

medianFilteredImage = im2uint8(medianFilteredImage);
medianTime = toc;

% Save median-filtered image
imwrite(medianFilteredImage, [baseFileName '_median_filtered.bmp']);

% ----------------------------
% 2. Sobel Edge Detection
% ----------------------------
tic;
grayImage = rgb2gray(medianFilteredImage);
grayImage = im2double(grayImage);

sobelX = [-1  0  1; -2  0  2; -1  0  1];
sobelY = [-1 -2 -1; 0  0  0; 1  2  1];

Gx = conv2(grayImage, sobelX, 'same');
Gy = conv2(grayImage, sobelY, 'same');
gradientMagnitude = sqrt(Gx.^2 + Gy.^2);
gradientMagnitude = gradientMagnitude / max(gradientMagnitude(:));

edgeImage = gradientMagnitude > threshold;
sobelTime = toc;

% Save edge-detected image
imwrite(edgeImage, [baseFileName '_edge_detected.bmp']);

% ----------------------------
% 3. Benchmark Outputs
% ----------------------------
totalTime = medianTime + sobelTime;
edgeDensity = sum(edgeImage(:)) / numel(edgeImage);  % Percentage of edge pixels

% Write to text file
logFileName = [baseFileName '.txt'];
fid = fopen(logFileName, 'w');
fprintf(fid, 'Median Time: %.4f s\n', medianTime);
fprintf(fid, 'Sobel Time: %.4f ms\n', sobelTime * 1000);
fprintf(fid, 'Total Time: %.4f s\n', totalTime);
fprintf(fid, 'Edge Density: %.4f percent\n', edgeDensity * 100);
fclose(fid);

% Display in command window
fprintf('Median Time: %.4f s\n', medianTime);
fprintf('Sobel Time: %.4f ms\n', sobelTime * 1000);
fprintf('Total Time: %.4f s\n', totalTime);
fprintf('Edge Density: %.4f percent\n', edgeDensity * 100);

% ----------------------------
% 4. Visualization
% ----------------------------
figure('Name','Golden Image Processing Benchmark','NumberTitle','off');
subplot(2, 3, 1); imshow(inputImage); title('Original Image');
subplot(2, 3, 2); imshow(medianFilteredImage); title('Median-Filtered Image');
subplot(2, 3, 3); imshow(grayImage); title('Grayscale Image');
subplot(2, 3, 4); imshow(abs(Gx), []); title('Sobel X (Vertical Edges)');
subplot(2, 3, 5); imshow(abs(Gy), []); title('Sobel Y (Horizontal Edges)');
subplot(2, 3, 6); imshow(edgeImage); title('Thresholded Edge Map');
end

[medianTime, sobelTime, totalTime, edgeDensity] = golden_image_processing_benchmark('Blurry.bmp', 3, 0.07);
[medianTime, sobelTime, totalTime, edgeDensity] = golden_image_processing_benchmark('lena_gray.bmp', 3, 0.07);
[medianTime, sobelTime, totalTime, edgeDensity] = golden_image_processing_benchmark('maybe_edges.bmp', 3, 0.07);
[medianTime, sobelTime, totalTime, edgeDensity] = golden_image_processing_benchmark('simple_house.bmp', 3, 0.07);
[medianTime, sobelTime, totalTime, edgeDensity] = golden_image_processing_benchmark('yoda.bmp', 3, 0.07);