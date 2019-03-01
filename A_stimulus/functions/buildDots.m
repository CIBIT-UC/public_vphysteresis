function [ D ] = buildDots( D , T )
%BUILDDOTS Initialise dots-related parameters and fill struct D.
% Usage: [ D ] = buildDots( D , T )
%
% Inputs:
%   : D - struct with dots-related parameters
%   : T - struct with textures (only used to read height of the stimulus)
%
% Output:
%   : D - struct with dots-related parameters (filled)
%

%Point
% D.myPointLife=5;
% D.myPointLifeJump=5;

D.dotsColor = [20 20 20];

D.n_dots_plaid = 2750;

D.dots_veloc_vert=5;
D.dots_veloc_horiz=3;

D.dots_size45=4;
D.plaid_border45=0.5;

D.dots_xy45=rand(D.n_dots_plaid,3)*(T.height-1);
% D.dots_xy45(:,3)=round(rand(D.n_dots_plaid,1)*(D.myPointLife-1)); 
D.dots_xy45(:,3)=ones(length(D.n_dots_plaid),1);
D.dots_xy45=round(D.dots_xy45+1);
D.dots_xy45_perm=randperm(D.n_dots_plaid);
% D.dots_xy45_perm=1:D.n_dots_plaid;

% dots_matrix = zeros(T.height,T.height);
% for i = D.dots_size45:D.dots_size45*4:T.height
%     dots_matrix(i,D.dots_size45:D.dots_size45*4:T.height) = 1;
% end
% [idx,idy]=ind2sub([T.height,T.height],find(dots_matrix==1));
% D.dots_xy45 = zeros(length(idx),3);
% D.dots_xy45(:,1) = idx;
% D.dots_xy45(:,2) = idy;
% D.dots_xy45(:,3) = ones(length(idx),1);
% D.dots_xy45_perm = randperm(length(idx));
% 
% D.n_dots_plaid=length(idx);

D.dots_size_45=4;
D.plaid_border_45=0.5;

D.dots_xy_45=rand(D.n_dots_plaid,3)*(T.height-1);
% D.dots_xy_45(:,3)=round(rand(D.n_dots_plaid,1)*(D.myPointLife-1));
D.dots_xy_45(:,3)=ones(length(D.n_dots_plaid),1);

D.dots_xy_45=round(D.dots_xy_45+1);
D.dots_xy_45_perm=randperm(D.n_dots_plaid);
% D.dots_xy_45_perm=1:D.n_dots_plaid;
% 
% dots_matrix = zeros(T.height,T.height);
% for i =  D.dots_size45:D.dots_size45*4:T.height
%     dots_matrix(i, D.dots_size45:D.dots_size45*4:T.height) = 1;
% end
% [idx,idy]=ind2sub([T.height,T.height],find(dots_matrix==1));
% D.dots_xy_45 = zeros(length(idx),3);
% D.dots_xy_45(:,1) = idx;
% D.dots_xy_45(:,2) = idy;
% D.dots_xy_45(:,3) = ones(length(idx),1);
% D.dots_xy_45_perm = randperm(length(idx));

disp('[buildDots] Done.')

end % End function