function [Rods, sol, sys, backup] =  prepareStep(Rods, sol, ana, numLinkers)

    % Save current state in case convergence fails
    backup = struct(); backup.sol = sol; backup.Rods = Rods;

    % Update time step
    sol.t = sol.t + ana.dt; printTimeStats(sol.t, ana.tf, ana.dt);

    % Update time dependant properties
    [Rods, sol] = assignTimeDependants(Rods, ana, sol);

    % Initialize properties
    sys = systemProperties(Rods, ana, sol, numLinkers);

    % Initialize displacement vector for iteration
    sol.u = sol.up;
end