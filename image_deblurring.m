v = zeros(10,1);
s = 3;
b = 1/s;
for i=1:s
    v(i) = b - (i-1)*(b/s);
end
A = toeplitz(v);
imshow(1-A/max(max(A)))
imwrite(1-A/max(max(A)), 'toeplitz.png', 'png')
%%
imdata = imread('baboon.png');
bw = im2gray(imdata);
bw = im2double(bw);
s = 30;
b = 1/s;
v = zeros([512 1]);
for i=1:s
    v(i) = b - (i-1)*(b/s);
end
A = toeplitz(v)
imshow(bw)
imshow(A*bw)
imshow(bw*A)
imshow(A*bw*A)
%%
s = svd(A);
x = zeros(size(s));
for i=1:size(x)
    x(i) = i;
end
%%
plot(x, s)
title 'Singular values of A'
yscale log
xlabel 'k'
ylabel '\sigma_k'
%%
k = [300];
vblur = A*bw;
imshow(vblur)
for i=1:size(k,2)
    imshow(DeblurImage(k(i), A, vblur, 1))
end
%%
hblur = bw*A;
imshow(hblur)
for i=1:size(k,2)
    imshow(DeblurImage(k(i), A, hblur, 2))
end
%%
both = A*bw*A;
imshow(both)
for i=1:size(k,2)
    hdb = DeblurImage(k(i), A, both, 2);
    imshow(DeblurImage(k(i), A, hdb, 1))
end
%%
function deblur = DeblurImage(k, A, B, dir)
    deblur = zeros(size(B));
    [U, S, V] = svd(A);
    S(k+1:end,:) = 0;
    S(:,k+1:end) = 0;
    for i=1:k
        S(i,i) = 1/S(i,i);
    end
    if dir == 2
        B=B';
    end
    for j=1:size(B, 2)
        b = B(:,j);
        deblur(:,j) = V*S'*U'*b;
    end
    if dir == 2
        deblur = deblur';
    end
end