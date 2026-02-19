function [du, dl] = newtonRaphson(Kt, R)
    % Kt is actually the jacobian J

    % Explicitly set dl to zero unlike mgdm
    dl = 0;

    % % Direct Solve
    du = solveDirect(Kt, R);
    
    % % AMD + LU
    % du = solveAMD(Kt, R);
    
    % % LU Decomposition
    % du = solveLU(Kt, R);

    % % Cholesky Decomposition
    % du = solveCholesky(Kt, R);

    % % RCM + LU
    % du = solveRCM(Kt, R);

end

% Sub-function for Direct Solve
function du = solveDirect(Kt, R)

    du = Kt \ R;

end

% Sub-function for LU Decomposition
function du = solveLU(Kt, R)

    [L, U, P] = lu(Kt);
    du = U \ (L \ (P * R));

end

% Sub-function for Cholesky Decomposition
function du = solveCholesky(Kt, R)

    Rc = chol(Kt, 'lower');
    du = Rc' \ (Rc \ R);

    % if issymmetric(Kt) && all(eig(Kt) > 0)
    %     Rc = chol(Kt, 'lower');
    %     du = Rc' \ (Rc \ R);
    % else
    %     du = NaN;
    %     t = NaN;
    %     fprintf('Cholesky Solve: Not applicable (not symmetric positive definite)\n');
    % end
end

% Sub-function for RCM + LU
function du = solveRCM(Kt, R)

    p = symrcm(Kt); % Compute RCM permutation
    Ktr = Kt(p, p); % Reorder rows and columns
    Rr = R(p); % Reorder residual

    [L, U, P] = lu(Ktr);
    dur = U \ (L \ (P * Rr));

    % Reverse the permutation to get original order
    du = zeros(size(R));
    du(p) = dur;

end

% Sub-function for AMD + LU
function du = solveAMD(Kt, R)

    p = amd(Kt);
    Kta = Kt(p, p);
    Ra = R(p);
    [La, Ua, Pa] = lu(Kta);
    dua = Ua \ (La \ (Pa * Ra));
    du = zeros(size(R));
    du(p) = dua;

end