function ndof = nele2ndof(nele)
    % Returns the number of dofs in a rod of nele elements
    % number of nodes = nele + 1

    % Number of nodes
    n = nele + 1;

    % Number of dofs
    ndof = 4*n - 1;
    
end