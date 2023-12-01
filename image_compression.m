imdata = imread('baboon.png');
size(imdata)
bw = im2gray(imdata);
testfile = fopen('test_bin.bin', 'w');
fwrite(testfile, bw);
%imwrite(bw, 'bw.jpg', 'jpg');
bw = im2double(bw);
imdataf = im2double(imdata);
ycbi = rgb2ycbcr(imdata);
size(ycbi)
ycb = im2double(ycbi);
%%
[U,S,V] = svd(bw);
sigma = diag(S);
x = zeros(size(sigma));
for i = 1:size(x)
    x(i) = i;
end
plot(x, sigma)
ylim([0.001 1000])
yscale log
ylabel '\sigma_k'
xlabel 'k'
title 'Singular values for b&w image'
%%
red = zeros(size(imdata), 'double');
red(:,:,1) = imdataf(:,:,1);
green = zeros(size(imdata), 'double');
green(:,:,2) = imdataf(:,:,2);
blue = zeros(size(imdata), 'double');
blue(:,:,3) = imdataf(:,:,3);
test = red+green+blue;
%%
%imwrite(red, 'red.jpg', 'jpg');
%imwrite(green, 'green.jpg', 'jpg');
%imwrite(blue, 'blue.jpg', 'jpg');
%imwrite(test, 'test.jpg', 'jpg');
%imwrite(imdata, 'test2.jpg', 'jpg');
%%
r = [1, 5, 10, 25, 50, 200];
err = zeros(size(r,2), 1);
comp = zeros(size(r,2), 1);
for i=1:size(r,2)
    approx = LowRankApproximation(r(i), bw);
    err(i) = GetError(bw, approx);
    comp(i) = GetCompressionRatio(size(bw), r(i));
    name = 'bw_' + string(r(i)) + '.jpg';
    %imwrite(approx, name, 'jpg');
end
%%
plot(r, err)
ylabel 'Error'
xlabel 'k'
title 'Relative error for b&w image'
%%
plot(r, comp)
ylabel 'Compression ratio'
xlabel 'k'
title 'Compression ratio for b&w image'
%%
r = [1, 5, 10, 25, 50, 200];
imsize = zeros(size(comp, 1), 1);
kb = size(bw, 1)*size(bw, 2)/1000
for i=1:size(comp,1)
    imsize(i) = kb/comp(i);
end
plot(r, imsize)
ylabel 'Image size (kb)'
xlabel 'k'
title 'B&w image size with integer storage'
%%
sr = svd(imdataf(:,:,1));
sg = svd(imdataf(:,:,2));
sb = svd(imdataf(:,:,3));
plot(x, sr, "red")
hold on
plot(x, sg, "green")
plot(x, sb, "blue")
title 'Singular values for color image'
ylabel '\sigma_k'
xlabel 'k'
ylim([0.001 30])
xlim([0 200])
hold off
%%
r = [1, 5, 10, 25, 50, 200];
err = zeros(size(r,2), 3);
for i=1:size(r,2)
    approx = zeros(size(imdataf));
    for j=1:3
        temp = LowRankApproximation(r(i), imdataf(:,:,j));
        err(i,j) = GetError(imdataf(:,:,j), temp);
        approx(:,:,j) = temp;
    end
    name = 'color_' + string(r(i)) + '.jpg';
    %imwrite(approx, name, 'jpg');
end
%%
plot(r, err(:,1), "red")
hold on
plot(r, err(:,2), "green")
plot(r, err(:,3), "blue")
title 'Relative error for color image'
ylabel 'Error'
xlabel 'k'
hold off
%%
plot(r, imsize*3)
ylabel 'Image size (kb)'
xlabel 'k'
title 'Color image size with integer storage'
%%
[Y Cb Cr] = imsplit(ycbi);
z = 127*ones(size(ycb, 1), size(ycb, 2)); % chroma center is offset!
Ysub = 127*ones(size(ycb, 1), size(ycb, 2)); % assume some luma
% substitute new luma, zero opposite chroma channel
just_Cb = ycbcr2rgb(cat(3, Ysub, Cb, z)); 
just_Cr = ycbcr2rgb(cat(3, Ysub, z, Cr));
imwrite(Y, 'Y.jpg', 'jpg')
imwrite(just_Cr, 'Cr.jpg', 'jpg')
imwrite(just_Cb, 'Cb.jpg', 'jpg')
%%
sy = svd(ycb(:,:,1));
sb = svd(ycb(:,:,2));
sr = svd(ycb(:,:,3));
plot(x, sr, "red")
hold on
plot(x, sy, "black")
plot(x, sb, "blue")
title 'Singular values for color image in YCbCr'
ylabel '\sigma_k'
xlabel 'k'
ylim([0.001 30])
xlim([0 200])
hold off
%%
approx = zeros(size(ycb));
approx(:,:,1) = LowRankApproximation(100, ycb(:,:,1));
approx(:,:,2) = LowRankApproximation(5, ycb(:,:,2));
approx(:,:,3) = LowRankApproximation(5, ycb(:,:,3));
approx = ycbcr2rgb(approx);
errr = GetError(imdataf(:,:,1), approx(:,:,1))
errg = GetError(imdataf(:,:,2), approx(:,:,2))
errb = GetError(imdataf(:,:,3), approx(:,:,3))
imshow(approx)
imwrite(approx, 'ycbcr.jpg', 'jpg');
ycbsize = 2*imsize(2) + kb/GetCompressionRatio(size(approx), 100)
%%
function approx = LowRankApproximation(n, A)
    [U,S,V] = svd(A);
    C = S;
    C(n+1:end,:) = 0;
    C(:,n+1:end) = 0;
    approx = U*C*V';
end
function err = GetError(A,B)
    err = norm(A-B, 'fro')/norm(A, 'fro');
end
function ratio = GetCompressionRatio(sizeA, k)
    initial = sizeA(1)*sizeA(2);
    final = k*sizeA(1) + k*sizeA(2) + k;
    ratio = initial/final;
end