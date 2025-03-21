function [F, K] = linkerPenaltySPARSE2(Rods, conn, sys)
    % Returns the penalty force vector and sparse stiffness matrix for linkers using structured cell storage.

    % Extract state vectors from each rod
    qs = arrayfun(@(r) r.q, Rods, 'UniformOutput', false);

    % Number of connections
    nconn = size(conn, 1);

    % Number of DOFs
    ndof = sys.ndof;

    % Preallocate cell arrays (each row corresponds to a connection)
    sz = nconn*6; % Cell array length
    IK = cell(sz, 1);
    JK = cell(sz, 1);
    VK = cell(sz, 1);
    
    IF = cell(sz, 1);
    VF = cell(sz, 1);

    % Index for stroing into the cell arrays
    k = 1;

    % Assemble force and stiffness
    for i = 1:nconn % Loop over linkers
        for j = 1:2 % Each linker connects two elements

            % Current connection
            c = conn(i, j);
            
            % Process positional node pairs (M-m and N-n)
            [IF{k}, VF{k}, IK{k}, JK{k}, VK{k}] = processNodePair(c.R, c.M, c.r, c.m, qs{c.R}, qs{c.r}, c.p, sys.ndofpr);
            k=k+1;

            [IF{k}, VF{k}, IK{k}, JK{k}, VK{k}] = processNodePair(c.R, c.N, c.r, c.n, qs{c.R}, qs{c.r}, c.p, sys.ndofpr);
            k=k+1;

            % Process angular edge pair (E-e)
            [IF{k}, VF{k}, IK{k}, JK{k}, VK{k}] = processEdgePair(c.R, c.E, c.r, c.e, qs{c.R}, qs{c.r}, c.p, sys.ndofpr);
            k=k+1;

        end
    end

    % Concatenate all stored indices and values
    IF = vertcat(IF{:});
    VF = vertcat(VF{:});
    
    IK = vertcat(IK{:});
    JK = vertcat(JK{:});
    VK = vertcat(VK{:});

    F = sparse(IF, ones(length(IF), 1), VF, ndof, 1);
    K = sparse(IK, JK, VK, ndof, ndof);

    % Ensure matrix size consistency
    assert(isequal(size(K), [ndof, ndof]), 'Stiffness matrix size changed while adding penalty');
end


function [IF, VF, IK, JK, VK] = processNodePair(R, N, r, n, Rq, rq, kp, ndofspr)
    % Process positional constraints for node pairs using cell storage.

    % Stiffness penalty terms
    pmat = diag([kp kp kp]);

    % DOF indices
    dofs = [1 2 3];

    % Compute system DOF indices
    r1 = node2sysdof(R, N, 1, ndofspr);
    r2 = r1 + 2;
    r3 = node2sysdof(r, n, 1, ndofspr);
    r4 = r3 + 2;
    
    p = r1:r2;
    q = r3:r4;

    % Store stiffness matrix entries
    [IK, JK] = getSparseIndices(p,q);
    VK = [pmat(:); pmat(:); -pmat(:); -pmat(:)];

    % Compute internal forces
    RNq = Rq(node2dof(N, dofs));
    rnq = rq(node2dof(n, dofs));
    fvec = kp * (RNq - rnq);

    % Store force vector entries
    IF = [p, q]';
    VF = [fvec; -fvec];
    
end

function [i, j] = getSparseIndices(p, q)
    % Generates i, j indices for a sparse block.

    % Ensure p and q are column vectors
    p = p(:); q = q(:);

    % Anonymous function generating the indices
    getIds = @(r, c) deal(repelem(r, length(c)), repmat(c, length(r), 1));
 
    % Create cells for the indices
    i = cell(4, 1);
    j = cell(4, 1);

    % Combinations of p and q in a cell array
    com = {[p, p], [q, q], [p, q], [q, p]};
    
    % Get the ids for each combination
    for k = 1:4; [i{k}, j{k}] = getIds(com{k}(:, 1), com{k}(:, 2)); end
    
    % Flatten the cells
    i = vertcat(i{:});
    j = vertcat(j{:});

end

function [IF, VF, IK, JK, VK] = processEdgePair(R, N, r, n, Rq, rq, kp, ndofspr)
    % Process torsional constraints for edge pairs using cell storage.

    % Torsional DOF
    dof = 4;

    % Compute system DOF indices
    r1 = node2sysdof(R, N, dof, ndofspr);
    r2 = node2sysdof(r, n, dof, ndofspr);

    % Store stiffness matrix entries
    IK = [r1 r2 r1 r2]';
    JK = [r1 r2 r2 r1]';
    VK = [kp kp -kp -kp]';

    % Compute internal forces
    RNq = Rq(node2dof(N, dof));
    rnq = rq(node2dof(n, dof));
    f = kp * (RNq - rnq);

    % Store force vector entries
    IF = [r1 r2]';
    VF = [f -f]';
 
end