function [du, dl] = newtonRaphson(Kt, R)
    dl = 0; % Initialize displacement increment
    % du = 0 * R;

    % LU Decomposition
    [L, U, P] = lu(Kt);
    du = U \ (L \ (P * R));

    % % Direct Solve
    % [du_direct, t_direct] = solveDirect(Kt, R);
    % du = du_direct; % Assign result from the chosen method

    % % LU Decomposition
    % [du_lu, t_lu] = solveLU(Kt, R);

    % % Cholesky Decomposition
    % [du_chol, t_chol] = solveCholesky(Kt, R);

    % % RCM + LU
    % [du_rcm, t_rcm] = solveRCM(Kt, R);
    % if ~isnan(t_rcm), du = du_rcm; end % Update if RCM was performed

    % % AMD + LU
    % [du_amd, t_amd] = solveAMD(Kt, R);
    % if ~isnan(t_amd), du = du_amd; end % Update if AMD was performed
    
end

% Sub-function for Direct Solve
function [du, t] = solveDirect(Kt, R)
    tic;
    du = Kt \ R;
    t = toc;
    fprintf('Direct Solve: %.4f sec\n', t);
end

% Sub-function for LU Decomposition
function [du, t] = solveLU(Kt, R)
    tic;
    [L, U, P] = lu(Kt);
    du = U \ (L \ (P * R));
    t = toc;
    fprintf('LU Factorization: %.4f sec\n', t);
end

% Sub-function for Cholesky Decomposition
function [du, t] = solveCholesky(Kt, R)
    tic;
    if issymmetric(Kt) && all(eig(Kt) > 0)
        Rchol = chol(Kt, 'lower');
        du = Rchol' \ (Rchol \ R);
        t = toc;
        fprintf('Cholesky Solve: %.4f sec\n', t);
    else
        du = NaN;
        t = NaN;
        fprintf('Cholesky Solve: Not applicable (not symmetric positive definite)\n');
    end
end

% Sub-function for RCM + LU
function [du, t] = solveRCM(Kt, R)
    tic;
    p = symrcm(Kt); % Compute RCM permutation
    Kt_rcm = Kt(p, p); % Reorder rows and columns
    R_rcm = R(p); % Reorder residual

    [L, U, P] = lu(Kt_rcm);
    du_rcm = U \ (L \ (P * R_rcm));

    % Reverse the permutation to get original order
    du = zeros(size(R));
    du(p) = du_rcm;
    t = toc;
    fprintf('RCM + LU: %.4f sec\n', t);
end

% Sub-function for AMD + LU
function [du, t] = solveAMD(Kt, R)
    tic;
    p = amd(Kt);
    Kt_amd = Kt(p, p);
    R_amd = R(p);
    [L_amd, U_amd, P_amd] = lu(Kt_amd);
    du_amd = U_amd \ (L_amd \ (P_amd * R_amd));
    du = zeros(size(R));
    du(p) = du_amd; % Reverse permutation
    t = toc;
    fprintf('AMD + LU: %.4f sec\n', t);
end


% % Sub-function to display timings
% function displayTimings(t_direct, t_lu, t_chol, t_rcm, t_amd)
%     fprintf('\nTiming Results:\n');
%     if ~isnan(t_direct), fprintf('Direct Solve: %.4f sec\n', t_direct); end
%     if ~isnan(t_lu), fprintf('LU Factorization: %.4f sec\n', t_lu); end
%     if ~isnan(t_chol), fprintf('Cholesky Solve: %.4f sec\n', t_chol); end
%     if ~isnan(t_rcm), fprintf('RCM + LU: %.4f sec\n', t_rcm); end
%     if ~isnan(t_amd), fprintf('AMD + LU: %.4f sec\n', t_amd); en
% end