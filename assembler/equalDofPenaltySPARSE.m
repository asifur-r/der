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
    kp = kp .* logical(tvals);

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


% function [Fed, Ked] = equalDofPenaltySPARSE(ana, sol, sys)
%     % Returns the equal dof penalty force vector and sparse stiffness matrix

%     % Time and time series
%     t = sol.t;
%     timeSeries = ana.timeSeries;

%     % Number of equal dofs
%     eqdN = length(ana.equalDof);

%     % Cell containting the parameters
%     mdofs = cell(eqdN, 1);
%     sdofs = cell(eqdN, 1);
%     kp = cell(eqdN, 1);
%     tsTags = cell(eqdN, 1);

%     % Extract the equal dofs
%     for i = 1:eqdN
%         eqd = ana.equalDof{i};
%         mdofs{i} = node2sysdof(eqd.masterRod, eqd.masterNode, eqd.dofs, sys.ndofpr);
%         sdofs{i} = node2sysdof(eqd.slaveRod, eqd.slaveNode, eqd.dofs, sys.ndofpr);
%         kp{i}    = ones(1, length(eqd.dofs)) * eqd.penalty;
%         tsTags{i}= ones(1, length(eqd.dofs)) * eqd.timeSeriesTag;
%     end

%     % Concatenate results into a single vector
%     mdofs = [mdofs{:}];
%     sdofs = [sdofs{:}];
%     kp    = [kp{:}];
%     tsTags= [tsTags{:}];

%     % Compute time series values
%     tvals = zeros(1, length(tsTags));
%     for i = 1:length(tsTags); tvals(i) = timeSeries(tsTags(i)).GetValue(t); end

%     % Adjust kp
%     kp = kp .* logical(tvals);
    
%     % Sparse processing

%     % Number of pairs
%     npairs = length(mdofs);

%     % Ensure mdofs and sdofs are the same length
%     assert(length(mdofs) == length(sdofs), 'Master slave dofs must have the same length.');

%     % Initialize sparse matrix components
%     sizeK = 4 * npairs; % Upper bound
%     IK = zeros(sizeK, 1); % Row indices for stiffness
%     JK = zeros(sizeK, 1); % Column indices for stiffness
%     VK = zeros(sizeK, 1); % Values for stiffness

%     % Initialize sparse force vector components
%     sizeF = 2 * npairs;
%     IF = zeros(sizeF, 1);
%     VF = zeros(sizeF, 1);

%     % Process each pair
%     for i = 1:npairs

%         % Get current master-slave pair
%         m = mdofs(i);
%         s = sdofs(i);
%         k = kp(i);

%         % Compute internal force contribution
%         f = k * (sol.u(m) - sol.u(s));

%         % Store force vector entries
%         ids = 2*(i-1) + (1:2);
%         IF(ids) = [m; s];
%         VF(ids) = [f; -f];

%         % Store stiffness matrix entries
%         ids = 4*(i-1) + (1:4);
%         IK(ids) = [m s m s]';
%         JK(ids) = [m s s m]';
%         VK(ids) = [k k -k -k]';
%     end

%     % Construct sparse matrices
%     Ked = sparse(IK, JK, VK, sys.ndof, sys.ndof);
%     Fed = sparse(IF, ones(size(IF)), VF, sys.ndof, 1);

% end