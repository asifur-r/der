function mat = rayleighDamping(M, K, alpha, beta)
    % Returns omputes the Rayleigh damping matrix
    %
    % Inputs:
    %   M - Mass matrix
    %   K - Stiffness matrix
    %   alpha - Mass proportional damping coefficient
    %   beta - Stiffness proportional damping coefficient
    %
    % Output:
    %   C - Rayleigh damping matrix

    % Compute the Rayleigh damping matrix
    C = alpha * M + beta * K;
    mat = C;

end