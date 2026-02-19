function fastPlot(S, t)
    % Plots rods as cloud of points at time step t
    
    % Extract all the qs for the target time step t
    Qs = arrayfun(@(r) S.Qs{r}(:, t), 1:length(S.Qs), 'UniformOutput', false);

    % Extract the coordinates xyz
    % Pts = arrayfun(@(r) extractPoints(Qs{r}), 1:length(S.Qs), 'UniformOutput', false);

    % Insert nans to break lines
    Pts = arrayfun(@(r) [extractPoints(Qs{r}); NaN NaN NaN], 1:length(S.Qs), 'UniformOutput', false);

    % Flatten the cell array
    Pts = vertcat(Pts{:});

    % Plot
    % plot3(Pts(:,1), Pts(:,2), Pts(:,3), 'ob')
    plot3(Pts(:,1), Pts(:,2), Pts(:,3), '-k')
    axis equal
    view([0 90])

end