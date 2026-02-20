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
        VK(ids) = kb(:);
        countK = countK + 121;

    end

    % Construct sparse matrices
    Fb = sparse(IF, ones(length(IF), 1), VF, ndof, 1);
    Kb = sparse(IK, JK, VK, ndof, ndof);

end

% function [Fb, Kb] = bendingForceStiffnessSPARSE2(t, enorm, kapb, kap1, kap2, kap1bar, kap2bar, m1, m2, ellbar, EIx, EIy)
%     % Cell based sparse implementation (runs a little slower)

%     nele = size(t, 1);
%     ndof = nele2ndof(nele); % Compute number of DOFs

%     % Compute first and second derivatives of curvature
%     [bendGrad1, bendGrad2] = bendingGradient(t, enorm, kapb, kap1, kap2, m1, m2);
%     [bendHess1, bendHess2] = bendingHessian(t, enorm, kapb, kap1, kap2, m1, m2);

%     % Cell-based storage for stiffness matrix
%     IK = cell(nele-1, 1);
%     JK = cell(nele-1, 1);
%     VK = cell(nele-1, 1);

%     % Cell-based storage for force vector
%     IF = cell(nele-1, 1);
%     VF = cell(nele-1, 1);

%     % Assemble force and stiffness
%     for i = 2:nele

%         % Compute force contributions
%         fb1 = (EIx(i) / ellbar(i)) * (kap1(i) - kap1bar(i)) * bendGrad1(i, :)';
%         fb2 = (EIy(i) / ellbar(i)) * (kap2(i) - kap2bar(i)) * bendGrad2(i, :)';

%         % Define DOF indices
%         p = 1 + 4*(i-2);
%         q = p + 10;

%         % Store element force vector
%         IF{i-1} = (p:q)';
%         VF{i-1} = fb1 + fb2;

%         % Compute element stiffness matrix
%         A = (EIx(i) / ellbar(i)) * (bendGrad1(i, :)' * bendGrad1(i, :));
%         B = (EIy(i) / ellbar(i)) * (bendGrad2(i, :)' * bendGrad2(i, :));
%         C = (EIx(i) / ellbar(i)) * (kap1(i) - kap1bar(i)) * bendHess1(:, :, i);
%         D = (EIy(i) / ellbar(i)) * (kap2(i) - kap2bar(i)) * bendHess2(:, :, i);
%         kb = A + B + C + D;

%         % Store stiffness matrix entries
%         [IK{i-1}, JK{i-1}] = getSparseIndices(p:q, p:q);
%         VK{i-1} = kb(:);

%     end

%     % Flatten the cells
%     IF = vertcat(IF{:});
%     VF = vertcat(VF{:});

%     IK = vertcat(IK{:});
%     JK = vertcat(JK{:});
%     VK = vertcat(VK{:});

%     % Construct sparse matrices
%     Fb = sparse(IF, ones(length(IF), 1), VF, ndof, 1);
%     Kb = sparse(IK, JK, VK, ndof, ndof);

% end

% function [i, j] = getSparseIndices(rows, cols)
%     % Generates i, j indices for a sparse block.

%     % Ensure row and column vectors
%     rows = rows(:);
%     cols = cols(:);

%     % Create grid of indices
%     getIds = @(r, c) deal(repelem(r, length(c)), repmat(c, length(r), 1));

%     [i, j] = getIds(rows, cols);

% end