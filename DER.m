function solution = DER(rods, linkspec, ana, visual, monitor, rec)

% Validate analysis object
ana.Validate();

% Generate linker rods
[linkers, conn] = linkerRods(rods, linkspec);

% Contains both regular and linker ders
Rods = [rods, linkers];

% Number of linkers
numLinkers = length(linkers);

% Initialize solver stuct
sol = solver(Rods);

while sol.t < ana.tf
    
    clc
    
    % Prepare
    [Rods, sol, sys, backup] =  prepareStep(Rods, sol, ana, numLinkers);

    % Solve step
    [sol, Rods, isConverged] = solveStep(Rods, conn, ana, sys, sol, monitor);

    % Update time stepping
    [ana, sol, Rods, retryStep, terminate] = timeStepping(ana, sol, Rods, backup, isConverged);

    % Retry or go to update if converged
    if retryStep; continue; end; if terminate; break; end

    % Reaches here only if converged, now update
    sol = solutionState(sol, sys, ana);
    Rods = rodHistory(Rods);
    updateOutputs(Rods, ana, sol, visual, rec, monitor);

end

solution = solutionStruct(Rods, sys, sol);

end


