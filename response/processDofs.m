function str = processDofs(mat)
% Processes dof matrices into arrays of structs of 3 fields: 'rod', 'node', 'dof'

    % Check if matrix is empty
    if isempty(mat); str = []; return; end

    % Get matrix size
    [ndofs, ncols] = size(mat);

    % Check if it has 3 column only
    if ncols ~= 3; error(['Specify 3 values ([rod, node, localdof]) for each dof.']); end

    % Process the struct
    str = arrayfun(@(i) struct('rod', mat(i, 1), 'node', mat(i, 2), 'dof', mat(i, 3)), 1:ndofs);
    
end