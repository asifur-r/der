function [Fs, Ks] = stretchingForceStiffnessSPARSE(t, enorm, enormbar, EA)
    
    nele = size(t, 1);
    ndof = nele2ndof(nele); % Compute number of DOFs

    % Preallocate force vector
    Fs = zeros(ndof, 1);

    % Preallocate sparse matrix storage (approximate max nonzeros)
    max_entries = 9 * (9 + (nele-2) * 5); % Conservative upper bound
    I = zeros(max_entries, 1);
    J = zeros(max_entries, 1);
    V = zeros(max_entries, 1);
    count = 0;

    % Assemble force and stiffness
    for i = 1:nele
        % Compute force contribution
        fs = EA(i) * (enorm(i)/enormbar(i) - 1) * t(i, :);
        
        % Define DOF indices
        p = 4*(i-1) + (1:3);
        po = p + 4;

        % Assemble force vector
        Fs(p)  = Fs(p)  - fs';
        Fs(po) = Fs(po) + fs';

        % Compute element stiffness matrix
        ks = EA(i) * ( (1/enormbar(i) - 1/enorm(i)) * eye(3) + (t(i,:)' * t(i,:)) / enorm(i) );

        % Store stiffness matrix entries
        [I, J, V, count] = addBlock(I, J, V, count, p, p,  ks);
        [I, J, V, count] = addBlock(I, J, V, count, po, po, ks);
        [I, J, V, count] = addBlock(I, J, V, count, p, po, -ks);
        [I, J, V, count] = addBlock(I, J, V, count, po, p, -ks);
    end

    % Construct sparse stiffness matrix
    Ks = sparse(I(1:count), J(1:count), V(1:count), ndof, ndof);
    %[ndof count max_entries]
    %full(Ks)
end

function [I, J, V, count] = addBlock(I, J, V, count, row_idx, col_idx, block)
    % Efficiently adds a block to sparse matrix triplet format
    [rr, cc] = ndgrid(row_idx, col_idx);
    n = numel(rr);
    I(count+1:count+n) = rr(:);
    J(count+1:count+n) = cc(:);
    V(count+1:count+n) = block(:);
    count = count + n;
end