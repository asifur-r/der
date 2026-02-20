function [Fs, Ks] = stretchingForceStiffnessFULL(t, enorm, enormbar, EA)
    
    nele = size(t, 1);
    ndof = nele2ndof(nele);

    % Streching force vector
    Fs = zeros(ndof, 1);

    for i = 1:nele

        % Eq. 8.28
        % Contribution of force from current element
        % This is added in both j-1 th and j-th node

        fs = EA(i) * (enorm(i)/enormbar(i) - 1) * t(i, :);
        
        % Row, col ids in global force vector
        p = 4*(i-1) + 1;
        q = p + 2;

        % For j-1 th node
        Fs(p:q) = Fs(p:q) - fs';
        
        % Update ids for next node
        p = 4*i + 1;
        q = p + 2;

        % For j th node
        Fs(p:q) = Fs(p:q) + fs';

    end

    % Streching stiffness matrix
    Ks = zeros(ndof);

    for i = 1:nele

        % Eq. 8.30
        % ks is 3x3 matrix
        ks = EA(i) * ( (1/enormbar(i) - 1/enorm(i)) * eye(3) + (t(i,:)' * t(i,:)) / enorm(i) );
        
        % Row, col ids in global stiffness matrix for current 3x3 block
        p = 4*(i-1) + 1;
        q = p + 2;

        % Offsets for adjacent 3x3 block
        po = p + 4;
        qo = q + 4;
        
        % Main diagonal blocks
        Ks(p:q, p:q) = Ks(p:q, p:q) + ks;
        Ks(po:qo, po:qo) = Ks(po:qo, po:qo) + ks;

        % Off diagonal blocks
        Ks(p:q, po:qo) = Ks(p:q, po:qo) - ks;
        Ks(po:qo, p:q) = Ks(po:qo, p:q) - ks;
        
    end

    Fs = sparse(Fs);
    Ks = sparse(Ks);
end