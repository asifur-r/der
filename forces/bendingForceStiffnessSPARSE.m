function [Fb, Kb] = bendingForceStiffnessSPARSE(t, enorm, kapb, kap1, kap2, kap1bar, kap2bar, m1, m2, ellbar, EIx, EIy)
    
    nele = size(t, 1);
    ndof = nele2ndof(nele); % Compute number of DOFs

    % Compute first and second derivatives of curvature
    [bendGrad1, bendGrad2] = bendingGradient(t, enorm, kapb, kap1, kap2, m1, m2);
    [bendHess1, bendHess2] = bendingHessian(t, enorm, kapb, kap1, kap2, m1, m2);

    % Preallocate sparse storage
    lengthK = 121 * (nele - 1); % Upper bound (each 11x11 block)
    IK = zeros(lengthK, 1);
    JK = zeros(lengthK, 1);
    VK = zeros(lengthK, 1);
    countK = 0;

    % Preallocate sparse storage for force vector
    lengthF = 11 * (nele - 1); % Each iteration contributes to 11 DOFs
    countF = 0;
    IF = zeros(lengthF, 1);
    VF = zeros(lengthF, 1);

    % Assemble force and stiffness
    for i = 2:nele

        % Compute force contributions
        fb1 = (EIx(i) / ellbar(i)) * (kap1(i) - kap1bar(i)) * bendGrad1(i, :)';
        fb2 = (EIy(i) / ellbar(i)) * (kap2(i) - kap2bar(i)) * bendGrad2(i, :)';

        % Define DOF indices
        p = 1 + 4*(i-2);
        q = p + 10;

        % Store element force vector
        ids = countF + (1:11);
        IF(ids) = (p:q)';
        VF(ids) = fb1 + fb2;
        countF = countF + 11;

        % Compute element stiffness matrix
        A = (EIx(i) / ellbar(i)) * (bendGrad1(i, :)' * bendGrad1(i, :));
        B = (EIy(i) / ellbar(i)) * (bendGrad2(i, :)' * bendGrad2(i, :));
        C = (EIx(i) / ellbar(i)) * (kap1(i) - kap1bar(i)) * bendHess1(:, :, i);
        D = (EIy(i) / ellbar(i)) * (kap2(i) - kap2bar(i)) * bendHess2(:, :, i);
        kb = A + B + C + D;

        % Store stiffness matrix entries
        [IK, JK, VK, countK] = addSparseBlock(IK, JK, VK, countK, p:q, p:q, kb);
    end

    % Construct sparse matrices
    Fb = sparse(IF, ones(length(IF), 1), VF, ndof, 1);
    Kb = sparse(IK, JK, VK, ndof, ndof);

end
