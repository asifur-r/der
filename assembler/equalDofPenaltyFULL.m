function [Fed, Ked] = equalDofPenaltyFULL(ana, sol, sys)
    % Returns the equal dof penalty force vector and stiffness matrix

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
    assert(length(mdofs) == length(sdofs), 'Master slave dofs must have the same length.')
    
    % Create the equal dof penalty matrix and force vector
    Ked = zeros(sys.ndof);
    Fed = zeros(sys.ndof, 1);

    % Process each pair
    for i = 1:npairs

        % Get current master slave pair
        m = mdofs(i);
        s = sdofs(i);
        k = kp(i);

        % Apply penalty values
        Ked(m, m) = Ked(m, m) + k;
        Ked(s, s) = Ked(s, s) + k;
        Ked(m, s) = Ked(m, s) - k;
        Ked(s, m) = Ked(s, m) - k;

        % Compute internal forces
        % f = k * (sol.u(m) - sol.u(s)); % No prestress
        f = k * (sol.u(m) - sol.u(s) + sol.q(m) - sol.q(s)); % For prestress

        % Insert force terms
        Fed(m) = Fed(m) + f;
        Fed(s) = Fed(s) - f;

    end

end
