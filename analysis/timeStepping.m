function [ana, sol, Rods, retryStep, terminate] = ...
    timeStepping(ana, sol, Rods, backup, isConverged)

    retryStep = false;
    terminate = false;

switch ana.timeSteppingMode

    case 'constant'

        if ~isConverged; terminate = true; end

    case 'adaptive'

        % Decrease dt if fails, and restore last converged state
        if ~isConverged

            dtNew = ana.dt * 0.90;

            if dtNew < ana.dtMin
                terminate = true;
            else
                ana.dt = dtNew;
                sol = backup.sol;
                Rods = backup.Rods;
                retryStep = true;
            end
        
        % Increase dt if converges fast
        elseif sol.i < 10

            dtNew = ana.dt * 1.10;

            if dtNew < ana.dtMax
                ana.dt = dtNew;
            end

        end

end