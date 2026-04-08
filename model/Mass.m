function rod = Mass(rod, nodesList, dofsList, valsList, tagsList)
    % Takes a single rod struct and assigns lump masses to the existing mdiag vector

    % rod = rod struct
    % nodesList = list of nodesList
    % dofsList = list of dofsList
    % valsList = list of valsList (must be a scalar or a vector of length nodesList x dofsList)
    % tagsList = timeseries tags

    % Create all the pairs of nodesList and dofsList
    [A, B] = meshgrid(nodesList, dofsList); pairs = [A(:), B(:)];

    % Check if valsList has correct length
    npairs = size(pairs, 1); nvals = length(valsList); 
    
    assert(nvals == 1 || nvals == npairs, "Incorrect length of mass, must be 1 or %d", npairs);
 
    % Rows where the values should go (its actually the rod level dofs)
    ids = arrayfun(@(i) node2dof(pairs(i, 1), pairs(i, 2)), 1:npairs);

    % Check for out of bounds index
    assert(max(ids) <= n2ndof(rod.n), "Out of bound indices occured while assigning mass")

    % Everything good, now assign
    rod.prmdiag(ids) = valsList;
    rod.prmdiagTag(ids) = tagsList;
    
end