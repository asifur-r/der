function [Fed, Ked] = equalDofPenaltySPARSE(ana, sol, sys)
    % Returns the equal dof penalty force vector and sparse stiffness matrix

    % Time
    t = sol.t;
    
    % Extract equal dofs and compute parameters
    [mdofs, sdofs, kp, tsTags] = extractEqualDofParams(ana, sys);
    assert(length(mdofs) == length(sdofs), 'Master slave dofs must have the same length.');
    
    % Compute time series values
    tvals = zeros(1, length(tsTags));
    for i = 1:length(tsTags); tvals(i) = ana.timeSeries(tsTags(i)).GetValue(t); end

    % Adjust kp for current time t
    % kp = kp .* logical(tvals);
    kp = kp .* tvals;
    
    % Sparse processing
    
    % Number of pairs
    npairs = length(mdofs);
    ndof = sys.ndof;

    % Preallocate I, J, K
    sizeK = 4 * npairs;
    IK = zeros(sizeK, 1);
    JK = zeros(sizeK, 1);
    VK = zeros(sizeK, 1);

    sizeF = 2 * npairs;
    IF = zeros(sizeF, 1);
    VF = zeros(sizeF, 1);

    for i = 1:npairs
        m = mdofs(i);
        s = sdofs(i);
        k = kp(i);
        
        % f = k * (sol.u(m) - sol.u(s)); % No prestress
        f = k * (sol.u(m) - sol.u(s) + sol.q(m) - sol.q(s)); % For prestress

        ids = 2 * (i - 1) + (1:2);
        IF(ids) = [m; s];
        VF(ids) = [f; -f];

        ids = 4 * (i - 1) + (1:4);
        IK(ids) = [m s m s]';
        JK(ids) = [m s s m]';
        VK(ids) = [k k -k -k]';
    end

    Ked = sparse(IK, JK, VK, ndof, ndof);
    Fed = sparse(IF, ones(size(IF)), VF, ndof, 1);

end

function [mdofs, sdofs, kp, tsTags] = extractEqualDofParams(ana, sys)
    % Extracts equal dof parameters.

    % Number of equal dofs
    eqdN = length(ana.equalDof.pairs);

    % Cell for equal dofs parameters
    mdofs  = cell(eqdN, 1);
    sdofs  = cell(eqdN, 1);
    kp     = cell(eqdN, 1);
    tsTags = cell(eqdN, 1);

    % Extract parameters and populate cells
    for i = 1:eqdN

        % Current equal dof struct
        eqd = ana.equalDof.pairs{i};

        % Master system dofs
        mdofs{i} = node2sysdof(eqd.masterRod, eqd.masterNode, eqd.dofs, sys.ndofpr);

        % Slave system dofs
        sdofs{i} = node2sysdof(eqd.slaveRod, eqd.slaveNode, eqd.dofs, sys.ndofpr);

        % Penalties
        kp{i} = ones(1, length(eqd.dofs)) * eqd.penalty;

        % Time series tags
        tsTags{i} = ones(1, length(eqd.dofs)) * eqd.timeSeriesTag;
    end

    % Concatenate
    mdofs = [mdofs{:}];
    sdofs = [sdofs{:}];
    kp = [kp{:}];
    tsTags = [tsTags{:}];
end


% function [Fed, Ked] = equalDofPenaltySPARSE2(ana, sol, sys)
%     % Cell based sparse implementation of equal dof

%     eqDofPairs = ana.equalDof.pairs;

%     % Create master dofs and slave dofs list
%     mdofs = cellfun(@(c) node2sysdof(c.masterRod, c.masterNode, c.dofs, sys.ndofpr), eqDofPairs, 'UniformOutput', false);
%     sdofs = cellfun(@(c) node2sysdof(c.slaveRod, c.slaveNode, c.dofs, sys.ndofpr), eqDofPairs, 'UniformOutput', false);
%     kp    = cellfun(@(c) ones(1, length(c.dofs)) * c.penalty, eqDofPairs, 'UniformOutput', false);

%     % Concatenate results into a single vector
%     mdofs = [mdofs{:}];
%     sdofs = [sdofs{:}];
%     kp    = [kp{:}];

%     % Number of pairs
%     npairs = length(mdofs);

%     % Ensure mdofs and sdofs are the same length
%     assert(length(mdofs) == length(sdofs), 'Master slave dofs must have the same length.');

%     % Cell-based storage for stiffness
%     IK = cell(npairs, 1);
%     JK = cell(npairs, 1);
%     VK = cell(npairs, 1);

%     % Cell-based storage for force vector
%     IF = cell(npairs, 1);
%     VF = cell(npairs, 1);

%     % Process each pair
%     for i = 1:npairs

%         % Get current master-slave pair
%         m = mdofs(i);
%         s = sdofs(i);
%         k = kp(i);

%         % Compute internal force contribution
%         % f = k * (sol.u(m) - sol.u(s)); % No prestress
%         f = k * (sol.u(m) - sol.u(s) + sol.q(m) - sol.q(s)); % For prestress

%         IF{i} = [m; s];
%         VF{i} = [f; -f];

%         IK{i} = [m s m s]';
%         JK{i} = [m s s m]';
%         VK{i} = [k k -k -k]';

%     end

%     % Flattens the cell and get the vectors
%     IF = vertcat(IF{:});
%     VF = vertcat(VF{:});

%     IK = vertcat(IK{:});
%     JK = vertcat(JK{:});
%     VK = vertcat(VK{:});

%     % Construct sparse matrices
%     Ked = sparse(IK, JK, VK, sys.ndof, sys.ndof);
%     Fed = sparse(IF, ones(size(IF)), VF, sys.ndof, 1);
 
% end