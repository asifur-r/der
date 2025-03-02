function [F, K] = linkerPenaltySPARSE(Rods, conn, sys)
    % Returns the penalty force vector and sparse stiffness matrix for linkers

    % Initialize force vector
    F = zeros(sys.ndof, 1);

    % Number of connections
    nconn = size(conn, 1);

    % Preallocate space for sparse triplets (upper bound estimate)
    max_entries = 200 * nconn;  % Conservative estimate
    I = zeros(max_entries, 1);
    J = zeros(max_entries, 1);
    V = zeros(max_entries, 1);
    count = 0;

    for i = 1:nconn % Loop over linkers
        for j = 1:2 % Each linker connects two elements

            % Current connection
            c = conn(i, j);

            % Process positional node pairs (M-m and N-n)
            [F, I, J, V, count] = processNodePair(F, I, J, V, count, c.R, c.M, c.r, c.m, sys.ndofpr, Rods, c.p);
            [F, I, J, V, count] = processNodePair(F, I, J, V, count, c.R, c.N, c.r, c.n, sys.ndofpr, Rods, c.p);

            % Process angular edge pair (E-e)
            [F, I, J, V, count] = processEdgePair(F, I, J, V, count, c.R, c.E, c.r, c.e, sys.ndofpr, Rods, c.p);
        end
    end

    % Construct sparse stiffness matrix
    K = sparse(I(1:count), J(1:count), V(1:count), sys.ndof, sys.ndof);

    %[sys.ndof count max_entries]

    % Ensure matrix size consistency
    assert(isequal(size(K), [sys.ndof, sys.ndof]), 'Stiffness matrix size changed while adding penalty');
end

function [F, I, J, V, count] = processNodePair(F, I, J, V, count, R, N, r, n, ndofspr, Rods, p)
    % Process positional constraints for node pairs
    
    % Stiffness terms
    pmat = diag([p p p]);

    % DOF indices
    dofs = [1 2 3];

    % Compute system DOF indices
    r1 = node2sysdof(R, N, 1, ndofspr);
    r2 = r1 + 2;
    r3 = node2sysdof(r, n, 1, ndofspr);
    r4 = r3 + 2;

    % Insert penalty terms into sparse storage
    [I, J, V, count] = addSparseBlock(I, J, V, count, r1:r2, r1:r2, pmat); % Top-left
    [I, J, V, count] = addSparseBlock(I, J, V, count, r3:r4, r3:r4, pmat); % Bottom-right
    [I, J, V, count] = addSparseBlock(I, J, V, count, r1:r2, r3:r4, -pmat); % Top-right
    [I, J, V, count] = addSparseBlock(I, J, V, count, r3:r4, r1:r2, -pmat); % Bottom-left

    % Compute internal forces
    RNq = Rods(R).q(node2dof(N, dofs));
    rnq = Rods(r).q(node2dof(n, dofs));
    fvec = p * (RNq - rnq);

    % Update force vector
    F(r1:r2) = F(r1:r2) + fvec;
    F(r3:r4) = F(r3:r4) - fvec;
end

function [F, I, J, V, count] = processEdgePair(F, I, J, V, count, R, N, r, n, ndofspr, Rods, p)
    % Process torsional constraints for edge pairs

    % Torsional DOF
    dof = 4;

    % Compute system DOF indices
    r1 = node2sysdof(R, N, dof, ndofspr);
    r2 = node2sysdof(r, n, dof, ndofspr);

    % Insert penalty terms into sparse storage
    [I, J, V, count] = addSparseBlock(I, J, V, count, r1, r1, p); % Top-left
    [I, J, V, count] = addSparseBlock(I, J, V, count, r2, r2, p); % Bottom-right
    [I, J, V, count] = addSparseBlock(I, J, V, count, r1, r2, -p); % Top-right
    [I, J, V, count] = addSparseBlock(I, J, V, count, r2, r1, -p); % Bottom-left

    % Compute internal forces
    RNq = Rods(R).q(node2dof(N, dof));
    rnq = Rods(r).q(node2dof(n, dof));
    f = p * (RNq - rnq);

    % Update force vector
    F(r1) = F(r1) + f;
    F(r2) = F(r2) - f;
end

function [I, J, V, count] = addSparseBlock(I, J, V, count, row_idx, col_idx, block)
    % Efficiently adds a block to sparse triplet format
    [rr, cc] = ndgrid(row_idx, col_idx);
    n = numel(rr);
    I(count+1:count+n) = rr(:);
    J(count+1:count+n) = cc(:);
    V(count+1:count+n) = block(:);
    count = count + n;
end


% function [F, K] = linkerPenalty(Rods, conn, sys)
%     % Returns the penalty force vector and penalty stiffness matrix for linkers

%     % Initialize zero vectors and matrices
%     F = zeros(sys.ndof, 1);
%     K = zeros(sys.ndof);

%     % Number of connection
%     nconn = size(conn, 1);
    
%     for i = 1:nconn % i represents a single linker
%     for j = 1:2 % j represents the two edges

%         % Current connection
%         c = conn(i, j);

%         % First node pair (positional), M-m
%         [F, K] = processNodePair(F, K, c.R, c.M, c.r, c.m, sys.ndofpr, Rods, c.p);
        
%         % Second node pair (positional), N-n
%         [F, K] = processNodePair(F, K, c.R, c.N, c.r, c.n, sys.ndofpr, Rods, c.p);

%         % Edge pair (angular), E-e
%         [F, K] = processEdgePair(F, K, c.R, c.E, c.r, c.e, sys.ndofpr, Rods, c.p);

%     end
%     end

%     % Check if the matrix size remains the same while adding penalty
%     assert(isequal(size(K), [1 1]*sys.ndof), 'Stiffness matrix size changed while adding penalty');
% end

% function [F, K] = processNodePair(F, K, R, N, r, n, ndofspr, Rods, p)
%     % Binds positional dofs
%     % N-th node from R-th regular rod with n-th node from r-th linker rod 

%     % Stiffness terms
%     pmat = diag([p p p]);

%     % Positional dofs
%     dofs = [1 2 3];

%     % Rows (and cols) to be updated
%     r1 = node2sysdof(R, N, 1, ndofspr);
%     r2 = r1 + 2;
%     r3 = node2sysdof(r, n, 1, ndofspr);
%     r4 = r3 + 2;

%     % Instrt penalty terms into stiffness matrix
%     K(r1:r2, r1:r2) = K(r1:r2, r1:r2) + pmat; % Top-left
%     K(r3:r4, r3:r4) = K(r3:r4, r3:r4) + pmat; % Bottom-right
%     K(r1:r2, r3:r4) = K(r1:r2, r3:r4) - pmat; % Top-right
%     K(r3:r4, r1:r2) = K(r3:r4, r1:r2) - pmat; % Bottom-left

%     % Compute internal forces
%     RNq = Rods(R).q(node2dof(N, dofs)); % Position of node N from rod R
%     rnq = Rods(r).q(node2dof(n, dofs)); % Position of node n from rod r
%     fvec = p * (RNq - rnq); % 3x1 vector

%     % Update Force terms
%     F(r1:r2) = F(r1:r2) + fvec;
%     F(r3:r4) = F(r3:r4) - fvec;
    
% end

% function [F, K] = processEdgePair(F, K, R, N, r, n, ndofspr, Rods, p)
%     % Binds torsional dofs
%     % N-th edge from R-th regular rod with n-th edge from r-th linker rod 

%     % Torsional dof
%     dof = 4;

%     r1 = node2sysdof(R, N, dof, ndofspr);
%     r2 = node2sysdof(r, n, dof, ndofspr);
    
%     % Matrix terms
%     K(r1, r1) = K(r1, r1) + p; % Top-left
%     K(r2, r2) = K(r2, r2) + p; % Bottom-right
%     K(r1, r2) = K(r1, r2) - p; % Top-right
%     K(r2, r1) = K(r2, r1) - p; % Bottom-left

%     % Compute internal forces
%     RNq = Rods(R).q(node2dof(N, dof)); % Twist of edge N from rod R
%     rnq = Rods(r).q(node2dof(n, dof)); % Twist of edge n from rod r
%     f = p * (RNq - rnq); % scalar

%     % Force terms
%     F(r1) = F(r1) + f;
%     F(r2) = F(r2) - f;
% end
