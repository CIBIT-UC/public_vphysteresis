function normalized = normalize_var(array, x, y)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Normalize to [0, 1]:
m = min(array);
range = max(array) - m;
array = (array - m) / range;

% Then scale to [x,y]:
range2 = y - x;
normalized = (array*range2) + x;


end

