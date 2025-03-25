function [Fs, Ks] = stretchingForceStiffnessSPARSE(t, enorm, enormbar, EA)
    
    nele = size(t, 1);
    ndof = nele2ndof(nele); % Compute number of DOFs

    % Preallocate sparse storage for stiffness
    lengthK = nele * 36; % Each addSparseBlock call inserts 9 elements, so four calls = 9 x 4 = 36
    IK = zeros(lengthK, 1);
    JK = zeros(lengthK, 1);
    VK = zeros(lengthK, 1);
    countK = 0;

    % Preallocate sparse storage force vector
    lengthF = nele * 6;
    IF = zeros(lengthF, 1);
    VF = zeros(lengthF, 1);
    countF = 0;

    % Assemble force and stiffness
    for i = 1:nele

        % Compute force contribution
        fs = (EA(i) * (enorm(i)/enormbar(i) - 1) * t(i, :))';
        
        % Define DOF indices
        p = 4*(i-1) + (1:3);
        q = p + 4;

        % Store element force vector
        ids = countF + (1:6);
        IF(ids) = [p, q]';
        VF(ids) = [-fs; fs];
        countF = countF + 6;

        % Compute element stiffness matrix
        ks = EA(i) * ( (1/enormbar(i) - 1/enorm(i)) * eye(3) + (t(i,:)' * t(i,:)) / enorm(i) );
        
        % Store stiffness matrix entries
        % [IK, JK, VK, countK] = addSparseBlock(IK, JK, VK, countK, p, p,  ks);
        % [IK, JK, VK, countK] = addSparseBlock(IK, JK, VK, countK, q, q,  ks);
        % [IK, JK, VK, countK] = addSparseBlock(IK, JK, VK, countK, p, q, -ks);
        % [IK, JK, VK, countK] = addSparseBlock(IK, JK, VK, countK, q, p, -ks);

        % Alternate technique without addSparseBlock

        % Generate row and col
        rows = [p q]; cols = [p q];
        
        % Generate indices using ndgrid
        % [r, c] = ndgrid(rows, cols);

        % Without using ndgrid
        r = rows(:) .* ones(1, length(cols));
        c = ones(length(rows), 1) .* cols(:)';

        % Combine the stiffness sub matrices (four 3x3)
        k = [ks -ks; -ks ks];

        % Store stiffness matrix entries
        ids = countK + (1:36);
        IK(ids) = r(:);
        JK(ids) = c(:);
        VK(ids) = k(:);
        countK = countK + 36;
    end

    % Construct sparse matrices
    Fs = sparse(IF, ones(length(IF), 1), VF, ndof, 1);
    Ks = sparse(IK, JK, VK, ndof, ndof);

end