function [ OutputLoc ] = runLocalizer( S )
%RUNLOCALISER3 Stimulus function for the Localiser
% Usage: [ OutputLoc ] = runLocaliser( S );
%
% Inputs:
%   : S - struct containing very important info (screen, subject, colors,
%   trigger, response box, eyetracker, etc)
%
% Outputs:
%   : OutputLoc - struct containing time of start, end and trigger of the
%   stimulation.
%

% Screen('Preference', 'SkipSyncTests', 1);

OutputLoc = struct();

%% Read PRT
load(fullfile(S.input_path,'Protocols_Localizer.mat'),...
    'condNames','framesCond','nCond','nFrames','nVols');

movingIdx = 3; % index of the moving conditions

%% Dots Properties
dots = struct();
dots.nDots = 350;                % number of dots
dots.color = [255,255,255];      % color of the dots
dots.size = 6;                   % size of dots (pixels)
dots.apertureSize = [9,9];       % size of rectangular aperture [w,h] in degrees.

dots.speed = 3;       %degrees/second

dots.direction = [ 0 45 90 120 180 225 270 315 ];  %degrees (clockwise from straight up)
dots.nDir = length(dots.direction);

% Start at the center of the screen
dots.center = [0,0];

% Calculate the left, right top and bottom of the aperture (in degrees)
dots.l = dots.center(1)-dots.apertureSize(1)/2;
dots.r = dots.center(1)+dots.apertureSize(1)/2;
dots.b = dots.center(2)-dots.apertureSize(2)/2;
dots.t = dots.center(2)+dots.apertureSize(2)/2;

% New random starting positions
dots.x = (rand(1,dots.nDots)-.5)*dots.apertureSize(1) + dots.center(1);
dots.y = (rand(1,dots.nDots)-.5)*dots.apertureSize(2) + dots.center(2);

%% Stim

try
    % -- Open Window
    [ windowID , winRect ] = Screen('OpenWindow', S.screenNumber , S.black);
    
    % -- Center Variables
    [S.xCenter, S.yCenter] = RectCenter(winRect);
    
    % -- Rendering Options
    Screen('BlendFunction', windowID, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    % -- Select specific text font, style and size
    Screen('TextFont', windowID , 'Arial');
    Screen('TextSize', windowID , 30);
    
    % -- Hide Cursor
    HideCursor;
    
    % -- Initialise EyeTracker
    if S.EYETRACKER
        eyeTrackerInit( windowID , S , 'L3');
    end
    
    % -- Start Eyetracker
    if S.EYETRACKER
        eyeTrackerStart();
    end
    
    % -- Wait for Key Press or Trigger
    if S.TRIGGER
        DrawFormattedText(windowID, 'Waiting to start...', 'center', 'center', S.white);
        Screen('Flip',windowID);
        disp('[runLocalizer] Waiting for trigger...')
        
        [gotTrigger, timeStamp] = waitForTrigger(S.syncbox_handle,1,300); % timeOut = 5 min (300s)
        if gotTrigger
            disp('[runLocalizer] Trigger Received.')
            IOPort('Flush', S.syncbox_handle);
            IOPort('Purge', S.syncbox_handle);
        else
            disp('[runLocalizer] Trigger Not Received. Aborting!')
            return
        end
    else
        DrawFormattedText(windowID, 'Press Enter to Start', 'center', 'center', S.white);
        Screen('Flip',windowID);
        disp('[runLocalizer] Waiting to start...')
        KbPressWait;
    end
    
    % Frame Iteration
    disp('[runLocalizer] Starting iteration...')
    
    init = GetSecs;
    
    for i = 1:nFrames % Iteration on the frames
        
        % -- Determine current condition
        c = framesCond(i);
        
        if c ~= 1 % Not Rest condition
            
            % Use the equation of an ellipse to determine which dots fall inside.
            goodDots = ((dots.x-dots.center(1)).^2/(dots.apertureSize(1)/2)^2 + ...
                (dots.y-dots.center(2)).^2/(dots.apertureSize(2)/2)^2) < 1;
            
            pixpos.x = angle2pix(S.width,S.screenX,S.dist,...
                dots.x)+ S.screenX/2;
            pixpos.y = angle2pix(S.width,S.screenX,S.dist,...
                dots.y)+ S.screenY/2;
            
            % Draw Dots
            Screen('DrawDots',windowID,...
                [pixpos.x(goodDots);pixpos.y(goodDots)], dots.size, ...
                dots.color,[0,0],1);
                       
            if c == movingIdx % Moving condition
                
                if changeDir
                    changeDir = false;
                    
                    % Movement
                    dx = cell(1,dots.nDir);
                    dy = cell(1,dots.nDir);
                    
                    for d = 1:dots.nDir                       
                        dx{d} = dots.speed*sin(dots.direction(d)*pi/180)/S.fps;
                        dy{d} = -dots.speed*cos(dots.direction(d)*pi/180)/S.fps;           
                    end
                    
                    idx = randperm(dots.nDots);
                end
                
                % Update the dot position
                for d = 1:dots.nDir 
                    dots.x(idx(d:dots.nDir:end)) = dots.x(idx(d:dots.nDir:end)) + dx{d};
                    dots.y(idx(d:dots.nDir:end)) = dots.y(idx(d:dots.nDir:end)) + dy{d};           
                end
                
                % Move the dots that are outside the aperture back one aperture width.
                dots.x(dots.x<dots.l) = dots.x(dots.x<dots.l) + dots.apertureSize(1);
                dots.x(dots.x>dots.r) = dots.x(dots.x>dots.r) - dots.apertureSize(1);
                dots.y(dots.y<dots.b) = dots.y(dots.y<dots.b) + dots.apertureSize(2);
                dots.y(dots.y>dots.t) = dots.y(dots.y>dots.t) - dots.apertureSize(2);
                
            end
            
        else % Rest condition
            changeDir = true;
        end
        
        % Fixation Cross
        drawFixationCross( windowID , S , 101 , 0 );
        
        % Do it
        Screen('Flip',windowID);
        
        % -------- KEYS --------
        [~,~,keyCode] = KbCheck();
        if keyCode(KbName('escape')) == 1 %Quit if "Esc" is pressed
            throw(MException('user:escape','Aborted by escape key.'))
        end
        
    end % End of frame interation
    
    finit = GetSecs;
    
    % -- Stop EyeTracker
    if S.EYETRACKER
        eyeTrackerStop( 0 );
    end
    
    % -- Close window
    Screen('CloseAll');
    ShowCursor;
    commandwindow;
    
    % -- Export Log
    OutputLoc.Subject = S.SUBJECT;
    OutputLoc.Start = init;
    OutputLoc.End = finit;
    if S.TRIGGER
        OutputLoc.TriggerTime = timeStamp;
    end
    
    output_filename = [S.SUBJECT '_Localiser_' datestr(now,'HHMM_ddmmmmyyyy')];
    save(fullfile(S.output_path,output_filename),'OutputLoc')
    
    disp('[runLocalizer] Done.')
    
catch ME
    
    % -- Stop EyeTracker
    if S.EYETRACKER
        eyeTrackerStop( 1 );
    end
    
    % -- Close window
    Screen('CloseAll');
    ShowCursor;
    commandwindow;
    
    % -- Deal with it
    switch ME.identifier
        case 'user:escape'
            disp('[runLocalizer] Aborted by escape key.')
        otherwise
            rethrow(ME);
            % psychrethrow(psychlasterror);
    end
    
end % End try/catch

end % End function
