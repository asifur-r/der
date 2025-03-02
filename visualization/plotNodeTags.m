function plotNodeTags(q)

    pts = extractPoints(q);
    
    % Local node tags
    of = 0.00;
    for i=1:size(pts,1)  
        text(pts(i,1) + of, pts(i,2) + of, pts(i,3), num2str(i), 'fontsize', 7)
    end
    
end