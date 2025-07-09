function PlotArrays(xyz)
    % Plot arrays of any types
    % xyz = cell list of rod coordinates

    clf; hold on; axis equal; grid on;
    xlabel('X'); ylabel('Y'); zlabel('Z');

    % Iterate through all lines and plot
    for i = 1:length(xyz)

        pts = xyz{i}; 
        plot3(pts(:,1), pts(:,2), pts(:,3), 'bo');
        
        % Initialize node and line counters
        nodeCounter = 1;

        % Label each node with its number
        for j = 1:size(pts, 1)
            text(pts(j, 1), pts(j, 2), pts(j, 3), sprintf('%d', nodeCounter), 'Color', 'k', 'FontSize', 6);
            nodeCounter = nodeCounter + 1;
        end

        % Label the line at the beginning
        text(pts(1, 1), pts(1, 2), pts(1, 3)+1, sprintf('Line %d', i), 'Color', 'r', 'FontSize', 12);
    end
    view([-45 45]);
end