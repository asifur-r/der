function solution = DER(rods, linkspec, ana, visual, monitor, rec)

% Validate analysis object
ana.Validate();

% Generate linker rods
[linkers, conn] = linkerRods(rods, linkspec);

% Contains both regular and linker ders
Rods = [rods, linkers];

% Number of actual rod
nrods = length(rods);

% Initialize solver stuct
sol = solver(Rods);

while sol.t < ana.tf

    % Update time step
    sol.t = sol.t + ana.dt; fprintf("Time: %.2f ------------ \n", sol.t)
    
    % Update time dependant properties
    [Rods, sol] = assignTimeDependants(Rods, ana, sol, nrods);

    % Initialize properties
    sys = systemProperties(Rods, ana);

    % Initialize displacement vector for iteration
    sol.u = sol.up;

    sol.i = 1;
    while sol.i <= ana.maxiter

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
        
        % Extract displacement of each rod
        for r=1:sys.nRods; Rods(r).u = getRodLevelVector(sol.u, r, sys.ndofpr); end
        for r=1:sys.nRods; Rods(r).Fi = getRodLevelVector(sol.FINT, r, sys.ndofpr); end

        % Update state vector for each rod
        for r=1:sys.nRods; Rods(r).q = Rods(r).q0 + Rods(r).u; end

        % Print, check termination and advance
        fprintf("i: %d, |du|= %.6f\n", sol.i, sol.err); if sol.i == ana.maxiter; error("maxiter"); end; if sol.err <= ana.tol; break; end; sol.i = sol.i + 1;

        % Print monitor variables for each iteration
        if ~isempty(monitor) & ~isempty(monitor.iter); eval(monitor.iter); end
        
    end
    
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
    for r=1:sys.nRods
        Rods(r).Q = [Rods(r).Q, Rods(r).q]; 
        Rods(r).U = [Rods(r).U, Rods(r).u]; 
        Rods(r).FI = [Rods(r).FI, Rods(r).Fi]; 
    end

    % Show live plot
    if ~isempty(visual); livePlot(Rods, sol, visual); end

    % Write in recorder
    if ~isempty(rec); recorder(rec, Rods, ana, sol); end

    % Print monitor variables for each step
    if ~isempty(monitor) & ~isempty(monitor.step); eval(monitor.step); end
 
end

% Plot final results
if ~isempty(visual); livePlot(Rods, sol, visual); end

% Prepare solution struct
solution = struct();
solution.ndofspr = sys.ndofpr;
solution.Qs = arrayfun(@(r) r.Q, Rods, 'UniformOutput', false);
solution.Us = arrayfun(@(r) r.U, Rods, 'UniformOutput', false);
solution.FIs = arrayfun(@(r) r.FI, Rods, 'UniformOutput', false);

end