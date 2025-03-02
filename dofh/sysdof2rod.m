function [rodId, nodeId, localDof] = sysdof2rod(sysdof, ndofspr)
    % Returns the rod id, node id and local dof id from a system level dof

    % sysdof = system dof
    % ndofspr = number of dofs per rod

    % Cumulitive sum of the ndofspr
    cum = cumsum(ndofspr);

    % Logical vector if cumulative is greater than sysdof
    isCumGrt = cum >= sysdof;

    % Extract the rod id
    rodId = find(isCumGrt, 1);

    % Sum of dofs just before the rod
    temp = sum(ndofspr(1:rodId-1));

    % Rod level dof
    rodLevelDof = sysdof - temp;

    % Get node id
    nodeId = ceil(rodLevelDof / 4);

    % Get local dof to that node (1, 2, 3 or 4)
    localDof = rodLevelDof - 4*(nodeId-1);

end