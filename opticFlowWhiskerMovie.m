function avgSpeed=opticFlowWhiskerMovie(WhiskMovie)
% Cumpute optic flow based  avg Speed
%based on An implementaion of the very classical optical flow method of Horn & Schunck according to their paper:  
%Horn, B.K.P., and Schunck, B.G., Determining Optical Flow, AI(17), No. 1-3, August 1981, pp. 185-203 
 
% LTP 2009

[x y f]=size(WhiskMovie);
avgSpeed=zeros(1,f);
h=waitbar(0,'Processing Frame...');
for i=1:f-1
    waitbar(i/f,h,['Processing Frame...'  num2str(i)] );
    [u v]=HS(WhiskMovie(:,:,i),WhiskMovie(:,:,i+1),0.1,10,0,0,0);
    %[u,v,o1,x2,y2,o2] = flow (WhiskMovie(:,:,i), WhiskMovie(:,:,i+1), [-25:25], [-10:10]);
    speed=sqrt(u.^2+v.^2);
    avgSpeed(i)=mean(speed(:));
end
close(h);