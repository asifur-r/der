function mat = extractResponse(solution, variable, dofs)
    % Extracts displacements for node/s from a dofs matrix
    % For multiple nodes, the displacements are in returned in column [u1 u2 ..]
    
    % dofs = a matrix in [rodTag nodeTag dofTag] format per row
    % variale = what to extract 'disp' or 'force' (internal)

    % Get the correct variable cell array
    switch variable
        case 'disp'; response = solution.Us;
        case 'force'; response = solution.FIs;
            
        otherwise; error("Response variable can be either 'disp' or 'force'")
            
    end

    % Get the last step from the lambda vector L
    nsteps = length(solution.T);

    % Number of requested displacement
    nrequest = size(dofs, 1);

    % Matrix to store the displacements
    mat = zeros(nsteps, nrequest);

    for i = 1:nrequest

        % Get the tags of rod, node, dof
        r = dofs(i, 1); 
        n = dofs(i, 2); 
        d = dofs(i, 3);
        
        % Get which row to extract (it's the rod level dof)
        rowid = node2dof(n, d);

        % Get the desired row
        mat(:, i) = response{r}(rowid, :);

    end
    
end