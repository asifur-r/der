function plotRefAndDefGeom(qi, qf, r)

    % r = rod tag
    % qi = initial state vector
    % qf = final state vector

    pti = extractPoints(qi);
    ptf = extractPoints(qf);
    markersize = 30;

    if size(pti, 1) ~= 3 % Assumes as Regular rod
        
        x = [pti(:,1)]; y = [pti(:,2)]; z = [pti(:,3)];
        % plot3(x, y, z, '-ok', 'MarkerSize', markersize);
        scatter3(x, y, z, markersize, 'k')
        
        hold on
        
        x = [ptf(:,1)]; y = [ptf(:,2)]; z = [ptf(:,3)];
        % plot3(x, y, z, '-ob', 'MarkerSize', markersize);
        scatter3(x, y, z, markersize, 'b')
        
    else % Linker rod

        % Close the triangle by repeating the first point at the end and plot
        % fill3([pti(:,1); pti(1,1)], [pti(:,2); pti(1,2)], [pti(:,3); pti(1,3)], 'black')%, 'FaceAlpha', 0.5);
        % fill3([ptf(:,1); ptf(1,1)], [ptf(:,2); ptf(1,2)], [ptf(:,3); ptf(1,3)], 'red')%, 'FaceAlpha', 0.5);

    end

    axis equal
    view([0 0]) % XZ view

    % plotRodTags(qi, r);
    % plotNodeTags(qi);

    % colors = {'r', 'b', 'g', 'm', 'y'};
    % color = colors{r};
    
end