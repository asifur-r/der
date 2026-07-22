function [du, dl] = newtonRaphson(J, R)

    % Explicitly set dl to zero unlike mgdm
    dl = 0;

    % % Direct Solve
    du = solveDirect(J, R);
    
    % % AMD + LU
    % du = solveAMD(J, R);
    
    % % LU Decomposition
    % du = solveLU(J, R);

    % % Cholesky Decomposition
    % du = solveCholesky(J, R);

    % % RCM + LU
    % du = solveRCM(J, R);

end

% Sub-function for Direct Solve
function du = solveDirect(J, R)

    du = J \ R;

end

% Sub-function for LU Decomposition
function du = solveLU(J, R)

    [L, U, P] = lu(J);
    du = U \ (L \ (P * R));

end

% Sub-function for Cholesky Decomposition
function du = solveCholesky(J, R)

    Rc = chol(J, 'lower');
    du = Rc' \ (Rc \ R);

    % if issymmetric(J) && all(eig(J) > 0)
    %     Rc = chol(J, 'lower');
    %     du = Rc' \ (Rc \ R);
    % else
    %     du = NaN;
    %     t = NaN;
    %     fprintf('Cholesky Solve: Not applicable (not symmetric positive definite)\n');
    % end
end

% Sub-function for RCM + LU
function du = solveRCM(J, R)

    p = symrcm(J); % Compute RCM permutation
    Ktr = J(p, p); % Reorder rows and columns
    Rr = R(p); % Reorder residual

    [L, U, P] = lu(Ktr);
    dur = U \ (L \ (P * Rr));

    % Reverse the permutation to get original order
    du = zeros(size(R));
    du(p) = dur;

end

% Sub-function for AMD + LU
function du = solveAMD(J, R)

    p = amd(J);
    Kta = J(p, p);
    Ra = R(p);
    [La, Ua, Pa] = lu(Kta);
    dua = Ua \ (La \ (Pa * Ra));
    du = zeros(size(R));
    du(p) = dua;

end