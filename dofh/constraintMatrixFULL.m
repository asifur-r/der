function W = constraintMatrixFULL(Res)%, Prdisp)
    % Returns the constraint matrix by applying boundary condtions

    % Res = Full sized system restraint vector

    % Makes an identity matrix 
    W = eye(length(Res));

    % Get a logical index which columns of W should be eliminated
    ids = (Res ~= 0);
    %ids = (Res ~= 0 | Prdisp ~= 0);

    % Eliminate the ids columns in W
    W(:, ids) = [];

end