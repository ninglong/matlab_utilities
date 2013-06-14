function b2r = blue2red(n)
% Generate a colormap with blue to red color range
if nargin < 1
    n = 64;
end
b2r = [linspace(.6,0,n); linspace(0.3,0.3,n); linspace(0,.6,n)]';