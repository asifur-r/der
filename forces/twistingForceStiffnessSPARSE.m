function [Ft, Kt] = twistingForceStiffnessSPARSE(t, enorm, kapb, m, mbar, ellbar, GJ)
    
    nele = size(t, 1);
    ndof = nele2ndof(nele); % Compute number of DOFs

    % Compute first and second derivatives of twist
    twistGrad = twistingGradient(enorm, kapb);
    twistHess = twistingHessian(t, enorm, kapb);

    % Preallocate force vector
    Ft = zeros(ndof, 1);

    % Preallocate sparse storage
    max_entries = 121 * (nele - 1); % Upper bound (each 11x11 block)
    I = zeros(max_entries, 1);
    J = zeros(max_entries, 1);
    V = zeros(max_entries, 1);
    count = 0;

    % Assemble force and stiffness
    for i = 2:nele
        % Compute force contributions
        ft = (GJ(i) / ellbar(i)) * (m(i) - mbar(i)) * twistGrad(i, :)';

        % Define DOF indices
        p = 1 + 4*(i-2);
        q = p + 10;

        % Assemble force vector
        Ft(p:q) = Ft(p:q) + ft;

        % Compute element stiffness matrix
        kt = (GJ(i) / ellbar(i)) * ((m(i) - mbar(i)) * twistHess(:, :, i) + twistGrad(i, :)' * twistGrad(i, :));

        % Store stiffness matrix entries
        [I, J, V, count] = addBlock(I, J, V, count, p:q, p:q, kt);
    end

    % Construct sparse stiffness matrix
    Kt = sparse(I(1:count), J(1:count), V(1:count), ndof, ndof);

    % [ndof count max_entries]

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