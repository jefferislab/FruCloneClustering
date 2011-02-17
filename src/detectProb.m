function dp = detectProb(x2, x1)

    x1 = sort(x1(:));
    x2 = sort(x2(:));
    
    [b1, n1] = unique(x1);
    
    [b2, n2] = unique(x2);
    
    if ~isempty(n1) && ~isempty(n2)
    
    u = [[-inf 0 0] ; union([b1 [n1(1) ; diff(n1)]/length(x1) zeros(size(b1))], ...
        [b2 zeros(size(b2)) [n2(1) ; diff(n2)]/length(x2)],'rows')];
    
    [uu, i] = unique(u(:,1));
        
    u = cumsum(u(:,[2 3]), 1);
    u = u(i, :);
   
    dp = trapz(u(:,1), u(:,2));
    
    else
        
        dp=.5;
        
    end
    
end