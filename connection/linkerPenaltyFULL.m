function [F, K] = linkerPenaltyFULL(Rods, conn, sys)
    % Returns the penalty force vector and penalty stiffness matrix for linkers

    % Initialize zero vectors and matrices
    F = zeros(sys.ndof, 1);
    K = zeros(sys.ndof);

    % Number of connection
    nconn = size(conn, 1);
    
    for i = 1:nconn % i represents a single linker
    for j = 1:2 % j represents the two edges

        % Current connection
        c = conn(i, j);

        % First node pair (positional), M-m
        [F, K] = processNodePair(F, K, c.R, c.M, c.r, c.m, sys.ndofpr, Rods, c.p);
        
        % Second node pair (positional), N-n
        [F, K] = processNodePair(F, K, c.R, c.N, c.r, c.n, sys.ndofpr, Rods, c.p);

        % Edge pair (angular), E-e
        [F, K] = processEdgePair(F, K, c.R, c.E, c.r, c.e, sys.ndofpr, Rods, c.p);

    end
    end

    % Check if the matrix size remains the same while adding penalty
    assert(isequal(size(K), [1 1]*sys.ndof), 'Stiffness matrix size changed while adding penalty');
end

function [F, K] = processNodePair(F, K, R, N, r, n, ndofspr, Rods, p)
    % Binds positional dofs
    % N-th node from R-th regular rod with n-th node from r-th linker rod 

    % Stiffness terms
    pmat = diag([p p p]);

    % Positional dofs
    dofs = [1 2 3];

    % Rows (and cols) to be updated
    r1 = node2sysdof(R, N, 1, ndofspr);
    r2 = r1 + 2;
    r3 = node2sysdof(r, n, 1, ndofspr);
    r4 = r3 + 2;

    % Instrt penalty terms into stiffness matrix
    K(r1:r2, r1:r2) = K(r1:r2, r1:r2) + pmat; % Top-left
    K(r3:r4, r3:r4) = K(r3:r4, r3:r4) + pmat; % Bottom-right
    K(r1:r2, r3:r4) = K(r1:r2, r3:r4) - pmat; % Top-right
    K(r3:r4, r1:r2) = K(r3:r4, r1:r2) - pmat; % Bottom-left

    % Compute internal forces
    RNq = Rods(R).q(node2dof(N, dofs)); % Position of node N from rod R
    rnq = Rods(r).q(node2dof(n, dofs)); % Position of node n from rod r
    fvec = p * (RNq - rnq); % 3x1 vector

    % Update Force terms
    F(r1:r2) = F(r1:r2) + fvec;
    F(r3:r4) = F(r3:r4) - fvec;
    
end

function [F, K] = processEdgePair(F, K, R, N, r, n, ndofspr, Rods, p)
    % Binds torsional dofs
    % N-th edge from R-th regular rod with n-th edge from r-th linker rod 

    % Torsional dof
    dof = 4;

    r1 = node2sysdof(R, N, dof, ndofspr);
    r2 = node2sysdof(r, n, dof, ndofspr);
    
    % Matrix terms
    K(r1, r1) = K(r1, r1) + p; % Top-left
    K(r2, r2) = K(r2, r2) + p; % Bottom-right
    K(r1, r2) = K(r1, r2) - p; % Top-right
    K(r2, r1) = K(r2, r1) - p; % Bottom-left

    % Compute internal forces
    RNq = Rods(R).q(node2dof(N, dof)); % Twist of edge N from rod R
    rnq = Rods(r).q(node2dof(n, dof)); % Twist of edge n from rod r
    f = p * (RNq - rnq); % scalar

    % Force terms
    F(r1) = F(r1) + f;
    F(r2) = F(r2) - f;
end
