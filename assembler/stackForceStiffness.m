function [Fi, Kt] = stackForceStiffness(Rods)
    % Returns system internal Fi and Kt just by stacking

    % Store force vectors and stiffness matrices of all rods
    % [fs, ks] = arrayfun(@(r) allForceStiffness(r), Rods, 'UniformOutput', false);

    fs = cell(1, length(Rods));
    ks = cell(1, length(Rods));

    for r = 1:length(Rods); [fs{r}, ks{r}] = allForceStiffness(Rods(r)); end

    % Vertically stack f vectors
    Fi = vertcat(fs{:});

    % Diagonally stack k matrices using blkdiag
    Kt = blkdiag(ks{:});

end