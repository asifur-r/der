function [Fb, Kb] = bendingForceStiffnessSPARSE(t, enorm, kapb, kap1, kap2, kap1bar, kap2bar, m1, m2, ellbar, EIx, EIy)
    
    nele = size(t, 1);
    ndof = nele2ndof(nele); % Compute number of DOFs

    % Compute first and second derivatives of curvature
    [bendGrad1, bendGrad2] = bendingGradient(t, enorm, kapb, kap1, kap2, m1, m2);
    [bendHess1, bendHess2] = bendingHessian(t, enorm, kapb, kap1, kap2, m1, m2);

    % Preallocate force vector
    Fb = zeros(ndof, 1);

    % Preallocate sparse storage
    max_entries = 121 * (nele - 1); % Upper bound (each 11x11 block)
    I = zeros(max_entries, 1);
    J = zeros(max_entries, 1);
    V = zeros(max_entries, 1);
    count = 0;

    % Assemble force and stiffness
    for i = 2:nele
        % Compute force contributions
        fb1 = (EIx(i) / ellbar(i)) * (kap1(i) - kap1bar(i)) * bendGrad1(i, :)';
        fb2 = (EIy(i) / ellbar(i)) * (kap2(i) - kap2bar(i)) * bendGrad2(i, :)';

        % Define DOF indices
        p = 1 + 4*(i-2);
        q = p + 10;

        % Assemble force vector
        Fb(p:q) = Fb(p:q) + fb1 + fb2;

        % Compute element stiffness matrix
        A = (EIx(i) / ellbar(i)) * (bendGrad1(i, :)' * bendGrad1(i, :));
        B = (EIy(i) / ellbar(i)) * (bendGrad2(i, :)' * bendGrad2(i, :));
        C = (EIx(i) / ellbar(i)) * (kap1(i) - kap1bar(i)) * bendHess1(:, :, i);
        D = (EIy(i) / ellbar(i)) * (kap2(i) - kap2bar(i)) * bendHess2(:, :, i);
        kb = A + B + C + D;

        % Store stiffness matrix entries
        [I, J, V, count] = addBlock(I, J, V, count, p:q, p:q, kb);
    end

    % Construct sparse stiffness matrix
    Kb = sparse(I(1:count), J(1:count), V(1:count), ndof, ndof);

    %[ndof count max_entries]
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
