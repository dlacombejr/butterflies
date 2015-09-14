%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------------------------------------------------%
%
% Machine Perception and Cognitive Robotics Laboratory
%
%     Center for Complex Systems and Brain Sciences
%
%              Florida Atlantic University
%
%------------------------------------------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------------------------------------------------%
% Locally Competitive Algorithms Demonstration
% Using RBG image data, see:
%
% 1)Rozell, Christopher J., et al.
% "Sparse coding via thresholding and
% local competition in neural circuits."
%
% 2)Selesnick, Ivan W. 
% Sparse Signal Restoration. 
% http://cnx.org/content/m32168/. 
%
%------------------------------------------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MPCR_LCA_Dictionary_RGB_Butterfly_v2

clear all
close all
clc

% make_patches
% make_dictionary
test_patches
% 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function make_patches

ps=16;

for k=1:6
    
    foldername=folder(k)
    
    ims=64;
    
    cd(['/Users/williamedwardhahn/Desktop/thesis/butterflies/' foldername '/'])
    
    ls
    
    dr1=dir('*.jpg')
    
    f1={dr1.name}; 
    X=[];
    
    for i=1:length(f1) 
        
        i
        
        a1=f1{i};
        
        b1=imread(a1);
    
        s1=size(b1);
        
        if(s1(1) > s1(2))
            ns1=[ims NaN];
        else
            ns1=[NaN ims];
        end
        
        b1=im2double(imresize(b1,ns1));
        
        b1 = b1 - min(b1(:));
        b1 = b1 / max(b1(:));

        c1r=im2col(b1(:,:,1),[ps ps]);
        c1g=im2col(b1(:,:,2),[ps ps]);
        c1b=im2col(b1(:,:,3),[ps ps]);
        
        c=[c1r; c1b; c1g];
        
        X=[X, c];
        
    end
     
    X=whiten_patches(X);
   
    disp('saving...')
    save(['HahnColorPatches_' num2str(ps) '_Butterflies_' foldername '_whitened1.mat'],'X','-v7.3')
    disp('...done')
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function make_dictionary


s=0.1;
patch_size=256*3;
neurons=256;
batch_size=100;
nk=6;
W = randn(patch_size, neurons, nk);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for k=1:6
    
    X1=load_train_patches(k); 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for j=1:1000
        
        r=randperm(size(X1,2));
        
        X=X1(:,r(1:batch_size));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        W(:,:,k) = W(:,:,k)*diag(1./sqrt(sum(W(:,:,k).^2,1)));
        
        b = W(:,:,k)'*X;
        G = W(:,:,k)'*W(:,:,k) - eye(neurons);
        
        u = zeros(neurons,batch_size);
        
        for i =1:20
            
            a=u.*(abs(u) > s);
            
            u = 0.9 * u + 0.01 * (b - G*a);
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        W(:,:,k) = W(:,:,k) + (1/batch_size)*((X-W(:,:,k)*a)*a');
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        imagesc(filterplotcolor(W(:,:,k)')), drawnow()
        
        j
        
    end
    
end

save('Butterfly_LCA_W.mat','W')


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function test_patches

load('Butterfly_LCA_W.mat')

s=0.15;
patch_size=256*3;
neurons=256;
batch_size=1000;
nk=size(W,3);

% figure(1)
% drawnow()
% set(gcf,'color','w');
% pause
% 
% for k=1:nk
%     subplot(2,3,k)
%     imagesc(filterplotcolor(W(:,:,k)')), drawnow()
%     title(folder(k),'Interpreter', 'none', 'FontSize', 20)
%     pause
% end
% 
% return

WW=[];

for k=1:size(W,3)
    
    WW=[WW W(:,:,k)];
    
end

% WW=randn(size(WW)); %Randomize weights to test

d=[];
bb=[];
for k=1:nk
    
    X2=load_test_patches(k);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    WW = WW*diag(1./sqrt(sum(WW.^2,1)));
    G = WW'*WW - eye(neurons*nk);
    
    for j=1:20
        
        r=randperm(size(X2,2));
        
        X=X2(:,r(1:batch_size));
        
%         imagesc(filterplotcolor(X(:,1:400)'))
%         set(gcf,'color','w');
%         title(folder(k),'Interpreter', 'none', 'FontSize', 20)
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        b = WW'*X;
        
        u = zeros(neurons*nk,batch_size);
        
        for i =1:20
            
            a=u.*(abs(u) > s);
            
            u = 0.9 * u + 0.01 * (b - G*a);
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        a1=sum(a.^2,2);
        
        b=[];
        
        for j=1:nk
            
            b=[b sum(abs(a1(1+(j-1)*neurons:j*neurons)))];
            
        end
        
        subplot(121)
        bar(b)
        
        
        
        
        
        [b1,b2]=max(b);
        
        if sum(b)==0
            
            b2=-1;
            
        end
        
        d=[d b2==k];
        
        subplot(122)
        
%         hist(d,0:1)
        
        bb=[bb; b];
        
        plot(bb)
        
        drawnow()
        
    end
    
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function foldername=folder(k)

switch k
    case 1
        foldername='admiral';
    case 2
        foldername='black_swallowtail';
    case 3
        foldername='machaon';
    case 4
        foldername='monarch_open';
    case 5
        foldername='peacock';
    case 6
        foldername='zebra';
    otherwise
        disp('error');
end


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function X1=load_train_patches(k)

ps=16;

foldername=folder(k);

cd('/Users/williamedwardhahn/Desktop/thesis/butterflies/butterflydata')

data=load(['HahnColorPatches_' num2str(ps) '_Butterflies_' foldername '_whitened.mat'])

X0=data.X;

X0=sqrt(0.1)*X0/sqrt(mean(var(X0)));

X1=X0(:,1:floor(end/2));

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function X2=load_test_patches(k)

ps=16;

foldername=folder(k);

cd('/Users/williamedwardhahn/Desktop/thesis/butterflies/butterflydata')

data=load(['HahnColorPatches_' num2str(ps) '_Butterflies_' foldername '_whitened.mat']);

X0=data.X;

X0=sqrt(0.1)*X0/sqrt(mean(var(X0)));

X2=X0(:,floor(end/2)+1:end);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function X=whiten_patches(X)

% Whiten Images in Matlab
% http://xcorr.net/2013/04/30/whiten-images-in-matlab/

X = bsxfun(@minus,X,mean(X)); %remove mean
fX = fft(fft(X,[],2),[],3); %fourier transform of the images
spectr = sqrt(mean(abs(fX).^2)); %Mean spectrum
X = ifft(ifft(bsxfun(@times,fX,1./spectr),[],2),[],3); %whitened X


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [D] = filterplotcolor(W)

Dr=filterplot(W(:,1:size(W,2)/3));
Dg=filterplot(W(:,size(W,2)/3+1:2*size(W,2)/3));
Db=filterplot(W(:,2*size(W,2)/3+1:end));
D=zeros(size(Dr,1),size(Dr,2),3);
D(:,:,1)=Dr;
D(:,:,2)=Db;
D(:,:,3)=Dg;
D = D - min(D(:));
D = D / max(D(:));

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [D] = filterplot(X)

[m,n] = size(X);
w = round(sqrt(n));
h = (n / w);
c = floor(sqrt(m));
r = ceil(m / c);
p = 1;
D = - ones(p + r * (h + p),p + c * (w + p));
k = 1;
for j = 1:r
    for i = 1:c
        D(p + (j - 1) * (h + p) + (1:h), p + (i - 1) * (w + p) + (1:w)) = reshape(X(k, :), [h, w]) / max(abs(X(k, :)));
        k = k + 1;
    end
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%