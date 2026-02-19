function [F, K] = linkerPenaltySPARSE(Rods, conn, sys)
    % Returns the penalty force vector and sparse stiffness matrix for linkers

    % Extract the state vectors from each rod and make a cell array
    qs = {Rods.q};

    % Number of connections
    nconn = size(conn, 1);

    % Number of dofs
    ndof = sys.ndof;

    % Preallocate space for sparse triplets
    lengthK = 152 * nconn; % lengthK = nconn (outer for) x 2 (inner for) x (36 + 36 + 4) = 152 x nconn
    countK = 0;
    IK = zeros(lengthK, 1);
    JK = zeros(lengthK, 1);
    VK = zeros(lengthK, 1);
    
    % Preallocate space for force vector
    lengthF = 28 * nconn; % lengthF = nconn (outer for) x 2 (inner for) x (6 + 6 + 2) = 28 x nconn
    countF = 0;
    IF = zeros(lengthF, 1); % Upper bound estimate for force vector
    VF = zeros(lengthF, 1);
    
    for i = 1:nconn % Loop over linkers
    for j = 1:2 % Each linker connects two elements

        % Current connection
        c = conn(i, j);
        
        % Process positional node pairs (M-m and N-n)
        [IF1, VF1, IK1, JK1, VK1] = processNodePair(c.R, c.M, c.r, c.m, qs{c.R}, qs{c.r}, c.p, sys.ndofpr);
        [IF2, VF2, IK2, JK2, VK2] = processNodePair(c.R, c.N, c.r, c.n, qs{c.R}, qs{c.r}, c.p, sys.ndofpr);
        
        % Process angular edge pair (E-e)
        [IF3, VF3, IK3, JK3, VK3] = processEdgePair(c.R, c.E, c.r, c.e, qs{c.R}, qs{c.r}, c.p, sys.ndofpr);

        % Insert into global vectors
        ids = countF + (1:14); % 6 + 6 + 2
        IF(ids) = [IF1; IF2; IF3];
        VF(ids) = [VF1; VF2; VF3];
        countF = countF + 14;
        
        ids = countK + (1:76); % 36 + 36 + 4
        IK(ids) = [IK1; IK2; IK3];
        JK(ids) = [JK1; JK2; JK3];
        VK(ids) = [VK1; VK2; VK3];
        countK = countK + 76;

    end
    end
    
    % Construct sparse matrices
    F = sparse(IF, ones(length(IF), 1), VF, ndof, 1);
    K = sparse(IK, JK, VK, ndof, ndof);
    
    % Ensure matrix size consistency
    assert(isequal(size(K), [ndof, ndof]), 'Stiffness matrix size changed while adding penalty');
end

function [IF, VF, IK, JK, VK] = processNodePair(R, N, r, n, Rq, rq, p, ndofspr)
    % Process positional constraints for node pairs

    % Preallocate sparse storage force vector
    IK = zeros(36, 1);
    JK = zeros(36, 1);
    VK = zeros(36, 1);
    IF = zeros(6, 1);
    VF = zeros(6, 1);

    % Stiffness penalty terms
    pmat = diag([p p p]);

    % DOF indices
    dofs = [1 2 3];

    % Compute system DOF indices
    r1 = node2sysdof(R, N, 1, ndofspr);
    r2 = r1 + 2;
    r3 = node2sysdof(r, n, 1, ndofspr);
    r4 = r3 + 2;
    
    % Generate row and col
    rows = [r1:r2, r3:r4]; cols = [r1:r2, r3:r4];

    % Generate indices using ndgrid
    % [r, c] = ndgrid(rows, cols);

    % Without using ndgrid
    r = rows(:) .* ones(1, length(cols));
    c = ones(length(rows), 1) .* cols(:)';
    
    % Combine the stiffness sub matrices (four 3x3)
    kp = [pmat -pmat; -pmat pmat];

    % Store stiffness matrix entries
    ids = 1:36;
    IK(ids) = r(:);
    JK(ids) = c(:);
    VK(ids) = kp(:);

    % Compute internal forces
    RNq = Rq(node2dof(N, dofs));
    rnq = rq(node2dof(n, dofs));
    fvec = p * (RNq - rnq);

    % Store force vector entries
    ids = 1:6;
    IF(ids) = [r1:r2, r3:r4]';
    VF(ids) = [fvec; -fvec];
end

function [IF, VF, IK, JK, VK] = processEdgePair(R, N, r, n, Rq, rq, p, ndofspr)
    % Process torsional constraints for edge pairs

    % Preallocate sparse storage force vector
    IK = zeros(4, 1);
    JK = zeros(4, 1);
    VK = zeros(4, 1);
    IF = zeros(2, 1);
    VF = zeros(2, 1);

    % Torsional DOF
    dof = 4;

    % Compute system DOF indices
    r1 = node2sysdof(R, N, dof, ndofspr);
    r2 = node2sysdof(r, n, dof, ndofspr);
    
    % Insert penalty terms into sparse storage
    % Diagonal terms are positive, cross diagonals are negative
    % ids = countK + (1:4);
    ids = 1:4;
    IK(ids) = [r1 r2 r1 r2]';
    JK(ids) = [r1 r2 r2 r1]';
    VK(ids) = [p  p -p -p]';
    % countK = countK + 4;
    
    % Compute internal forces
    RNq = Rq(node2dof(N, dof));
    rnq = rq(node2dof(n, dof));
    f = p * (RNq - rnq);

    % Store force vector entries
    % ids = countF + (1:2);
    ids = 1:2;
    IF(ids) = [r1 r2]';
    VF(ids) = [f -f]';
    % countF = countF + 2;

end