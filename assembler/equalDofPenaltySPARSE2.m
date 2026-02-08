function [Fed, Ked] = equalDofPenaltySPARSE2(ana, sol, sys)
    % Returns the equal dof penalty force vector and sparse stiffness matrix

    eqDofPairs = ana.equalDof.pairs;

    % Create master dofs and slave dofs list
    mdofs = cellfun(@(c) node2sysdof(c.masterRod, c.masterNode, c.dofs, sys.ndofpr), eqDofPairs, 'UniformOutput', false);
    sdofs = cellfun(@(c) node2sysdof(c.slaveRod, c.slaveNode, c.dofs, sys.ndofpr), eqDofPairs, 'UniformOutput', false);
    kp    = cellfun(@(c) ones(1, length(c.dofs)) * c.penalty, eqDofPairs, 'UniformOutput', false);

    % Concatenate results into a single vector
    mdofs = [mdofs{:}];
    sdofs = [sdofs{:}];
    kp    = [kp{:}];

    % Number of pairs
    npairs = length(mdofs);

    % Ensure mdofs and sdofs are the same length
    assert(length(mdofs) == length(sdofs), 'Master slave dofs must have the same length.');

    % Cell-based storage for stiffness
    IK = cell(npairs, 1);
    JK = cell(npairs, 1);
    VK = cell(npairs, 1);

    % Cell-based storage for force vector
    IF = cell(npairs, 1);
    VF = cell(npairs, 1);

    % Process each pair
    for i = 1:npairs

        % Get current master-slave pair
        m = mdofs(i);
        s = sdofs(i);
        k = kp(i);

        % Compute internal force contribution
        % f = k * (sol.u(m) - sol.u(s)); % No prestress
        f = k * (sol.u(m) - sol.u(s) + sol.q(m) - sol.q(s)); % For prestress

        IF{i} = [m; s];
        VF{i} = [f; -f];

        IK{i} = [m s m s]';
        JK{i} = [m s s m]';
        VK{i} = [k k -k -k]';

    end

    % Flattens the cell and get the vectors
    IF = vertcat(IF{:});
    VF = vertcat(VF{:});

    IK = vertcat(IK{:});
    JK = vertcat(JK{:});
    VK = vertcat(VK{:});

    % Construct sparse matrices
    Ked = sparse(IK, JK, VK, sys.ndof, sys.ndof);
    Fed = sparse(IF, ones(size(IF)), VF, sys.ndof, 1);
 
end