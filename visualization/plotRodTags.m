function plotRodTags(q, r)

    pts = extractPoints(q);
    
    % Rod tag
    row = ceil(size(pts, 1) / 2);
    str = strcat("Rod ", num2str(r));
    of = 0.00;
    text(pts(row, 1) + of, pts(row, 2) + of, pts(row, 3) + of, str, 'fontsize', 7)
    
end