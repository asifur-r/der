function [Fcp, Kcp] = constraintPenaltyFULL(ana, sol, sys)
    % Returns the constraint penalty force vector and stiffness matrix

    % Validation
    validateConstraintPenalty(sol.Res, sol.Prdisp, sys.ndofpr);

    % Penalty matrix for restraint
    Kcp_r = diag(sol.Res) * ana.penalty;

    % Penalty matrix for prescribed displacement
    Kcp_pd = diag(sol.Prdisp) * ana.penalty;

    % Total penalty stiffness matrix
    Kcp = Kcp_r + Kcp_pd;

    % Constraint penalty force vector
    Fcp = Kcp * (sol.Prdisp - sol.u);

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