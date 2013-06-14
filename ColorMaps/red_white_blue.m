function rwb = red_white_blue(n)
% Generate a colormap with red to white to blue color range
if nargin < 1
    n = 64;
end
b2w = [linspace(0.2,1,n); linspace(0.1,1,n); linspace(1,1,n)];
w2r = [linspace(1,1,n); linspace(1,.1,n); linspace(1,0.1,n)];
% rwb = [linspace(0.2,1,n)' linspace(0.1,1,n)' linspace(1,1,n)'; ...
%     linspace(1,1,n)' linspace(1,.3,n)' linspace(1,0.3,n)'];
rwb = [b2w'; w2r'];