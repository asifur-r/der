function rod = Displacement(rod, nodesList, dofsList, tagsList)

    rod = assignLoadResDisp('prdisp', rod, nodesList, dofsList, tagsList);

    % % Assigns prescribed displacements to rod struct

    % % Check dimensions
    % assert(length(nodesList) == length(dofsList) && length(dofsList) == length(presDispsList), 'Lists must have the same length');

    % % Row ids where the disp should go
    % ids = node2dof(nodesList, dofsList);

    % % Check for out of bounds index
    % assert(max(ids) <= n2ndof(rod.n), "Out of bound indices occured while assigning loads")

    % % Assign the prescribed displacements
    % rod.prdisp(ids) = presDispsList;

end