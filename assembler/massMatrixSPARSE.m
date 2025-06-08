function mat = massMatrixSPARSE(diagM)
    % Takes diagonal of the mass matrix and returns the full matrix

    mat = spdiags(diagM(:), 0, length(diagM), length(diagM));
    % mat = sparse(diag(diagM));
    
end