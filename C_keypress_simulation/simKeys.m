function [P_coh,W_noisy,Calib] = simKeys(X,direction,main_effect,d,init_P_coh,max_w,max_w_ope,transition,opposite_effect,ope_sustain,noise_power)
%simKeys Keypress Simulation Model
%   Detailed explanation goes here

%% Initialise stuff
timestep = 1.5; % equals the TR
time_vector = 0:timestep:30;

thresh = 0.02; % sigmoid threshold for saturation
    
P_coh = zeros(size(time_vector));
W = zeros(size(time_vector));
W_noisy = zeros(size(time_vector));
Calib = zeros(size(time_vector));

%% Iterate on time
for nn = 1:length(time_vector)
    
    if time_vector(nn) == time_vector(1) % First data point
        W(nn) = 0;
        W_noisy(nn) = 0;
        P_coh(nn) = init_P_coh;
        Calib(nn) = init_P_coh;
    else % Other
        [W(nn),W_noisy(nn)] = weightFunction(direction,main_effect,transition,max_w,max_w_ope,opposite_effect,nn,ope_sustain,noise_power,P_coh(nn-1));
        
        % Calculate Calib
        Calib(nn) = 1 / (1 + exp(-30*(X(nn)-d)));

        % Calculate P_coh
        P_coh(nn) = 1 / (1 + exp(-30*(X(nn)-(d+W_noisy(nn)))));
    end
    
    % Saturation effect of the sigmoid - is this necessary?
    if P_coh(nn) > 1
        P_coh(nn) = 1;
    elseif P_coh(nn) < 0
        P_coh(nn) = 0;
    end
    
    if Calib(nn) > 1
        Calib(nn) = 1;
    elseif Calib(nn) < 0
        Calib(nn) = 0;
    end
    
end

end
