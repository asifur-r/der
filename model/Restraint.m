function rod = Restraint(rod, nodesList, dofsList, tagsList)

    % Allow only 1 or 0 for restraint assignment, treating any non-zero values as 1
    % valsList = double(valsList~=0);

    % Need to check for constant or rect time series for support

    rod = assignLoadResDisp('res', rod, nodesList, dofsList, tagsList);

    % % Make a cell array of the blocked dofs grouped by nodes
    % ids = arrayfun(@(n) node2dof(n, dofsList), nodesList, 'UniformOutput', false);

    % % Makes a vector by flattening the cells
    % ids = horzcat(ids{:});

    % % Check for out of bounds index
    % assert(max(ids) <= n2ndof(rod.n), "Out of bound indices occured while assigning restraint")

    % % Assign support to the ids
    % rod.res(ids) = 1;

end