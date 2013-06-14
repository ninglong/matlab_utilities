%
% function extern_dombeck(im_s, im_t, maxdx, maxdy, debug_flag)
%   im_s: source image ; height x width x frames
%   im_t: target image ; height x width 
%   maxdx, maxdy: maximal displacement in each direction in pixels
%   debug_flag: 0 means nothing ; 1 gives waitbars ; 2 gives figures and waitbars
%
% Source code from 
%   Imaging large-scale neural activity with cellular resolution in awake, mobile mice.
%   Dombeck DA, Khabbaz AN, Collman F, Adelman TL, Tank DW.
%   Neuron. 2007 Oct 4;56(1):43-57.
%
% Altered, but most of this is (C) Princeton ... so if you want your own, re-write it - frankly,
%  their implementation is kind of bitchass so it should be redone anyways.
%   1) hysteresis assumption is way too liberal ; more conservative means faster because 
%      if you assume that motion between lines is small *but* overall motion is unbound/much larger,
%      you will likely get much better results - and you need to therefore separate these two
%      constraints which currently are identical
%   2) they had a lot of stuff for preprocessing that I removed -- automated target selection,
%      basically
%
function offsets = extern_dombeck(im_s, im_t, maxdx, maxdy, debug_flag)

% --- convert im_s to chone format -- h,w,nfrms to nfrms,h,w
if (length(size(im_s)) == 2) % single frame
  chone = im_s; % assume same
else % multi frame - must reshape
	chone = zeros(size(im_s,3), size(im_s,1), size(im_s,2));
	for f=1:size(im_s,3)
	  chone(f,:,:) = im_s(:,:,f);
	end
end

% --- values of 0 are not cool with this guy
im_t(find(im_t < 1)) = 1;

% --- the main call
[PIsave, maxdx, maxdy, Nx, Ny, Nh, Nw, numframes, edgebuffer, gain, framesper30sec, chone] = ...
  extern_dombeck_split_createPI(chone,maxdx,maxdy,im_t, debug_flag); %10 10 more real
offsets = extern_dombeck_maxlambda(PIsave, maxdx, maxdy, Nx, Ny, Nh, Nw, numframes, edgebuffer, gain, framesper30sec, debug_flag);
%[fixeddata,countdata]=playback_markov(chone,offsets,edgebuffer,1);


function PI=extern_dombeck_create_PI_markov(lineextract,refimage,maxdx,maxdy,j, debug_flag)
%PI=create_PI_markov(lineextract,refimage,maxdx,maxdy,j)
%take a reference image (REFIMAGE), a line of data to fit (LINEEXTRACT),
%maximum offsets to consider MAXDX, MAXDY, and the expected location of the
%that line in y (J) (expected location in x is assumed to at zero offset.

%pick out the size of the image
Nh=size(refimage,1);
Nw=size(refimage,2);


%initialize the probabilities to zero
PI=zeros(2*maxdy+1,2*maxdx+1);

%what is the topline and the bottomline considered
%this check is a remenant of older versions which allowed lines to be
%placed that were near the edges of the image.
%topline and bottomline should always be j-maxdy and j+maxdy respectively
%now..
topline=max(1,j-maxdy);
bottomline=min(Nh,j+maxdy);

%loop over all considered x shifts
for shift=-maxdx:maxdx

    %pick out the section of lineextract which we will be considering
    %edge pixels are not considered so that the same number of pixels are
    %fit for each offset
    start=1+maxdx;
    ending=Nw-maxdx;
    F=lineextract(start:ending);

    %pick out the range of pixels in X out of the reference image which we will
    %be considering for this particular fit.
    start2=1+maxdx+shift;
    ending2=Nw-maxdx+shift;
    %pick out that section of the reference image which we will be aligning
    %to for this particular X offset.. we do all Y offsets considered
    %simultaneously in this implementation
    G=refimage(topline:bottomline,start2:ending2);
    
    %repeat the line we are fitting for all the possible Y offsets
    F=repmat(F',size(G,1),1);
    
    %calculate the fit in terms of a log probability for each pixel in the
    %calculation
    temp=F.*log(G)-G;
 
    %sum over all the pixels in the line to get the total probability 
    % for this X offset over all Y offset considered.
    %stick into the PI matrix in the appropriate spot
    PI(topline-j+maxdy+1:bottomline-j+maxdy+1,shift+maxdx+1)=sum(temp,2);
end



function gain=extern_dombeck_find_gain(data,streak,debug_flag)
%takes a movie (DATA) that is numframes x Nh x Nw and calculates the GAIN of
%the optical system which took the movie by looking at the relationship
%between the standard deviation and the mean of those pixels.
%this of course only works if there is no movements, so this function look
%for the "stillest" section of frames (STREAK frames long).  "stillest" is
%judged by having the smallest mean absolute difference between frames.

if (debug_flag > 0) 
  h = waitbar(0.0,'Calculating Mean Absolute Difference Between Frames...');
  set(h,'Name','Auto Calculating Gain...');
end

%pull out the number of frames and size of each frame
%assumed to be square.
 numframes=size(data,1);
 Nh=size(data,2);
 Nw=size(data,3);

 %calculate the mean absolute difference between frames
 diffvector=mean(mean(abs(diff(data)),2),3);
 
 %initialize the vector which stores the mean absolute difference between
 %frames for all the possible streaks
 diffavg=zeros(1,length(diffvector)-streak);
 
 %fill in that vector
 for i=1:numframes-streak-1
     if (debug_flag > 0) ; waitbar(.1+.8*(i/(numframes-streak-1)),h,['Calculating Mean Diff. Starting at Frame ' num2str(i)]); end
     diffavg(i)=mean(diffvector(i:i+streak));
 end
 
 %find the best streak
 [junk,minframe]=min(diffavg);
if(debug_flag > 0) ; set(h,'Name',['AutoCalculating Gain...Streak at ' num2str(minframe)]); end
 %cut out the data across that streak
 datacut=data(minframe:minframe+streak,:,:);
 
if(debug_flag > 0) ; waitbar(.9,h,['Calculating Means..']); end
 %find the mean of every pixel across that streak
 means=mean(datacut);
 
 %turn it into a vector...
 means=means(:);
 
if(debug_flag > 0) ;waitbar(.925,h,['Calculating Stds..']); end
%calculate the stds of every pixel across that streak and turn it into a
%vector
 stds=std(datacut);
 stds=stds(:);
if(debug_flag > 0) ;waitbar(.95,h,['Fitting to Sqrt Function..']); end
 %fit a sqrt function to the relationship between the mean and stds
 curve=fit(means,stds,'a*x^.5');
 
% the gain is related to a^2
gain=curve.a.^2;
%gain = ones(size(stds));
if(debug_flag > 0) ;waitbar(1,h,['Done!']);end

if exist('h') ;delete(h); end
  
 
function [offsets thepath P PItot PIpath totprob] = ... 
  extern_dombeck_markov_on_PIsave(PIsave, maxdx, maxdy, Nx, Ny, Nw, Nh, lambda, numframes, edgebuffer, gain, h, framesper30sec, debug_flag)
%double checks that you loaded a _PI file and asks you to load one if you
%haven't

%you also need to have lambda set before you run this... normally run
%maxlambda, and have it call this script.. but you can set lambda by hand if you want.
%if ~exist('PIsave')
%    if ~exist('filename')
%      [filename,pathname]=uigetfile('*PI.mat','pick your file');
%      junk=strfind(filename,'/');
%      filebase=filename(1:end-4);
%    else
%      pathname='../';
%        junk=strfind(filename,'/');
%        filebase=filename(junk(end)+1:end-4);
%        filename=['matfiles/' filebase '_PI.mat'];
%    end
%     load([pathname filename]);
%end

%creates the basic exponential model for the transistion probabilities,
%this in terms of relative change in offset.  We normalize appropriately
%and make sure its big enough so that it covers all possible differences in
%offsets
[xx,yy]=meshgrid(-2*maxdx:2*maxdx,-2*maxdy:2*maxdy);
rr=sqrt(xx.^2+yy.^2);
rel_trans_prob=exp(-(abs(rr)./lambda));
rel_trans_prob=rel_trans_prob/(sum(sum(rel_trans_prob)));

%to plot it out if you wanted
%figure(9);
%imagesc(rel_trans_prob);

%now build up the entire transition probability matrix where you index a
%pair of offsets as a single hashed value by making use of the reshape
%function in matlab.  an offset pair will now be refered to a state.
trans_prob=zeros(Nx*Ny,Nx*Ny);
for i=-maxdx:maxdx
    for j=-maxdy:maxdy
        trans_prob((i+maxdx)*(maxdy*2+1)+j+maxdy+1,:)=reshape(rel_trans_prob((maxdy-j+1):(3*maxdy-j+1),(maxdx-i+1):(3*maxdx-i+1)),Nx*Ny,1);
    end
end
%there are some alternative ways you could consider renormalizing this
%matrix, but we decided not to use any of these..
%trans_prob=trans_prob./repmat(sum(trans_prob),Nx*Ny,1);
%trans_prob=trans_prob./repmat(sum(trans_prob,2),1,Nx*Ny);

%translate it into a log probability
trans_prob=log(trans_prob);

%image the whole matrix if you want
%figure(20);
%imagesc(trans_prob);

frames=1:numframes;

%this is going to be the matrix which keeps track of the transition which
%was the most probable way to get to a particular state from the previous
%state.. we will fill this matrix up, and the backtrack the most probable
%path as is the standard way of the veterbi algorithm.
savemax=zeros(Nx*Ny,numframes*Nh,'int16');

%P is the probability vector which describes the maximal probability of
%being in a particular state at the current time step as we march forward
%we will start with a uniform distribution across offsets
P=ones(1,Nx*Ny);

%vector to save the time it took to process each frame
tocs=zeros(numframes,1);

%index which will march over lines considered
m=0;

%loop over all frames
for i=frames
    %note the time
    tic
    %loop over all the lines considered in that frame
    for j=1+edgebuffer:Nh-edgebuffer

        %increment our index for lines considered
        m=m+1;

        %replicate the starting probabilities at the time step before for
        %all the possible offsets
        Prep=repmat(P,Nx*Ny,1);
        %calculate the matrix of probabilities of being in one state at
        %the previous time point and then transitioning to another
        Pnew=Prep+trans_prob;

        %this was my C implementation of the previous 2 lines.. it speeds
        %things up but i have disabled it here... if you want to compile
        %the C for your platform you can.. the file there.
        %Pnew = makepifast(trans_prob,P);
        %Pnew = Pnew';

        %calculate the most probable way to wind up in a given state, and
        %what the probability is.. save which path you took to get that
        %value, and update P.
        [P,savemax(:,m)]= max(Pnew',[],1);

        %now add in the fit data to adjust the probability of being in a
        %given state.

        %pull out the relevant matrix of values
        PI=squeeze(PIsave(m,:,:));
        %reshape them into a vector
        PIvec=reshape(PI,Nx*Ny,1);

        %i shift all the probabilities by the mean just to keep things
        %from hitting round off errors.. this doesn't affect the
        %calculation, just keeps things reasonable.
        PIvec=PIvec/gain;
        PIvec=PIvec-mean(PIvec);


        %add on the fits to the probabilities

        P=P+PIvec';

        % plot out the maximal probabilities and the fits if you want
        % figure(60);
        % imagesc(reshape(P,Nx,Ny));
        % figure(61);
        % imagesc(reshape(PIvec,Nx,Ny));
    end

    %note the time
    tocs(i)=toc;

    %calculate the average time per frame so far
    delframes=mean(tocs(max(i-9,1):i));
    %use that to estimate the time remaining
    minremain=(numframes-i)*delframes/60;
    %display what frame you are on, how long it should take, and how long
    %the current frame took
    if (debug_flag > 0) ; waitbar((i/length(frames)),h,['Running HMM.. Frame ' num2str(i) ' ETA:' num2str(minremain) ' min']); end
    %disp([i minremain tocs(i)]);

end

clear offsets;
numlines=m;

%find the state that was the most probable ending point
%and what the total probablity was for this value of lambda
[totprob,mprob]=max(P);

%initialize the path of most probable states
thepath=zeros(1,numlines);

%for my interest i save the fits along the path
PIpath=zeros(1,numlines);
%calculate the total fit for this path without considering transition
%probabilities.
PItot=0;

%march backward from the last line considered to the first
for k=numlines:-1:1
    if(mod(k,Nh)==0)
    if (debug_flag > 0) ; waitbar((k/numlines),h,['Backtracing path.. line ' num2str(k)]); end
    end
    %pull out the fits from the current line
    PI=squeeze(PIsave(k,:,:));
    %turn it into a vector
    PIvec=reshape(PI,Nx*Ny,1);

    %what is the fit for the most probable state at this timepoint
    PIpath(k)=PIvec(mprob);
    %add that to the total fit
    PItot=PItot+PIvec(mprob);

    %save that point along the path
    thepath(k)=mprob;
    %remember what was the most probable way was to get to that state.. update mprob
    mprob=savemax(mprob,k);
end

%unhash the path in terms of state index into a pair of offsets
offsets(1,:)=mod(thepath,Ny);
offsets(1,find(offsets(1,:)==0))=Ny;
offsets(1,:)=offsets(1,:)-maxdy-1;
offsets(2,:)=((thepath-mod(thepath,Ny))/Ny)-maxdx;

%adjust for the alignments between reference frames
%offsetfix=1:numlines;
%offsetfix=floor(offsetfix/(Nh-2*edgebuffer));
%offsetfix=floor(offsetfix/framesper30sec)+1;
%offsetfix=stilloffsets(offsetfix,:)'
%offsets=offsets-offsetfix;
%pause;


%plot out the offsets
if (debug_flag > 1)
	figure(2);
	plot(offsets');
	title(['\lambda' sprintf(' = %3.2f',lambda)]);
	xlabel('line number');
	ylabel('offset (relative pixels)');
end



function offsets = extern_dombeck_maxlambda(PIsave, maxdx, maxdy, Nx, Ny, Nh, Nw, numframes, edgebuffer, gain, framesper30sec,debug_flag)
%before running this file, load up the _PI.mat file that was created by
%split_createPI

%powers of 10 to scan over for lambda
%sampling uniform in log space determines lambda to a uniform percentage
%precision, i have intentionally scanned over a larger range of lambda than
%is neccesary in order to illustrate what happens at small and large values of lambda.
if (debug_flag > 0)
  h = waitbar(0.0,'Scanning Lambda Values...');
  set(h,'Name','Expectation Maximization');
else
  h= -1;
end

n=-3:.1:.5;

%values of lambda to sample
lambdas=10.^n;

%initialize index for lambda values
jj=0;

%clear previous results if any
clear saveprobs

%loop over values of lambda
for lambda=lambdas
  %increment index
  jj=jj+1;
  dl=1/length(lambdas);
	if (debug_flag > 0) ; waitbar((jj-1)/length(lambdas),h,['Lambda=' num2str(lambda)]); end
  %run an abbreviated version of the HMM on the first 20 frames
  %totprob will be the overall probability for that run
  %offsets predicted for that value are plotted at the completion of each
  %iteration.
  totprob = extern_dombeck_short_markov (PIsave, maxdx, maxdy, lambda, Nx, Ny, Nh, Nw, numframes, edgebuffer, gain, jj, lambdas, dl, h, framesper30sec, debug_flag);
  
  %save the total probablity for that value of lambda
  saveprobs(jj)=totprob;
end

%plot the curve of overall probabilities


%pick out the value of lambda which is the overall most probable
[maximumvalue,maximumindex]=max(saveprobs);
lambda=lambdas(maximumindex);
if (debug_flag > 1)
	figure(99);
	clf;
	set(gcf,'Position',[800 200 1280-800 500]);
	hold on;
	plot(lambdas,saveprobs);
	plot(lambda,maximumvalue,'rx');
	xlabel('\lambda');
	ylabel('total probability');
end

if (debug_flag > 0)
	waitbar(0.0,h,['Run with Lambda=' num2str(lambda)]);
	set(h,'Name',['HMM Lambda=' num2str(lambda)]);
end

%run the HMM algorithm, now that lambda is set to its most probable value,
%over all frames of the movie. this will result in a _L file containing the
%offsets
if (debug_flag == 0) ; h = -1 ; end
[offsets thepath P PItot PIpath totprob] = ... 
 extern_dombeck_markov_on_PIsave(PIsave, maxdx, maxdy, Nx, Ny, Nw, Nh, lambda, numframes, edgebuffer, gain, h, framesper30sec, debug_flag);
if exist('h'); if (ishandle(h)) ; delete(h); end ;end
%save the probabilities into the _PI file for posterity
%save(['../matfiles/' filebase '_PI.mat'],'saveprobs','lambdas','-append');



function totprob = extern_dombeck_short_markov(PIsave, maxdx, maxdy, lambda, Nx, Ny, Nh, Nw, ...
                     numframes, edgebuffer, gain, jj, lambdas, dl, h, framesper30sec, debug_flag)
%double checks that you loaded a file and asks you to load one if you
%haven't
%you also need to have lambda set before you run this... normally run
%maxlambda that calls this.. but you can set lambda by hand if you want.


%creates the basic exponential model for the transistion probabilities,
%this in terms of relative change in offset, normalizing appropriately
%we make sure its big enough so that it covers all possible differences in
%offsets
[xx,yy]=meshgrid(-2*maxdx:2*maxdx,-2*maxdy:2*maxdy);
rr=sqrt(xx.^2+yy.^2);
rel_trans_prob=exp(-(abs(rr)./lambda));
rel_trans_prob=rel_trans_prob/(sum(sum(rel_trans_prob)));

%to plot it out if you wanted
%figure(9);
%imagesc(rel_trans_prob);

%now build up the entire transition probability matrix where you index a
%pair of offsets as a single hashed value by making use of the reshape
%function in matlab.  an offset pair will now be refered to a state.
trans_prob=zeros(Nx*Ny,Nx*Ny);
for i=-maxdx:maxdx
    for j=-maxdy:maxdy
        trans_prob((i+maxdx)*(maxdy*2+1)+j+maxdy+1,:)=reshape(rel_trans_prob((maxdy-j+1):(3*maxdy-j+1),(maxdx-i+1):(3*maxdx-i+1)),Nx*Ny,1);
    end
end
%there are some alternative ways you could consider renormalizing this
%matrix, but we decided not to use any of these..
%trans_prob=trans_prob./repmat(sum(trans_prob),Nx*Ny,1);
%trans_prob=trans_prob./repmat(sum(trans_prob,2),1,Nx*Ny);

%translate it into a log probability
trans_prob=log(trans_prob);

%image the whole matrix if you want
% figure(20);
% imagesc(trans_prob);
% colorbar;

frames=1:20;
%this is going to be the matrix which keeps track of the transition which
%was the most probable way to get to a particular state from the previous
%state.. we will fill this matrix up, and the backtrack the most probable
%path as is the standard way of the veterbi algorithm.
savemax=zeros(Nx*Ny,length(frames)*Nh,'int16');

%P is the probability vector which describes the maximal probability of
%being in a particular state at the current time step as we march forward
%we will start with a uniform distribution across offsets
P=ones(1,Nx*Ny);

%vector to save the time it took to process each frame
tocs=zeros(numframes,1);

%index which will march over lines considered
m=0;

%loop over all frames
for i=frames
    %note the time
    tic
    %loop over all the lines considered in that frame
    for j=1+edgebuffer:Nh-edgebuffer

        %increment our index for lines considered
        m=m+1;

        %replicate the starting probabilities at the time step before for
        %all the possible offsets
        Prep=repmat(P,Nx*Ny,1);
        %calculate the matrix of probabilities of being in one state at
        %the previous time point and then transitioning to another
        Pnew=Prep+trans_prob;

        %this was my C implementation of the previous 2 lines.. it speeds
        %things up but i have disabled it here... if you want to compile
        %the C for your platform you can.. the file there.
        % Pnew = makepifast(trans_prob,P);

        %calculate the most probable way to wind up in a given state, and
        %what the probability is.. save which path you took to get that
        %value, and update P.
        [P,savemax(:,m)]= max(Pnew',[],1);

        %now add in the fit data to adjust the probability of being in a
        %given state.

        %pull out the relevant matrix of values
        PI=squeeze(PIsave(m,:,:));

        %          figure(10);
        %          imagesc(PI);
        %          drawnow;
        %          pause(.1);

        %reshape them into a vector
        PIvec=reshape(PI,Nx*Ny,1);

        %i shift all the probabilities by the mean just to keep things
        %from hitting round off errors.. this doesn't affect the
        %calculation, just keeps things reasonable.
        PIvec=PIvec/gain;
        PIvec=PIvec-mean(PIvec);



        %add on the fits to the probabilities

        P=P+PIvec';

        %plot out the maximal probabilities and the fits if you want
        % figure(60);
        % imagesc(reshape(P,Nx,Ny));
        % figure(61);
        % imagesc(reshape(PIvec,Nx,Ny));
    end

    %note the time
    tocs(i)=toc;

    %calculate the average time per frame so far
    delframes=mean(tocs(max(i-9,1):i));
    %use that to estimate the time remaining
    minremain=(length(frames)-i)*delframes/60;
    %display what frame you are on, how long it should take, and how long
    %the current frame took
    if (debug_flag > 0) ; waitbar((jj-1)/length(lambdas)+dl*(i/length(frames)),h,['Lambda=' num2str(lambda) ' Frame ' num2str(i)]); end
    %disp([i minremain tocs(i)]);

end



clear offsets;
numlines=m;

%find the state that was the most probable ending point
%and what the total probablity was for this value of lambda
[totprob,mprob]=max(P);

%initialize the path of most probable states
thepath=zeros(1,numlines);

%for my interest i save the fits along the path
PIpath=zeros(1,numlines);
%calculate the total fit for this path without considering transition
%probabilities.
Ptot=0;

%march backward from the last line considered to the first
for k=numlines:-1:1
    %pull out the fits from the current line
    PI=squeeze(PIsave(k,:,:));
    %turn it into a vector
    PIvec=reshape(PI,Nx*Ny,1);

    %what is the fit for the most probable state at this timepoint
    PIpath(k)=PIvec(mprob);
    %add that to the total fit
    Ptot=Ptot+PIvec(mprob);

    %save that point along the path
    thepath(k)=mprob;
    %remember what was the most probable way was to get to that state.. update mprob
    mprob=savemax(mprob,k);
end

%unhash the path in terms of state index into a pair of offsets
offsets(1,:)=mod(thepath,Ny);
offsets(1,find(offsets(1,:)==0))=Ny;
offsets(1,:)=offsets(1,:)-maxdy-1;;
offsets(2,:)=((thepath-mod(thepath,Ny))/Ny)-maxdx;

%adjust for the alignments between reference frames
%offsetfix=1:numlines;
%offsetfix=floor(offsetfix/(Nh-2*edgebuffer));
%offsetfix=floor(offsetfix/framesper30sec)+1;
%offsetfix=stilloffsets(offsetfix,:)';
%offsets=offsets-offsetfix;

%plot out the offsets
if (debug_flag > 1)
	figure(2);
	set(gcf,'Position',[50 200 750 500]);
	plot(offsets');
	title(['\lambda' sprintf(' = %6.5f',lambda)]);
	xlabel('line number');
	ylabel('offset (relative pixels)');
end


function [PIsave, maxdx, maxdy, Nx, Ny, Nh, Nw, numframes, edgebuffer, gain, framesper30sec, chone] = ...
	extern_dombeck_split_createPI(chone,maxdx,maxdy,refimage, debug_flag)
%split_createPI(filename,maxdx,maxdy)
%FILENAME is the file located in the data directory you want to correct
%MAXDX is the maximum offset in pixels you estimate is observed in the X
%direction (across columns)
%MAXDY is the maximum offset in pixels you estimate is observed in the Y
%direction (across rows)
%these two parameters should be set high enough so that the maximal offset
%is never reached, but as small as possible as the running time increases and
%accuracy of placement decreases as these values get larger.
%NUMCHANNELS is the number of channels in the movie
tic;
%filename to be analyzed, path from one level up from where the script is
%filename=['data/' filename];
%if ~exist('filename')
%    [filename,path]=uigetfile('*.tif','pick your tif file');
%else
%    path='../';
%end

%these two parameters are the maximum offsets to consider in pixels across
%the whole movie, these should be set high enough that that offset is never
%reached, but as small as possible as the running time increases and
%accuracy of placement decreases as these values get larger
%maxdx=input('max delta X: ');
%maxdy=input('max delta Y: ');
% maxdx=5;
% maxdy=5;

Nx=2*maxdx+1;
Ny=2*maxdy+1;

%creates the full filename with the path, and extracts the number of frames
%etc from the tiff file information
if (length(size(chone)) == 2)
  numframes = 1;
	Nh = size(chone,1);
	Nw = size(chone,2);
else % why? bc this was done dumb - frame dimension should be THREE
  numframes = size(chone,1);
	Nh = size(chone,2);
	Nw = size(chone,3);
end
msecperframe=(1000/7.91); % ORIG: 2*N
framesper30sec=floor(30000/msecperframe);

stop=false;

		gs = min(50, ceil(numframes/5)); % used to be fixed to 50 but we are much shorter
    gain=extern_dombeck_find_gain(chone,gs, debug_flag);
    %make sure there are no zeros .. ln(0) is bad
    if (debug_flag > 0)
		  h = waitbar(0.0,'Finding Reference Images...');
      set(h,'Name','Calculating PI');
		end
    chone(find(chone<1))=1;
    %chone=chone/gain;
    numstills=floor(numframes/framesper30sec)+1;
    for i=1:numstills
        [minval,minimage]=min(mean(mean(abs(diff(chone(1+(i-1)*framesper30sec:min(i*framesper30sec,numframes),:,:),1)),2),3));
        stillimages(i,:,:)=chone(minimage+(i-1)*framesper30sec,:,:);
    end


edgebuffer=maxdy;

%this function aligns all the reference frames to another using maximal
%cross correlation looking over a range of offsets (in this case 5)
%hopefully these values should all be very small as the reference frames
%have basically the same overall shape.. we found this to be true in our
%data but it is not gaurunteed.
if (debug_flag > 0) ; waitbar(0.1,h,'Aligning Reference Images...'); end

% --- TOTALLY UNNECESSARY
%stilloffsets=extern_dombeck_refs_align(stillimages,5)
%size(stilloffsets)
%stilloffsets = zeros(size(stilloffsets));
frames=1:numframes;

%this is the total number of lines we will consider placing since we don't
%try to place the top/bottom maxdy lines
numlines=(Nh-2*edgebuffer+1)*numframes; % ORIG: N

%this is the matrix for which we will store the fits for each offset.
PIsave=zeros(numlines,Ny,Nx);
%m is the index we will use to order the lines for which we have placed
m=0;
%this stores which line of the data is at which index
msave=zeros(numlines,2);
%this stores the times it took to do each frame for my crude progress bar
tocs=zeros(numframes,1);

if (debug_flag > 0 ) ; waitbar(0.2,h,'Calculating PI...'); end
for i=frames
    %note the time at the start of the frame
    tic;
    %which reference frame are we aligning to
    stillindex=floor(i/framesper30sec)+1;
    %pull out that reference frame
%size(refimage)
%imshow(refimage, [0 500]);
%    refimage=squeeze(stillimages(stillindex,:,:));
%figure;imshow(refimage, [0 500]);
%min(min(refimage))
%pause;
    %scan over all the lines in that frame that we are considering
%ORIG:    for j=1+edgebuffer:N-edgebuffer
    for j=1+edgebuffer:Nh-edgebuffer
        %increment our index
        m=m+1;
        %note which line it is
        msave(m,:)=[i j];

        %pull out the line we are placing
        lineextract=squeeze(chone(i,j,:));
        %this function takes the line we are trying to fit, the reference
        %image.. the maximum offsets, and the expected position of the line
        %and returns the log fit probabilities into the PIsave matrix
        %see create_fit_markov for more details
        PIsave(m,:,:)=extern_dombeck_create_PI_markov(lineextract,refimage,maxdx,maxdy,j, debug_flag);

        %this is if you wanted to visualize the fits as they are being made
        %useful for debugging, but slow.
        %       figure(1);
        %       imagesc(squeeze(PIsave(m,:,:)));
        %       %colorbar;
        %       pause(.05);
    end
    %note the time at the end of the frame
    tocs(i)=toc;

    %estimate the average time it took for frames to be processed
    delframes=mean(tocs(max(i-9,1):i));
    %use that to estimate the time remaining
    minremain=(numframes-i)*delframes/60;
    %show what frame you are on, how much time is remaining and how much
    %time that frame took
    if (debug_flag > 0 ) ; waitbar(0.2+.7*(i/length(frames)),h,['Frame ' num2str(i) ', ETA ' num2str(minremain) ' min']); end
    %disp([i minremain tocs(i)]);

end

%find where in the fullfilename the filename is, and cut out the string of
%the filename without the .tif
%use that to save every variable into a _PI.mat file in one directory up,
%then down to matfiles.
%junk=strfind(filename,'/');
%if ~isempty(junk)
%    filebase=filename(junk(end)+1:end-4);
%else
%    filebase=filename(1:end-4);
%end
%disp('Saving results of PI calculation');
%waitbar(0.9,h,'Saving results of PI');
%save(['../matfiles/' filebase '_PI.mat']);
if (debug_flag >  0 ) ; waitbar(1,h,'Done!'); end
if exist('h') delete(h); end



function [fixeddata,countdata]=playback_markov(imagedata,offsets,edgebuffer,playback,totvel)
%fixeddata,countdata]=playback_markov(imagedata,offsets,edgebuffer,playback,totvel)

%pick out the number of frames and size of images
numframes=size(imagedata,1);
Nh=size(imagedata,2);
Nw=size(imagedata,3);


%dynamically set the dynamic range for playback by taking the 99.99% pixel
%removes outliers. can adjust downward for automated gain control
sortpix=imagedata(1:3,:,:);
sortpix=sortpix(:);
sortpix=sort(sortpix);
k=round(length(sortpix)*.9999);
maxpixel=sortpix(k)
minpixel=sortpix(1)


%initialize the data 
countdata=int8(zeros(numframes,Nh,Nw));
fixeddata=zeros(numframes,Nh,Nw);

%in case you just wanted to do a few frames
frames=1:numframes;

%index for offsets
m=0;


for i=frames
    %initialize a matrix just for this frame for simplicity
    correctimage=zeros(Nh,Nw);
    countimage=zeros(Nh,Nw);
    %loop over the lines we are considering placing
    for j=1+edgebuffer:Nh-edgebuffer
        %increment the offset counter
        m=m+1;
        
        %pick out the line of the data we are placing
        lineextract=squeeze(imagedata(i,j,:));
 
        %pick out the line number where it is going
        linenumber=offsets(1,m)+j;
        %pick out the relative shift in X within that line
        shift=offsets(2,m);
   
        %need different bounds for shifts left and shifts right
        %but in general increments correctimage and countimage correctly
        if shift<0    
            correctimage(linenumber,1:end+shift)=correctimage(linenumber,1:end+shift)+lineextract(1-shift:end)';
            countimage(linenumber,1:end+shift)=countimage(linenumber,1:end+shift)+ones(1,Nw+shift);
        
        else
            correctimage(linenumber,shift+1:end)=correctimage(linenumber,shift+1:end)+lineextract(1:end-shift)';
            countimage(linenumber,shift+1:end)=countimage(linenumber,shift+1:end)+ones(1,Nw-shift);
        end
      
    end
    %show the framenumber you have just completed
    disp(i);
    %store the results into the data structure
    fixeddata(i,:,:)=correctimage;
    countdata(i,:,:)=countimage;

    %if you want to visualize the results do so
    if playback

        
        figure(3);
        clf;
        set(gcf,'Position',[50 314 560 420]);
        %finds those pixels which were not sampled and sets their counts to
        %infinity for display purposes
        badones=find(countimage==0);
        countimage(badones)=Inf;
        
        %display, normalizing for multiple samples
        imagesc(correctimage./(countimage));
        colormap(gray);
        %set the dynamic range
        caxis([minpixel maxpixel]);
        %title it by frame number
        title(num2str(i));
        
        figure(4);
        clf;
        set(gcf,'Position',[50+560 314 560 420]);
        
        imagesc(squeeze(imagedata(i,:,:)));
        colormap gray;
        caxis([minpixel maxpixel]);
        title(num2str(i));
        pause(.1);
        
    end

end


