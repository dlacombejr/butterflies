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

% set up path
path = 'butterflyphotos/';
addpath(genpath(path))

% get folder names
folderNames = dir(path);
folderNames = folderNames(~strncmpi('.', {folderNames.name}, 1));

%%% TEST CLASSIFICATION PERFORMANCE OF LEARNED PATCHES %%%
% read in the catergory-specific dictionaries
load 'Butterfly_LCA_W.mat' W

% set environment variables
nk = size(W, 3); % number of classes
ps=16; % patch size
channels = 3; % number of chennels
ims=64; %maximum size of longest image dimension
patch_size = ps ^ 2 * channels; % vectorized patch size
neurons = 256; % number of neurons
maxIter = 1000; % max iterations
s = 0.15; % threshold value

% concatenating the dictionary elements
WW = [];
for k = 1:nk
    WW = [WW, W(:,:,k)];
end

% test classification performance
performance_vector = [];
CSD_cache = [];
for k = 1:nk
    
    % load in test patches
    filename = ['butterflydata/', folderNames(k).name, '_test.mat'];
    X1 = load(filename);
    X0 = X1.Xtest;
    
    % uncell the test data
    test_index = zeros(size(X0, 1), 2);
    temp = [];
    for m = 1:size(X0, 1)
        if m == 1
            test_index(m, :) = [1, size(X0{m}, 2)];
        else
            step = test_index(m - 1, 2) + 1;
            test_index(m, :) = [step, step + size(X0{m}, 2) - 1];
        end
        temp = [temp, X0{m}];
    end
    X0 = temp; 
    
    % preprocess data
    X0=sqrt(0.1)*X0/sqrt(mean(var(X0)));
%     X2=X0(:,floor(end/2)+1:end);
    
    % recell the test data
    temp = cell(size(test_index, 1), 1); 
    for i = 1:size(test_index, 1)
        temp{i} = X0(:, test_index(i, 1):test_index(i, 2)); 
    end
    Xtest = temp;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % normalize weights and get similarity matrix
    WW = WW * diag(1 ./ sqrt(sum(WW .^ 2,1)));
    G = WW'*WW - eye(neurons*nk);
    
    % loop over images for category
    nImages = size(Xtest, 1);
    for img = 1:nImages
        
        % get current test image
        X = Xtest{img};
        
        %%% LCA %%%
        b = WW'*X;
        u = zeros(neurons*nk,size(X, 2));
        
        for i =1:20
            
            a=u.*(abs(u) > s);
            u = 0.9 * u + 0.01 * (b - G*a);
            
        end
        %%% \LCA %%%
        
        % l2 norm across patches (single value for each neuron)
        a1=sum(a.^2,2);
        
        % perform l1 pooling across all elements belonging to CSD
        CSD_activations=[];
        for j=1:nk
            CSD_activations = [CSD_activations, sum(abs(a1(1+(j-1)*neurons:j*neurons)))];
        end
        
        % determine the class with the highest l1 pool
        [value, class]=max(CSD_activations);
        
        % assign invalid class if no class is given
        if sum(CSD_activations)==0
            class = -1;
        end
        
        % append performance value based on whether class is predicted
        performance_vector = [performance_vector, class == k];
        
        % save the activation profile to cache
        CSD_cache=[CSD_cache; CSD_activations];
        
        % visualize the performance
        subplot(1, 2, 1)
        bar(CSD_activations)
        subplot(1, 2, 2)
        plot(CSD_cache)
        
    end
    
end

% calculate accuracy
accuracy = sum(performance_vector) / length(performance_vector);
disp(['Accuracy: ', num2str(accuracy)])