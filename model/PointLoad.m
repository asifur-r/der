function rod = PointLoad(rod, nodesList, dofsList, loadsList, tagsList)
    
    rod = assignLoadResDisp('fext', rod, nodesList, dofsList, loadsList, tagsList);

    % % Check dimensions
    % assert(length(nodesList) == length(dofsList) && length(dofsList) == length(loadsList), 'Lists must have the same length');

    % % Row ids where the loads should go
    % ids = node2dof(nodesList, dofsList);

    % % Check for out of bounds index
    % assert(max(ids) <= n2ndof(rod.n), "Out of bound indices occured while assigning loads")

    % % Assign the loads
    % rod.fext(ids) = loadsList;

end