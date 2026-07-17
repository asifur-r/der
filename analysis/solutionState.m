function sol = solutionState(sol, sys, ana)

    % Update velocity
    switch ana.integration

        case 'euler'
            sol.v = (sol.u - sol.up)/ana.dt;

        case 'newmark'
            sol.v = (sol.u - sol.up) / (ana.dt * ana.betaN) - (1 - ana.betaN) / ana.betaN * sol.vp;

    end

    % Set current displacement and velocity as 'previous' for the next iteration
    sol.vp = sol.v;
    sol.up = sol.u;

    % Do the same for the force vectors
    sol.Fep = fullVector(sol.Fe, sys.frdof, sys.ndof);
    sol.Fip = fullVector(sol.Fi, sys.frdof, sys.ndof);

    % Update time vector
    sol.T = [sol.T sol.t];
    
end