%%% CREATE IMAGE PATCHES FOR TRAINING AND TESTING %%%

% set up path
path = 'butterflyphotos/';
uPath = 'utilities/'; 
addpath(genpath(path))
addpath(genpath(uPath))

% get folder names
folderNames = dir(path);
folderNames = folderNames(~strncmpi('.', {folderNames.name}, 1));

% loop over butterfly classes and grab random patches
for k = 1:nk
    
    % grab the k-th folder
    foldername = folderNames(k).name;
    
    % get the image file names
    imDir = dir([path, foldername, '/*.jpg']);
    images = {imDir.name};
    nImages = length(images); 
    
    % create empty data array and grab patches
    split = floor(nImages/3); % test then train (1/3, and 2/3, respectively)
    Xtrain = [];
    Xtest = []; 
    test_index = zeros(split, 2); 
    for i=1:nImages
        
        i
        
        % read in image
        b1 = imread(images{i});
        
        % get resizing dimensions
        s1 = size(b1);
        if(s1(1) > s1(2))
            ns1=[ims NaN];
        else
            ns1=[NaN ims];
        end
        
        % resize image
        b1=im2double(imresize(b1,ns1));
        
        % normalize image
        b1 = b1 - min(b1(:));
        b1 = b1 / max(b1(:));
        
        % separate color channels and grab patches
        c1r=im2col(b1(:,:,1),[ps ps]);
        c1g=im2col(b1(:,:,2),[ps ps]);
        c1b=im2col(b1(:,:,3),[ps ps]);
        
        % concatenate data and put into master matrix
        c=[c1r; c1b; c1g];
        
        % assign patches to matrix based on image number
        if i <= split
            if i == 1
                test_index(i, :) = [1, size(c, 2)]; 
            else
                step = test_index(i - 1, 2) + 1; 
                test_index(i, :) = [step, step + size(c, 2) - 1];
            end
            Xtest = [Xtest, c]; 
        else
            Xtrain = [Xtrain, c]; 
        end
        
    end
    
    % whiten the image patches
    Xtrain=whiten_patches(Xtrain);
    Xtest=whiten_patches(Xtest);
        
    % put test images into cell array
    temp = cell(split, 1); 
    for i = 1:split
        temp{i} = Xtest(:, test_index(i, 1):test_index(i, 2)); 
    end
    Xtest = temp;
    
    % save the data
    disp('saving...')
    save(['butterflydata/', foldername '_train.mat'],'Xtrain','-v7.3')
    save(['butterflydata/', foldername '_test.mat'],'Xtest','-v7.3')
    disp('...done')

end
