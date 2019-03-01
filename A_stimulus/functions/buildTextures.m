function [ T ] = buildTextures( S )
%BUILDTEXTURES Build plaid image and frames
%   

disp('[buildTextures] Starting...')
tic

%% Initialize
T = struct();
T.height = S.height;

myAngle = 65;
distanceY = 120;
distanceX = 133;
veloc = 2;
nLoopFramesY = floor(distanceY/veloc);
nLoopFramesX = floor(distanceX/veloc);
linethick = 30;
textureBackColor = S.textBackground;
linesColor = S.lines;
screenBackColor = S.screenBackground;

%% --- Central circle Phantoms: full-screen and partial central square
myPhantom01 = zeros(T.height ,T.height ,'uint8')+255;

for myI=1:size(myPhantom01,1)
    for myJ=1:size(myPhantom01,2)
        if (myI-T.height/2)^2 + (myJ-T.height/2)^2 <= (T.height/2)^2
            myPhantom01(myI,myJ)=0;
        end
    end
end

% Indexes Circle and Exterior
myIndexesCircle = (myPhantom01==255);

%% --- Textures
startLine = 1;
endLine = T.height*2;

startArrayLine = startLine:distanceY:endLine;

T.Template = cell(nLoopFramesY,nLoopFramesX);
T.Textures = cell(nLoopFramesY,nLoopFramesX);

for j = 1:nLoopFramesY % Iterate on the lines
    
    startArrayLine = floor(startArrayLine);
    
    myImage02 = 125*ones(T.height*2,T.height*2,'uint8');
    
    for i=1:size(startArrayLine,2)
        myImage02(startArrayLine(i):min(startArrayLine(i)+linethick-1,endLine),:) = 0;
    end
    
    startLine=startArrayLine(1)+veloc;
    startArrayLine=startLine:distanceY:endLine;
    startArrayLine=[startLine:-distanceY:1,startArrayLine(2:end)];
    
    myImage45=imrotate(myImage02,myAngle,'bicubic');
    [x_med45,y_med45]=size(myImage45);
    x_start45 = floor((x_med45-T.height)/2);
    x_end45 = floor((x_med45+T.height)/2-1);
    y_start45 = floor((y_med45-T.height)/2);
    y_end45 = floor((y_med45+T.height)/2-1);
    
    myImage_45=imrotate(myImage02,-myAngle,'bicubic');
    [x_med_45,y_med_45]=size(myImage_45);
    x_start_45 = floor((x_med_45-T.height)/2);
    x_end_45 = floor((x_med_45+T.height)/2-1);
    y_start_45 = floor((y_med_45-T.height)/2);
    y_end_45 = floor((y_med_45+T.height)/2-1);
    
    for z = 1:nLoopFramesX % Iterate on the columns
        
        myTemp45_aux = myImage45(x_start45:x_end45 , y_start45+(z-1)*veloc:y_end45+(z-1)*veloc);
        
        aux_template1=zeros(T.height,T.height,'uint8');
        aux_template1(myTemp45_aux<60)=1;
        
        myTemp_45_aux = myImage_45(x_start_45:x_end_45 , y_start_45+(z-1)*veloc:y_end_45+(z-1)*veloc);
        
        aux_template2=zeros(T.height,T.height,'uint8');
        aux_template2(myTemp_45_aux<60)=2;
         
        T.Template{j,z} = aux_template1 + aux_template2;
        T.Template{j,z}(myIndexesCircle) = 0;
        
        myTempAll=(myTemp45_aux+myTemp_45_aux)/2;
        
        T.Textures{j,z}=zeros(T.height,T.height,'uint8');
        
        T.Textures{j,z}(:,:)=textureBackColor;
        T.Textures{j,z}(myTempAll<90)=linesColor;
        T.Textures{j,z}(myIndexesCircle)=screenBackColor;
        
    end %  End column iteration
    
end % End line iteration

T.TextureStaticBlack = T.Textures{1,1};
T.TextureStaticBlack(myIndexesCircle) = 0;

fprintf('[buildTextures] Build Time = %.2fs. \n',toc)

T.nTextY = nLoopFramesY;
T.nTextX = nLoopFramesX;

disp('[buildTextures] Saving file to disk...')

save(fullfile(S.input_path,sprintf('Textures_%i_sB%i_tB%i_l%i',T.height,S.screenBackground,S.textBackground,S.lines)),'T','-v7.3');

fprintf('[buildTextures] Done. Total Time = %.2fs. \n',toc)

end % End function
