function [F, K] = linkerPenaltySPARSE(Rods, conn, sys)
    % Returns the penalty force vector and sparse stiffness matrix for linkers

    % Extract the state vectors from each rod and make a cell array
    qs = arrayfun(@(r) r.q, Rods, 'UniformOutput', false);

    % Number of connections
    nconn = size(conn, 1);

    % Number of dofs
    ndof = sys.ndof;

    % Preallocate space for sparse triplets
    % Each processNodePair call inserts 36 items (Four 3x3 block)
    % Each processEdgePair call inserts 4 items (One 2x2 block)
    % lengthK = nconn (outer for) x 2 (inner for) x (36 + 36 + 4) = 152 x nconn

    lengthK = 152 * nconn;
    countK = 0;
    IK = zeros(lengthK, 1);
    JK = zeros(lengthK, 1);
    VK = zeros(lengthK, 1);
    
    % Preallocate space for force vector
    % lengthF = nconn (outer for) x 2 (inner for) x (6 + 6 + 2) = 28 x nconn
    lengthF = 28 * nconn;
    countF = 0;
    IF = zeros(lengthF, 1); % Upper bound estimate for force vector
    VF = zeros(lengthF, 1);
    
    for i = 1:nconn % Loop over linkers
    for j = 1:2 % Each linker connects two elements

        % Current connection
        c = conn(i, j);
        
        % Process positional node pairs (M-m and N-n)
        [IF, VF, countF, IK, JK, VK, countK] = processNodePair(IF, VF, countF, IK, JK, VK, countK, c.R, c.M, c.r, c.m, qs{c.R}, qs{c.r}, c.p, sys.ndofpr);
        [IF, VF, countF, IK, JK, VK, countK] = processNodePair(IF, VF, countF, IK, JK, VK, countK, c.R, c.N, c.r, c.n, qs{c.R}, qs{c.r}, c.p, sys.ndofpr);
        
        % Process angular edge pair (E-e)
        [IF, VF, countF, IK, JK, VK, countK] = processEdgePair(IF, VF, countF, IK, JK, VK, countK, c.R, c.E, c.r, c.e, qs{c.R}, qs{c.r}, c.p, sys.ndofpr);
        
    end
    end

    % Construct sparse stiffness matrix
    K = sparse(IK, JK, VK, ndof, ndof);

    % Construct sparse force vector
    F = sparse(IF, ones(length(IF), 1), VF, ndof, 1);

    % Ensure matrix size consistency
    assert(isequal(size(K), [ndof, ndof]), 'Stiffness matrix size changed while adding penalty');
end

function [IF, VF, countF, IK, JK, VK, countK] = processNodePair(IF, VF, countF, IK, JK, VK, countK, R, N, r, n, Rq, rq, p, ndofspr)
    % Process positional constraints for node pairs

    % Stiffness penalty terms
    pmat = diag([p p p]);

    % DOF indices
    dofs = [1 2 3];

    % Compute system DOF indices
    r1 = node2sysdof(R, N, 1, ndofspr);
    r2 = r1 + 2;
    r3 = node2sysdof(r, n, 1, ndofspr);
    r4 = r3 + 2;
    
    % Insert penalty terms into sparse storage
    [IK, JK, VK, countK] = addSparseBlock(IK, JK, VK, countK, r1:r2, r1:r2,  pmat); % Top-left
    [IK, JK, VK, countK] = addSparseBlock(IK, JK, VK, countK, r3:r4, r3:r4,  pmat); % Bottom-right
    [IK, JK, VK, countK] = addSparseBlock(IK, JK, VK, countK, r1:r2, r3:r4, -pmat); % Top-right
    [IK, JK, VK, countK] = addSparseBlock(IK, JK, VK, countK, r3:r4, r1:r2, -pmat); % Bottom-left
    
    % Compute internal forces
    RNq = Rq(node2dof(N, dofs));
    rnq = rq(node2dof(n, dofs));
    fvec = p * (RNq - rnq);

    % Store force vector entries
    ids = countF + (1:6);
    IF(ids) = [r1:r2, r3:r4]';
    VF(ids) = [fvec; -fvec];
    countF = countF + 6;
end

function [IF, VF, countF, IK, JK, VK, countK] = processEdgePair(IF, VF, countF, IK, JK, VK, countK, R, N, r, n, Rq, rq, p, ndofspr)
    % Process torsional constraints for edge pairs

    % Torsional DOF
    dof = 4;

    % Compute system DOF indices
    r1 = node2sysdof(R, N, dof, ndofspr);
    r2 = node2sysdof(r, n, dof, ndofspr);
    
    % Insert penalty terms into sparse storage
    % Diagonal terms are positive, cross diagonals are negative
    ids = countK + (1:4);
    IK(ids) = [r1 r2 r1 r2]';
    JK(ids) = [r1 r2 r2 r1]';
    VK(ids) = [p  p -p -p]';
    countK = countK + 4;
    
    % Compute internal forces
    RNq = Rq(node2dof(N, dof));
    rnq = rq(node2dof(n, dof));
    f = p * (RNq - rnq);

    % Store force vector entries
    ids = countF + (1:2);
    IF(ids) = [r1 r2]';
    VF(ids) = [f -f]';
    countF = countF + 2;

end