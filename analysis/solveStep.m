function [sol, Rods, isConverged] = solveStep(Rods, conn, ana, sys, sol, monitor)
    
    sol.i = 1;
    while sol.i <= ana.maxIteration

        % Compute jacobian and residual
        sol = assembleSystem(Rods, conn, ana, sys, sol);
        
        % Solve for current iteration
        [sol.du, sol.dl, sol.err] = solveIteration(ana, sys, sol);
      
        % Update displacement vector
        sol = updateDisplacement(sol, sys, ana);
        
        % Update rods
        Rods = updateRodStates(Rods, sol, sys);

        % Print
        printIterationStatus(sol, monitor);

        % Check termination
        [isConverged, shouldBreak] = checkStepConvergence(sol, ana); if shouldBreak; break; end

        % Advance iteration
        sol.i = sol.i + 1;
        
    end

end

function sol = updateDisplacement(sol, sys, ana)
    % Update displacement vector based on constraint type
    
    switch ana.constraint
        case 'elimination'
            % Update free DOFs
            sol.u(sys.frdof) = sol.u(sys.frdof) + sol.du;
            
            % Insert prescribed displacements directly
            if sys.nprddof ~= 0
                sol.u(sys.prddof) = sol.Prdisp(sys.prddof);
            end
            
        case 'penalty'
            % Update all DOFs with penalty method
            sol.u = sol.u + sol.du;
    end
end

function Rods = updateRodStates(Rods, sol, sys)
    % Update all rods from global displacement and force vectors

    % Split global vectors into cell arrays of rod-level vectors
    us = mat2cell(sol.u, sys.ndofpr);
    Fis = mat2cell(sol.FINT, sys.ndofpr);
    
    % Update each rod
    for r = 1:numel(Rods); Rods(r) = Rods(r).UpdateState(us{r}, Fis{r}); end
    
end

function printIterationStatus(sol, monitor)
    
    % Print current iteration status
    fprintf("i: %d, |du|= %.6f\n", sol.i, sol.err);
    
    % Execute user-defined monitor callback
    if ~isempty(monitor) && ~isempty(monitor.iter)
        eval(monitor.iter);
    end
    
end

function [isConverged, shouldBreak] = checkStepConvergence(sol, ana)
    
    % Check termination conditions
    if sol.err <= ana.tol
        isConverged = true;
        shouldBreak = true;

    elseif sol.i == ana.maxIteration || sol.err > ana.maxResidual
        isConverged = false;
        shouldBreak = true;

    else
        isConverged = false;
        shouldBreak = false;
    end
    
end