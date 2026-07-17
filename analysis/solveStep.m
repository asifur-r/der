function [sol, Rods, isConverged] = solveStep(Rods, conn, ana, sys, sol, monitor)
    
    sol.i = 1;
    while sol.i <= ana.maxIteration

        % Compute jacobian and residual
        sol = jacobianResidual(Rods, conn, ana, sys, sol);
        
        % Solve for current iteration
        [sol.du, sol.dl, sol.err] = solveIteration(ana, sys, sol);
      
        % Update displacement vector
        switch ana.constraint
            case 'elimination'
                sol.u(sys.frdof) = sol.u(sys.frdof) + sol.du;
                
                % Insert prescribed displacement (if any) directly into the solution
                if sys.nprddof ~= 0; sol.u(sys.prddof) = sol.Prdisp(sys.prddof); end
                  
            case 'penalty'
                sol.u = sol.u + sol.du;
        end
        
        % Update rods
        for r=1:sys.numRods
            Rods(r).u = getRodLevelVector(sol.u, r, sys.ndofpr);
            Rods(r).Fi = getRodLevelVector(sol.FINT, r, sys.ndofpr);
            Rods(r).q = Rods(r).q0 + Rods(r).u;
        end
        
        % Print
        fprintf("i: %d, |du|= %.6f\n", sol.i, sol.err);
        if ~isempty(monitor) && ~isempty(monitor.iter); eval(monitor.iter); end

        % Check termination
        if sol.err <= ana.tol; isConverged = true; break; end
        if sol.i == ana.maxIteration || sol.err > ana.maxResidual; isConverged = false; break; end

        % Advance iteration
        sol.i = sol.i + 1;
        
    end

end
