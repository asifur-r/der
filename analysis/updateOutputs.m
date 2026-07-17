function updateOutputs(Rods, ana, sol, visual, rec, monitor)

    % Show live plot
    if ~isempty(visual); livePlot(Rods, sol, visual); end

    % Write in recorder
    if ~isempty(rec); recorder(rec, Rods, ana, sol); end

    % Print monitor variables for each step
    if ~isempty(monitor) && ~isempty(monitor.step); eval(monitor.step); end

end