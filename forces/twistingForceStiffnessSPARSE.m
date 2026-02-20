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

% function [Ft, Kt] = twistingForceStiffnessSPARSE2(t, enorm, kapb, m, mbar, ellbar, GJ)
%     % Cell based sparse implementation (runs a little slower)

%     nele = size(t, 1);
%     ndof = nele2ndof(nele); % Compute number of DOFs

%     % Compute first and second derivatives of twist
%     twistGrad = twistingGradient(enorm, kapb);
%     twistHess = twistingHessian(t, enorm, kapb);

%     % Cell-based storage for stiffness
%     IK = cell(nele-1, 1);
%     JK = cell(nele-1, 1);
%     VK = cell(nele-1, 1);
    
%     % Cell-based storage for force vector
%     IF = cell(nele-1, 1);
%     VF = cell(nele-1, 1);

%     % Assemble force and stiffness
%     for i = 2:nele

%         % Compute force contributions
%         ft = (GJ(i) / ellbar(i)) * (m(i) - mbar(i)) * twistGrad(i, :)';

%         % Define DOF indices
%         p = 1 + 4*(i-2);
%         q = p + 10;

%         % Store element force vector
%         IF{i-1} = (p:q)';
%         VF{i-1} = ft;

%         % Compute element stiffness matrix
%         kt = (GJ(i) / ellbar(i)) * ((m(i) - mbar(i)) * twistHess(:, :, i) + twistGrad(i, :)' * twistGrad(i, :));

%         % Store stiffness matrix entries
%         [IK{i-1}, JK{i-1}] = getSparseIndices(p:q, p:q);
%         VK{i-1} = kt(:); % Flatten the stiffness matrix into a vector

%     end

%     % Flatten the cells and construct sparse matrices
%     IF = vertcat(IF{:});
%     VF = vertcat(VF{:});

%     IK = vertcat(IK{:});
%     JK = vertcat(JK{:});
%     VK = vertcat(VK{:});

%     Ft = sparse(IF, ones(length(IF), 1), VF, ndof, 1);
%     Kt = sparse(IK, JK, VK, ndof, ndof);
    
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