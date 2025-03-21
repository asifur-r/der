function [Fs, Ks] = stretchingForceStiffnessSPARSE2(t, enorm, enormbar, EA)

    nele = size(t, 1);
    ndof = nele2ndof(nele); % Compute number of DOFs

    % Cell-based storage for stiffness
    IK = cell(nele, 1);
    JK = cell(nele, 1);
    VK = cell(nele, 1);

    % Cell-based storage for force vector
    IF = cell(nele, 1);
    VF = cell(nele, 1);

    % Assemble force and stiffness
    for i = 1:nele

        % Compute force contribution
        fs = (EA(i) * (enorm(i)/enormbar(i) - 1) * t(i, :))';

        % Define DOF indices
        p = 4*(i-1) + (1:3);
        q = p + 4;

        % Store element force vector
        IF{i} = [p, q]';
        VF{i} = [-fs; fs];

        % Compute element stiffness matrix
        ks = EA(i) * ((1/enormbar(i) - 1/enorm(i)) * eye(3) + (t(i, :)' * t(i, :)) / enorm(i));

        % Store stiffness matrix entries
        [IK{i}, JK{i}] = getSparseIndices(p, q);
        VK{i} = [ks(:); ks(:); -ks(:); -ks(:)]; %flatten ks into a vector.

    end

    % Flatten the cells and construct sparse matrices
    IF = vertcat(IF{:});
    VF = vertcat(VF{:});

    IK = vertcat(IK{:});
    JK = vertcat(JK{:});
    VK = vertcat(VK{:});

    Fs = sparse(IF, ones(length(IF), 1), VF, ndof, 1);
    Ks = sparse(IK, JK, VK, ndof, ndof);

end

function [i, j] = getSparseIndices(p, q)
    % Generates i, j indices for a sparse block.

    % Ensure p and q are column vectors
    p = p(:); q = q(:);

    % Anonymous function generating the indices
    getIds = @(r, c) deal(repelem(r, length(c)), repmat(c, length(r), 1));
 
    % Construt the indices pairs
    %[i, j] = ndgrid(rows, cols);

	% Same thing with repmat
	% i = repmat(rows', 1, length(cols));
	% j = repmat(cols, length(rows), 1);

    % Create cells for the indices
    i = cell(4, 1);
    j = cell(4, 1);

    % Combinations of p and q in a cell array
    com = {[p, p], [q, q], [p, q], [q, p]};
    
    % Get the ids for each combination
    for k = 1:4; [i{k}, j{k}] = getIds(com{k}(:, 1), com{k}(:, 2)); end
    
    % Flatten the cells
    i = vertcat(i{:});
    j = vertcat(j{:});

end