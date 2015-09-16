% set up path
path = 'butterflyphotos/';
uPath = 'utilities/'; 
addpath(genpath(path))
addpath(genpath(uPath))

% get folder names
folderNames = dir(path);
folderNames = folderNames(~strncmpi('.', {folderNames.name}, 1));

% set environment variables
nk = numel(folderNames);
ps=16; % patch size
channels = 3;
ims=64; %maximum size of longest image dimension

%%% MAKE CLASS-SPECIFIC DICTIONARY ELEMENTS %%%
% set environment parameters
s = 0.1; % treshold
patch_size = ps ^ 2 * channels;
neurons = 256;
batch_size = 100;
W = randn(patch_size, neurons, nk);
maxIter = 1000;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% loop over butterfly classes
for k=1:nk
    
    % load the training patches
    filename = ['butterflydata/', folderNames(k).name, '_train.mat'];
    X1 = load(filename);
    X0 = X1.Xtrain;
    
    % preprocess data
    X0=sqrt(0.1)*X0/sqrt(mean(var(X0)));
    X1=X0(:,1:floor(end/2));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % loop over training iterations
    for j=1:maxIter
        
        % select random mini-batch
        r=randperm(size(X1,2));
        X=X1(:,r(1:batch_size));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % normalize the weights
        W(:,:,k) = W(:,:,k)*diag(1./sqrt(sum(W(:,:,k).^2,1)));
        
        %%% LCA %%%
        b = W(:,:,k)'*X;
        G = W(:,:,k)'*W(:,:,k) - eye(neurons);
        
        u = zeros(neurons,batch_size);
        for i =1:20
            
            a=u.*(abs(u) > s);
            u = 0.9 * u + 0.01 * (b - G*a);
            
        end
        %%% \LCA %%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % update the weight parameters
        W(:,:,k) = W(:,:,k) + (1/batch_size)*((X-W(:,:,k)*a)*a');
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % visualize the learned parameters for the j-th learning iteration
        imagesc(filterplotcolor(W(:,:,k)')), drawnow()
        
        % display training iteration
        disp([folderNames(k).name, ' dictionary: Iteration ', num2str(j)])
        
    end
    
end

% save the weights for all butterfly dictionaries
save('Butterfly_LCA_W.mat','W')
