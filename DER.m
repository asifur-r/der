function solution = DER(rods, linkspec, ana, visual, monitor, rec)

    % Validate analysis object
    ana.Validate();

    % Generate linker rods
    [linkers, conn] = linkerRods(rods, linkspec);

    % Contains both regular and linker ders
    Rods = [rods, linkers];

    % Initialize solver stuct
    sol = solver(Rods);

    while sol.t < ana.tf
        
        clc
        
        % Prepare
        [sol, sys, backup] =  prepareStep(Rods, sol, ana);

        % Solve step
        [sol, Rods, isConverged] = solveStep(Rods, conn, ana, sys, sol, monitor);

        % Rods = updateRodStates(Rods, sol, sys);
        
        % Update time stepping
        [action, ana] = ana.UpdateTimeStep(isConverged, sol.i);

        switch action
            case 'retry'; [sol, Rods] = backup.Restore(); continue;
            case 'terminate'; break;
        end

        % Reaches here only if converged, now update
        sol = solutionState(sol, sys, ana);
        
        Rods = rodHistory(Rods);
        updateOutputs(Rods, ana, sol, visual, rec, monitor);

    end

    solution = solutionStruct(Rods, sys, sol, ana);

end

function [sol, sys, backup] =  prepareStep(Rods, sol, ana)

    % Save current state in case convergence fails
    backup = Backup(sol, Rods);

    % Update time step
    sol.t = sol.t + ana.dt; 
    printTimeStats(sol.t, ana.tf, ana.dt);

    % Update time dependant properties
    sol = assignTimeDependants(Rods, ana, sol);

    % Initialize properties
    sys = systemProperties(Rods, ana, sol);

    % Initialize displacement vector for iteration
    sol.u = sol.up;
end

function sol = solutionState(sol, sys, ana)

    % Velocity update
    sol = ana.velocityUpdate(sol, ana);

    % Set current displacement and velocity as 'previous' for the next iteration
    sol.vp = sol.v;
    sol.up = sol.u;

    % Do the same for the force vectors
    sol.Fep = fullVector(sol.Fe, sys.frdof, sys.ndof);
    sol.Fip = fullVector(sol.Fi, sys.frdof, sys.ndof);

    % Update time vector
    sol.T = [sol.T sol.t];
    
end

function Rods = rodHistory(Rods)

    for r = 1:length(Rods); Rods(r) = Rods(r).CommitStep(); end

end

function updateOutputs(Rods, ana, sol, visual, rec, monitor)

    % Show live plot
    if ~isempty(visual); livePlot(Rods, sol, visual); end

    % Write in recorder
    if ~isempty(rec); recorder(rec, Rods, ana, sol); end

    % Print monitor variables for each step
    if ~isempty(monitor) && ~isempty(monitor.step); eval(monitor.step); end

end

function S = solutionStruct(Rods, sys, sol, ana)

    % Prepare solution struct
    S = struct();
    S.ndofspr = sys.ndofpr;
    S.T   = sol.T;
    S.Qs  = {Rods.Q};
    S.Us  = {Rods.U};
    S.FIs = {Rods.FI};
    
    S.ESs = {Rods.Es};
    S.ETs = {Rods.Et};
    S.EBs = {Rods.Eb};
    S.Es  = {Rods.E};

    if sol.t >= ana.tf; S.completed = 1; else; S.completed = 0; end

end
