function [Fcp, Kcp] = constraintPenaltySPARSE(ana, sol, sys)
    % Returns the constraint penalty force vector and sparse stiffness matrix

    % Validate constraint penalty inputs
    validateConstraintPenalty(sol.Res, sol.Prdisp, sys.ndofpr);

    % Efficient sparse diagonal penalty matrices
    Kcp_r = spdiags(sol.Res * ana.penalty, 0, sys.ndof, sys.ndof);  % Restraint penalty
    Kcp_pd = spdiags(sol.Prdisp * ana.penalty, 0, sys.ndof, sys.ndof); % Prescribed displacement penalty

    % Total penalty stiffness matrix (remains sparse)
    Kcp = Kcp_r + Kcp_pd;

    % Compute sparse-friendly constraint penalty force vector
    Fcp = Kcp * (sol.lam .* sol.Prdisp - sol.u);

end


function validateConstraintPenalty(Res, Prdisp, ndofspr)
    % Checks if both restraint and prescried disp are not applied on the same dof

    % Logical vector contains if both restrain and displacement are prescribed in a dof
    areBothNonZero = Res ~= 0 & Prdisp ~= 0;

    if any(areBothNonZero) % Violation found

        % Find which dof the violation has occured
        nonZeroDof = find(areBothNonZero);

        % Get rod id, node id and local dof id
        [r, n, d] = sysdof2rod(nonZeroDof, ndofspr);

        % Return with error message
        error('Restraint and prescribed displacement both are applied in rod %d at node %d in dof %d', r, n, d);

    end

end