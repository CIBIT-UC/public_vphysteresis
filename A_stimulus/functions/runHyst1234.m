function [ OutputRun1234 ] = runHyst1234( run_name , S , T )
%RUNRUN0 Stimulus function for run0
% Usage: [ OutputRun0 ] = runRun0( run_name , S , T )
%
% Inputs:
%   : run_name - string with run name and number
%   : S - struct containing very important info (screen, subject, colors,
%   trigger, response box, eyetracker, etc)
%   : T - struct containg the textures
%
% Outputs:
%   : OutputRun0 - struct containing time of start, end and trigger of the
%   stimulation, key presses and codes, user responses.
%

% Screen('Preference', 'SkipSyncTests', 1);

OutputRun1234 = struct(); % Output struct
D = struct(); % Dots struct

%% Clean the COMs
% Never trust what happened before...
if S.RSPBOX
    IOPort('Purge',S.response_box_handle);
end
if S.TRIGGER
    IOPort('Purge', S.syncbox_handle);
end

%% Read PRT
load(fullfile(S.input_path,['Protocols_' run_name '.mat']));

%% Search for Black condition
discardCondIdx = find(ismember(condNames, 'Discard')) ;

staticCondIdx = find(ismember(condNames, 'Static')) ;

%% Initialise key-related stuff
keysPressed = zeros(numFrames , 2);
key_codes = zeros(2,1);
KbName('UnifyKeyNames');

%% Stim

try
    % -- Open Window
    [ windowID , winRect ] = Screen('OpenWindow', S.screenNumber , S.screenBackground );
    
    % -- Rendering Options
    Screen('BlendFunction', windowID, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    % -- Flip Interval
    ifi = Screen('GetFlipInterval', windowID);
    
    % -- Select specific text font, style and size
    Screen('TextFont', windowID , 'Arial');
    Screen('TextSize', windowID , 20);
    
    % -- Center Variables
    [S.xCenter, S.yCenter] = RectCenter(winRect);
    
    % -- Build Dots
    [ D ] = buildDots( D , T );
    
    % -- Hide Cursor
    HideCursor;
    
    % -- Initialise EyeTracker
    if S.EYETRACKER
        eyeTrackerInit( windowID , S , run_name(end-1:end));
    end
    
    % -- Instruction
    text = 'Look attentively at the fixation cross. \n You must report, using buttons 1 and 2, if \n 1) Coherent (Downward) motion \n 2) Incoherent (Inward) motion \n is perceived, at all times the plaids are moving. \n\n Press any key to continue.';
    DrawFormattedText(windowID, text, 'center', 'center', S.white);
    Screen('Flip',windowID);
    KbStrokeWait;

    % -- Map Keys / Identify Key Codes
    btUnique = false;
    
    while ~btUnique
        
        % Button 1
        DrawFormattedText(windowID, 'Press Button for Coherent (Downward) Motion', 'center', 'center', S.white);
        Screen('Flip',windowID);
        if S.RSPBOX
            pr = 1;
            while pr
                key = IOPort('Read',S.response_box_handle);
                if ~isempty(key) && (length(key) == 1)
                    key_codes(1) = key;
                    pr = 0;
                end
                IOPort('Flush',S.response_box_handle);
            end
        else
            [~,code] = KbPressWait;
            key_codes(1) = find(code==1);
        end
        
        % Button 2
        DrawFormattedText(windowID, 'Press Button for Incoherent (Inward) Motion', 'center', 'center', S.white);
        Screen('Flip',windowID);
        if S.RSPBOX
            pr = 1;
            while pr
                key = IOPort('Read',S.response_box_handle);
                if ~isempty(key) && (length(key) == 1)
                    key_codes(2) = key;
                    pr = 0;
                end
                IOPort('Flush',S.response_box_handle);
            end
        else
            [~,code] = KbPressWait;
            key_codes(2) = find(code==1);
        end
        
        if length(unique(key_codes))==2
            btUnique = true;
        else
            key_codes = zeros(2,1);
        end
        
        clear code key pr
        
    end
    
    % -- Start Eyetracker
    if S.EYETRACKER
        eyeTrackerStart();
    end
    
    % -- Wait for Key Press or Trigger
    if S.TRIGGER
        DrawFormattedText(windowID, 'Waiting to start...', 'center', 'center', S.white);
        Screen('Flip',windowID);
        disp('[runHyst1234] Waiting for trigger...')
        
        [gotTrigger, timeStamp] = waitForTrigger(S.syncbox_handle,1,300); % timeOut = 5 min (300s)
        if gotTrigger
            disp('[runHyst1234] Trigger Received.')
            IOPort('Flush', S.syncbox_handle);
            IOPort('Purge', S.syncbox_handle);
        else
            disp('[runHyst1234] Trigger Not Received. Aborting!')
            return
        end
    else
        DrawFormattedText(windowID, 'Press Enter to Start', 'center', 'center', S.white);
        Screen('Flip',windowID);
        disp('[runHyst1234] Waiting to start...')
        KbPressWait;
    end
    
    % -- Start parameters
    t = 0;
    textIndexX = 1;
    textIndexY = 1;
    
    % -- Frame Iteration
    vbl = Screen('Flip', windowID);
    disp('[runHyst1234] Starting iteration...')
    
    init = GetSecs;
    
    while t < numFrames % Iteration on the frames
                
        % Make Texture
        windowtext = Screen('MakeTexture', windowID, T.Textures{textIndexY,textIndexX});
        
%         if framesCond(t+1) ~= blackCondIdx % Not Black
            
            % Draw Lines
            Screen('DrawTextures', windowID, windowtext)
            
            % Draw Dots
            [ D ] = drawDots( windowID , D , T , S , textIndexX , textIndexY );
            
            % Update Texture Index
            if all(framesCond(t+1) ~= [staticCondIdx,discardCondIdx]) % Not Static
                textIndexY = textIndexY + 1;
            end
            
            % Restrict Texture Index
            if textIndexX > T.nTextX
                textIndexX = 1;
            elseif textIndexX <= 0
                textIndexX = T.nTextX;
            end
            if textIndexY > T.nTextY
                textIndexY = 1;
            elseif textIndexY <= 0
                textIndexY = T.nTextY;
            end
            
%         end % End If Not Black
        
        % Fixation Cross
        drawFixationCross( windowID , S , 101 , 0 );
        
        % Do it
        vbl = Screen('Flip', windowID, vbl + 0.5*ifi);
        
        % -------- KEYS --------
        [keyPress,~,keyCode] = KbCheck();
        if keyPress
            if keyCode(KbName('escape')) == 1 %Quit if "Esc" is pressed
                throw(MException('user:escape','Aborted by escape key.'))
            end
        end
        
        if S.RSPBOX
            [key,~] = IOPort('Read',S.response_box_handle);
            
            if ~isempty(key) && (length(key) == 1)
                IOPort('Flush',S.response_box_handle);
                
                keysPressed(t+1,1) = key;
            end
            
            IOPort('Flush',S.response_box_handle);
        else
            if keyPress
                a = find(keyCode==1);
                if length(a) == 1
                    keysPressed(t+1,1) = a;
                end
            end
        end
        
        keysPressed(t+1,2) = GetSecs;

        % Clear Texture
        Screen('Close', windowtext);
        
        % Move dots
        [ D ] = moveDots( framesDots(t+1) , D , T , framesPercentage(t+1) );
        
        % Record frames
%         rect = round([S.xCenter-S.height/2 ; S.yCenter-S.height/2 ; S.xCenter+S.height/2 ; S.yCenter+S.height/2]);
%         frameImage=Screen('GetImage', windowID, rect, [], [], []);
%         imwrite(frameImage,[pwd '\output_frames\RunH_' num2str(t+1000) '.png'],'png');
        
        % -- Iterate frame
        t = t+1;    
        
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
    OutputRun1234.Subject = S.SUBJECT;
    OutputRun1234.Start = init;
    OutputRun1234.End = finit;
    if S.TRIGGER
        OutputRun1234.TriggerTime = timeStamp;
    end
    OutputRun1234.Keys = keysPressed;
    OutputRun1234.KeyCodes = key_codes;
    
    output_filename = [S.SUBJECT '_' run_name '_' datestr(now,'HHMM_ddmmmmyyyy')];
    save(fullfile(S.output_path,output_filename),'OutputRun1234')
    
    disp('[runHyst1234] Done.')
    
catch ME
    
    finit = GetSecs;
    
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
            OutputRun1234.Subject = S.SUBJECT;
            OutputRun1234.Start = init;
            OutputRun1234.End = finit;
            if S.TRIGGER
                OutputRun1234.TriggerTime = timeStamp;
            end
            OutputRun1234.Keys = keysPressed;
            OutputRun1234.KeyCodes = key_codes;
            
            output_filename = [S.SUBJECT '_' run_name '_' datestr(now,'HHMM_ddmmmmyyyy') '_Aborted'];
            save(fullfile(S.output_path,output_filename),'OutputRun1234')
            
            disp('[runHyst1234] Aborted by escape key.')
        otherwise
            rethrow(ME);
            % psychrethrow(psychlasterror);
    end
    
end % End try/catch

end % End function