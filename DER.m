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
    
    % Save current state in case convergence fails
    backup = struct(); backup.sol = sol; backup.Rods = Rods;
    
    % Update time step
    sol.t = sol.t + ana.dt; printTime(sol.t, ana.tf, ana.dt);

    % Update time dependant properties
    [Rods, sol] = assignTimeDependants(Rods, ana, sol);

    % Initialize properties
    sys = systemProperties(Rods, ana, sol, numLinkers);

    % Initialize displacement vector for iteration
    sol.u = sol.up;

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
        
        % Extract displacement, forces and update state vector of each rod
        for r=1:sys.numRods
            Rods(r).u = getRodLevelVector(sol.u, r, sys.ndofpr);
            Rods(r).Fi = getRodLevelVector(sol.FINT, r, sys.ndofpr);
            Rods(r).q = Rods(r).q0 + Rods(r).u;
        end
        
        % Print
        fprintf("i: %d, |du|= %.6f\n", sol.i, sol.err);
        if ~isempty(monitor) & ~isempty(monitor.iter); eval(monitor.iter); end

        % Check termination
        if sol.err <= ana.tol; isConverged = true; break; end
        if sol.i == ana.maxIteration || sol.err > ana.maxResidual; isConverged = false; break; end

        % Advance iteration
        sol.i = sol.i + 1;

    end
    
    % Break outer while loop if constatnt time stepping fails
    if strcmp(ana.timeSteppingMode, 'constant') && isConverged == false; break; end

    % For adaptive time stepping, try again by increasing or decreasing dt
    if strcmp(ana.timeSteppingMode, 'adaptive')
    
        % Decrease dt if fails, and restore last converged state
        if isConverged == false; sol = backup.sol; Rods = backup.Rods; ana.dt = ana.dt * 0.90; continue; end

        % Increase dt if converges fast
        if isConverged == true && sol.i < 10; dtNew = ana.dt * 1.10; if dtNew < ana.dtMax; ana.dt = dtNew; end; end
    end

    % Reaches here for converged steps only

    % Update velocity
    if strcmp(ana.integration, 'euler')
        sol.v = (sol.u - sol.up) / ana.dt;

    elseif strcmp(ana.integration, 'newmark')
        sol.v = (sol.u - sol.up) / (ana.dt * ana.betaN) - (1 - ana.betaN) / ana.betaN * sol.vp;
    end

    % Set current displacement and velocity as 'previous' for the next iteration
    sol.vp = sol.v;
    sol.up = sol.u;
    
    % Do the same for the force vectors
    sol.Fep = fullVector(sol.Fe, sys.frdof, sys.ndof);
    sol.Fip = fullVector(sol.Fi, sys.frdof, sys.ndof);

    % Assign for each rod
    for r=1:sys.numRods
        Rods(r).Q = [Rods(r).Q, Rods(r).q]; 
        Rods(r).U = [Rods(r).U, Rods(r).u]; 
        Rods(r).FI= [Rods(r).FI,Rods(r).Fi];
    end

    % Show live plot
    if ~isempty(visual); livePlot(Rods, sol, visual); end

    % Write in recorder
    if ~isempty(rec); recorder(rec, Rods, ana, sol); end

    % Print monitor variables for each step
    if ~isempty(monitor) & ~isempty(monitor.step); eval(monitor.step); end

    % Update time vector
    sol.T = [sol.T sol.t];

end

solution = makeSolution(Rods, sys, sol);

end

function S = makeSolution(Rods, sys, sol)

    % Prepare solution struct
    S = struct();
    S.ndofspr = sys.ndofpr;
    S.T = sol.T;
    S.Qs = arrayfun(@(r) r.Q, Rods, 'UniformOutput', false);
    S.Us = arrayfun(@(r) r.U, Rods, 'UniformOutput', false);
    S.FIs = arrayfun(@(r) r.FI, Rods, 'UniformOutput', false);

end

function printTime(currentTime, finalTime, timeStep)
    % Prints the current time, time step, and a text-based progress bar
    % in the console.

    fprintf("Time: %.4f s, dt: %.4f s, ", currentTime, timeStep);

    barWidth = 50; % Width of the progress bar in characters

    percentComplete = (currentTime / finalTime) * 100;

    fullBlockChar = char(9608);     % Unicode for a full block character
    emptyBlockChar = char(9617);    % Unicode for a light shade block character

    numBlocksFilled = floor((percentComplete / 100) * barWidth);
    numBlocksEmpty = barWidth - numBlocksFilled;

    progressBar = ['[' ...
                   repmat(fullBlockChar, 1, numBlocksFilled) ...
                   repmat(emptyBlockChar, 1, numBlocksEmpty) ...
                   ']'];

    fprintf('Progress: %s %5.2f%%', progressBar, percentComplete);

    fprintf('\n');

end