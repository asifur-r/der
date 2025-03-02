function rod = assignLoadResDisp(parameter, rod, nodesList, dofsList, valsList)
    % Takes a single rod struct and assigns either load, restraint or prescribed displacements

    % parameter = 'load', 'restraint', 'disp'
    % rod = rod struct
    % nodesList = list of nodesList
    % dofsList = list of dofsList
    % valsList = list of valsList (must be a scalar or a vector of length nodesList x dofsList)

    % Create all the pairs of nodesList and dofsList
    [A, B] = meshgrid(nodesList, dofsList); pairs = [A(:), B(:)];

    % Check if valsList has correct length
    npairs = size(pairs, 1); nvals = length(valsList);
    assert(nvals == 1 || nvals == npairs, "Incorrect length of %s values, must be 1 or %d", parameter, npairs);

    % Just store into two separate vectors
    % nodes = pairs(:, 1); dofs = pairs(:, 2);

    % Rows where the values should go (its actually the rod level dofs)
    % rowIds = arrayfun( @(n, d) node2dof(n, d), nodes, dofs);

    % This doesn't require splitting into two vectors
    rowIds = arrayfun(@(i) node2dof(pairs(i, 1), pairs(i, 2)), 1:npairs);

    % Check for out of bounds index
    assert(max(rowIds) <= n2ndof(rod.n), "Out of bound indices occured while assigning %s", parameter)

    % Everything good, now assign

    switch parameter
        case 'fext'; rod.fext(rowIds) = valsList;
        case 'res'; rod.res(rowIds) = valsList;
        case 'prdisp'; rod.prdisp(rowIds) = valsList;
            
        otherwise; error("Assignment type must be either fext, res or pdisp")
    end
    
end