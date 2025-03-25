function [Ft, Kt] = twistingForceStiffnessSPARSE(t, enorm, kapb, m, mbar, ellbar, GJ)
    
    nele = size(t, 1);
    ndof = nele2ndof(nele); % Compute number of DOFs

    % Compute first and second derivatives of twist
    twistGrad = twistingGradient(enorm, kapb);
    twistHess = twistingHessian(t, enorm, kapb);

    % Preallocate sparse storage for stiffness
    lengthK = 121 * (nele - 1); % Each iteration in the for loop makes a 11x11 block
    countK = 0;
    IK = zeros(lengthK, 1);
    JK = zeros(lengthK, 1);
    VK = zeros(lengthK, 1);
    
    % Preallocate sparse storage for force vector
    lengthF = 11 * (nele - 1); % Each iteration contributes to 11 DOFs
    countF = 0;
    IF = zeros(lengthF, 1);
    VF = zeros(lengthF, 1);

    % Assemble force and stiffness
    for i = 2:nele

        % Compute force contributions
        ft = (GJ(i) / ellbar(i)) * (m(i) - mbar(i)) * twistGrad(i, :)';

        % Define DOF indices
        p = 1 + 4*(i-2);
        q = p + 10;

        % Store element force vector
        ids = countF + (1:11);
        IF(ids) = (p:q)';
        VF(ids) = ft;
        countF = countF + 11;

        % Compute element stiffness matrix
        kt = (GJ(i) / ellbar(i)) * ((m(i) - mbar(i)) * twistHess(:, :, i) + twistGrad(i, :)' * twistGrad(i, :));
        
        % Store stiffness matrix entries
        % [IK, JK, VK, countK] = addSparseBlock(IK, JK, VK, countK, p:q, p:q, kt);

        % Alternate technique without addSparseBlock

        % Generate row and col
        rows = p:q; cols = p:q;

        % Generate indices using ndgrid
        % [r, c] = ndgrid(rows, cols);

        % Without using ndgrid
        r = rows(:) .* ones(1, length(cols));
        c = ones(length(rows), 1) .* cols(:)';
        
        % Store stiffness matrix entries
        ids = countK + (1:121);
        IK(ids) = r(:);
        JK(ids) = c(:);
        VK(ids) = kt(:);
        countK = countK + 121;

    end

    % Construct sparse matrices
    Ft = sparse(IF, ones(length(IF), 1), VF, ndof, 1);
    Kt = sparse(IK, JK, VK, ndof, ndof);
    
end