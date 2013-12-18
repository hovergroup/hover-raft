close all;
clc;
clear;


original = imread('tag.png ');

imshow(original);

figure();
distorted = imread('frame_544.jpg'); % approx 0.14s/frame
% distorted = imread('frame_720.jpg'); % approx 0.24s/frame
subplot(2,2,1);
imshow(distorted)
subplot(2,2,2)
imshow(distorted(:,:,1))
subplot(2,2,3)
imshow(distorted(:,:,2))
subplot(2,2,4)
imshow(distorted(:,:,3))
original = rgb2gray(original);
distorted = rgb2gray(distorted);

tic
for i=1:1
    [t,theta,scale] = getTransform(distorted,original);
end
toc
figure();

height = 544;
width = 960;

%%

imshow(distorted);
hold on;
plot(t(1), t(2),'rx','MarkerSize',15);
% toc


