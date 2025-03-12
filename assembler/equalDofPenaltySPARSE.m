function [Fed, Ked] = equalDofPenaltySPARSE(ana, sol, sys)
    % Returns the equal dof penalty force vector and sparse stiffness matrix

    % Create master dofs and slave dofs list
    mdofs = cellfun(@(c) node2sysdof(c.masterRod, c.masterNode, c.dofs, sys.ndofpr), ana.equalDof, 'UniformOutput', false);
    sdofs = cellfun(@(c) node2sysdof(c.slaveRod, c.slaveNode, c.dofs, sys.ndofpr), ana.equalDof, 'UniformOutput', false);
    kp    = cellfun(@(c) ones(1, length(c.dofs)) * c.penalty, ana.equalDof, 'UniformOutput', false);

    % Concatenate results into a single vector
    mdofs = [mdofs{:}];
    sdofs = [sdofs{:}];
    kp    = [kp{:}];

    % Number of pairs
    npairs = length(mdofs);

    % Ensure mdofs and sdofs are the same length
    assert(length(mdofs) == length(sdofs), 'Master slave dofs must have the same length.');

    % Initialize sparse matrix components
    sizeK = 4 * npairs; % Upper bound
    IK = zeros(sizeK, 1); % Row indices for stiffness
    JK = zeros(sizeK, 1); % Column indices for stiffness
    VK = zeros(sizeK, 1); % Values for stiffness

    % Initialize sparse force vector components
    sizeF = 2 * npairs;
    IF = zeros(sizeF, 1);
    VF = zeros(sizeF, 1);

    % Process each pair
    for i = 1:npairs

        % Get current master-slave pair
        m = mdofs(i);
        s = sdofs(i);
        k = kp(i);

        % Compute internal force contribution
        f = k * (sol.u(m) - sol.u(s));

        % Store force vector entries
        ids = 2*(i-1) + (1:2);
        IF(ids) = [m; s];
        VF(ids) = [f; -f];

        % Store stiffness matrix entries
        ids = 4*(i-1) + (1:4);
        IK(ids) = [m s m s]';
        JK(ids) = [m s s m]';
        VK(ids) = [k k -k -k]';
    end

    % Construct sparse matrices
    Ked = sparse(IK, JK, VK, sys.ndof, sys.ndof);
    Fed = sparse(IF, ones(size(IF)), VF, sys.ndof, 1);

end
