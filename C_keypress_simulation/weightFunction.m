function [w,w_noisy] = weightFunction(direction,main_effect,transition,max_w,max_w_ope,opposite_effect,n,ope_sustain,noise_power,p_coh_past)
%weightFunction Keypress Simulation Model - Weight of previous history
%   Detailed explanation goes here

blockVols = 21;

global idx_decresc;

% Initialise idx_decresc with the last volume index
if n == 2
    idx_decresc = blockVols;
end

% Initialise signal to make simulink happy. If this value stays -99
% someting is very wrong
signal = -99;

% Conditional definition of idx_decresc and signal, depending of direction,
% main_effect and transition
switch direction
    case 1                       % Pattern -> Component
        if main_effect == 2        % Persistence
            signal = -1;
            if p_coh_past <= (1-transition)      % after the transition P(t) value
                if idx_decresc == blockVols  % only if not defined before
                    idx_decresc = n-1;
                end
            end
        elseif main_effect == 1    % Adaptation
            signal = 1;
            if p_coh_past <= (1-transition)      % after the transition P(t) value
                if idx_decresc == blockVols  % only if not defined before
                    idx_decresc = n-1;
                end
            end
        else                       % No effect
            signal = 0;
        end
        
    case 2                       % Component -> Pattern
        if main_effect == 2        % Persistence
            signal = 1;
            if p_coh_past >= transition      % after the transition P(t) value
                if idx_decresc == blockVols  % only if not defined before
                    idx_decresc = n-1;
                end
            end
        elseif main_effect == 1    % Adaptation
            signal = -1;
            if p_coh_past >= transition      % after the transition P(t) value
                if idx_decresc == blockVols  % only if not defined before
                    idx_decresc = n-1;
                end
            end
        else                       % No effect
            signal = 0;
        end
end

% Calculate w based on n, max_w, idx_decresc and signal
if n < 2
    w = 0;
elseif n >= 2 && n <= 6
    w = signal * ((max_w)*n/4 - max_w/2);
elseif n > 6 && n < idx_decresc
    w = signal * max_w;
elseif opposite_effect ~= 1 && n >= idx_decresc && n <= idx_decresc+4 % decrease to 0 without opposite effect
    w = signal * (-(max_w*n/4) + ((idx_decresc+4)*max_w)/4);
elseif opposite_effect == 1 && n >= idx_decresc && n <= idx_decresc+2 % decrease to 0 with opposite effect
    w = signal * (-(max_w*n/2) + ((idx_decresc+2)*max_w)/2);    
elseif opposite_effect == 1 && n > idx_decresc + 2 && n <= idx_decresc + 4 % opposite effect increase
    w = signal * (-(max_w_ope*n/2) + ((idx_decresc+2)*max_w_ope)/2);
elseif opposite_effect == 1 && n > idx_decresc + 4 && n <= idx_decresc + 4 + ope_sustain % opposite effect sustain
    w = signal * -max_w_ope;
elseif opposite_effect == 1 && n > idx_decresc + 4 + ope_sustain && n <= idx_decresc + 6 + ope_sustain % opposite effect decrease to 0
    w = signal * ((max_w_ope)*n/2 - ((idx_decresc+6+ope_sustain)*max_w_ope)/2);
else
    w = 0;
end

% Add noise
noise = [(noise_power).*rand(15,1) ; -(noise_power).*rand(15,1)];
noise = noise(randperm(length(noise)));

w_noisy = w + noise(1);

end
