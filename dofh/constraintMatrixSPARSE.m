function W = constraintMatrixSPARSE(Res)
    % Returns a sparse constraint matrix by applying boundary conditions

    % Find indices to keep (where Res == 0)
    keep_ids = Res == 0;

    % Directly construct a sparse identity matrix with selected columns
    W = speye(length(Res));
    W = W(:, keep_ids); % Keep only non-restrained DOFs

end
