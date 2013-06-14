clear;clc;close all;delete('test.ppt');
a=figure('Visible','off');plot(1:10);
b=figure('Visible','off');plot([1:10].^2);
c=figure('Visible','off');plot([1:10].^3);
d=figure('Visible','off');plot([1:10].^4);

%% Test the columns
for i=1:6
 saveppt2('test.ppt','figure',[a b c d],'columns',i)
end
%% Test the columns w/stretching
for i=1:4
 saveppt2('test.ppt','figure',[a b c d],'columns',i,'stretch')
end
% 
%% Test the columns with a title
for i=1:4
 saveppt2('test.ppt','figure',[a b c d],'columns',i,'title',['Columns ' num2str(i)])
end

%% Test padding
saveppt2('test.ppt','figure',[a b c d],'columns',2,'padding',20)
saveppt2('test.ppt','figure',[a b c d],'columns',2,'padding',[20 0 0 0])
saveppt2('test.ppt','figure',[a b c d],'columns',2,'padding',[0 20 0 0])
saveppt2('test.ppt','figure',[a b c d],'columns',2,'padding',[0 0 20 0])
saveppt2('test.ppt','figure',[a b c d],'columns',2,'padding',[0 0 0 20])
% 
%% Test renderers
saveppt2('test.ppt','figure',[a b],'stretch','render','painters')
saveppt2('test.ppt','figure',[a b],'stretch','render','zbuffer')
saveppt2('test.ppt','figure',[a b],'stretch','render','opengl')
saveppt2('test.ppt','figure',[a b],'stretch','render')

%% Test alignment
saveppt2('test.ppt','figure',[a b],'halign','left')
saveppt2('test.ppt','figure',[a b],'halign','right')
saveppt2('test.ppt','figure',[a b],'halign','center')
saveppt2('test.ppt','figure',[a b],'valign','top')
saveppt2('test.ppt','figure',[a b],'valign','bottom')
saveppt2('test.ppt','figure',[a b],'valign','center')

%% Test alignment w/title
saveppt2('test.ppt','figure',[a b],'halign','left','title','left')
saveppt2('test.ppt','figure',[a b],'halign','right','title','right')
saveppt2('test.ppt','figure',[a b],'halign','center','title','center')
saveppt2('test.ppt','figure',[a b],'valign','top','title','top')
saveppt2('test.ppt','figure',[a b],'valign','bottom','title','bottom')
saveppt2('test.ppt','figure',[a b],'valign','center','title','center')

%% Test alignment w/title
saveppt2('test.ppt','figure',[a b],'halign','left','title','left','columns',1)
saveppt2('test.ppt','figure',[a b],'halign','right','title','right','columns',1)
saveppt2('test.ppt','figure',[a b],'halign','center','title','center','columns',1)
saveppt2('test.ppt','figure',[a b],'valign','top','title','top','columns',1)
saveppt2('test.ppt','figure',[a b],'valign','bottom','title','bottom','columns',1)
saveppt2('test.ppt','figure',[a b],'valign','center','title','center','columns',1)

%% Test alignment
saveppt2('test.ppt','figure',[a],'halign','left')
saveppt2('test.ppt','figure',[b],'halign','right')
saveppt2('test.ppt','figure',[c],'halign','center')
saveppt2('test.ppt','figure',[d],'valign','top')
saveppt2('test.ppt','figure',[a],'valign','bottom')
saveppt2('test.ppt','figure',[b],'valign','center')

%% Test alignment w/Title
saveppt2('test.ppt','figure',[a],'halign','left','title','left')
saveppt2('test.ppt','figure',[b],'halign','right','title','right')
saveppt2('test.ppt','figure',[c],'halign','center','title','center')
saveppt2('test.ppt','figure',[d],'valign','top','title','top')
saveppt2('test.ppt','figure',[a],'valign','bottom','title','bottom')
saveppt2('test.ppt','figure',[b],'valign','center','title','center')

%% Test Notes
saveppt2('test.ppt','notes','Hello World!');
saveppt2('test.ppt','notes','Hello World!\nLine Two');
saveppt2('test.ppt','notes','Hello World!\n\tRow Two, Tabbed');

%% Test Resolution
for i=100:100:500
    saveppt2('test.ppt','resolution',i,'title',['Resolution ' num2str(i)],'scale')
end