function dp = detectProb_2D(x1,x2);

% x1 and x2 are Nx2 arrays
% 

dp = zeros(1,360);

for i = 1:360
    
    v = [cosd(i) sind(i)];
    
    y1 = v*x1';
    y2 = v*x2';
    
    dp(i) = detectProb(y1, y2);
    
end

