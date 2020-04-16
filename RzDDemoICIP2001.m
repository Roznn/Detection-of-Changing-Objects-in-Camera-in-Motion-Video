% RzDDemoICIP2001
% Rozenn Dahyot https://github.com/Roznn 

function RzDDemoICIP2001
clear all; close all

'Replication of results in Fig. 1 DOI:10.1109/ICIP.2001.959126'
%reading the images
I0=imread('images/70.jpg'); figure;imshow(I0),title('I_{70}')
I1=imread('images/75.jpg'); figure;imshow(I1),title('I_{75}')
I2=imread('images/80.jpg');figure;imshow(I2),title('I_{80}')

%Feature computation
[L0,r0,g0]=RzDIrg(double(I0));
[L1,r1,g1]=RzDIrg(double(I1));
[L2,r2,g2]=RzDIrg(double(I2));

%Histograms computation
ResHistColour=[0 1 21; 0 1 21];
[Histo0,Ind0]=RzDHistogram([r0(:) g0(:)]',ResHistColour);Histo0=Histo0/sum(Histo0(:));
[Histo1,Ind1]=RzDHistogram([r1(:) g1(:)]',ResHistColour);Histo1=Histo1/sum(Histo1(:));
[Histo2,Ind2]=RzDHistogram([r2(:) g2(:)]',ResHistColour);Histo2=Histo2/sum(Histo2(:));

HOA=max(Histo1-2*Histo2,0); % Eq. (5)
HOD=max(Histo1-2*Histo0,0);  % Eq. (8)

%Backprojection maps
maplikA=RzDBackprojection(Ind1,HOA/sum(HOA(:)));
[height width depth]=size(I1);
figure;imagesc(reshape(maplikA,height,width)), colormap(flipud(gray)),title('Backward back-projection map  in I_{75}')

maplikD=RzDBackprojection(Ind1,HOD/sum(HOD(:)));
figure;imagesc(reshape(maplikD,height,width)), colormap(flipud(gray)),title('Forward back-projection map  in I_{75}')


%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
function [I,r,g]=RzDIrg(image)
% [I,r,g]=RzDIrg(image)
% colour image
% Rozenn Dahyot 2005

if (size(image,3)>1) % colour image
    I=image(:,:,1)+image(:,:,2)+image(:,:,3);
    toto=I;
    mask=(I==0);
    toto(mask)=1; %just to avoid dividing by 0
    r=image(:,:,1)./toto;
    g=image(:,:,2)./toto;
    I=I/(255*3);

else I=image/255;  % grey level image
    r=0;
    g=0;
end

%%
function [Xhisto,IndX]=RzDHistogram(X, hinfo)
% function [Xhisto,IndX]=RzDHistogram(X, hinfo)
% Rozenn Dahyot May 2006
% X: data 
% size(X,1): dimension of the feature space
% size(X,2): Number of features
% hinfo : low bound, upper bound and number of bins for each dimension
% Output
% Xhisto: multidimensional histogram of data X
% IndX: 

X=double(X);
d=size(X,1);
N=size(X,2); 

for i=1:d
    X(i,:)=round(D_normalise(X(i,:), hinfo(i,1), hinfo(i,2))*(hinfo(i,3)-1)) + 1;
    if(i==1)
        dimhisto=[hinfo(i,3)];
    else
        dimhisto=[dimhisto,hinfo(i,3)];
    end
end

Xhisto = zeros(dimhisto);

% size(Xhisto)

if (d==2)
    for i=1:N
        Xhisto(X(1,i),X(2,i))=Xhisto(X(1,i),X(2,i))+1;
    end
else if(d==3)
        for i=1:N
            Xhisto(X(1,i),X(2,i),X(3,i))=Xhisto(X(1,i),X(2,i),X(3,i))+1;
        end
    end
end
IndX=X;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nvals = D_normalise(vals,lower,upper);
nvals = abs((vals-lower)/(upper-lower));

function map=RzDBackprojection(Ind,Histo)
% function map=RzDBackprojection(Ind,Histo)
% Ind: index
% Histo: Histogram to backproject
% Rozenn Dahyot
% 4 october 2006
%

map=zeros(size(Ind(1,:)));

N = ndims(Histo);
if(N==length(Ind(:,1)))
    if (N==1)
        for i=1:length(Ind(1,:))
            map(i)=Histo(Ind(1,i));
        end
    elseif(N==2)
        for i=1:length(Ind(1,:))
            map(i)=Histo(Ind(1,i),Ind(2,i));
        end
    elseif(N==3)
        for i=1:length(Ind(1,:))
            map(i)=Histo(Ind(1,i),Ind(2,i),Ind(3,i));
        end
    else
        'RzDBackprojection is currently not defined for Histogram with more than 3 dimensions'
        return;
    end
end