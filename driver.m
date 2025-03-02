function solution = driver(rods, linkspec, ana, visual, monitor, rec)

% Generate linker rods
[linkers, conn] = linkerRods(rods, linkspec);

% Contains both regular and linker ders
Rods = [rods, linkers];

% System properties struct
sys = systemProperties(Rods, ana);

% Initialize solver stuct
sol = solver(Rods, sys);

while sol.lam < 1
    sol.t = sol.t + 1; fprintf("STEP: %d ------------ \n", sol.t)
    
    if strcmp(ana.solver, 'nr'); sol.lam = sol.lam + ana.lam0; end
    
    sol.i = 1;
    while sol.i <= ana.maxiter

        % Compute jacobian and residual
        sol = jacobianResidual(Rods, conn, ana, sys, sol);
        
        % Solve for current iteration
        [sol.du, sol.dl, sol.err] = solveIteration(ana, sys, sol);
        
        % Update load factor
        sol.lam = sol.lam + sol.dl;
      
        % Update displacement vector
        switch ana.constraint
            case 'elimination'
                %sol.u = sol.u + sol.W * sol.du;
                %sol.Fi = sol.W * sol.Fi;
                sol.u(sys.frdof) = sol.u(sys.frdof) + sol.du;
                % Insert prescribed displacement (if any) directly into the solution
                if sys.nprddof ~= 0; sol.u(sys.prddof) = sol.lam*sol.Prdisp(sys.prddof); end
                
            case 'penalty'
                sol.u = sol.u + sol.du;
        end
        
        % Extract displacement of each rod
        for r=1:sys.nRods; Rods(r).u = getRodLevelVector(sol.u, r, sys.ndofpr); end
        for r=1:sys.nRods; Rods(r).Fi = getRodLevelVector(sol.Fi, r, sys.ndofpr); end

        %for r=1:sys.nRods; Rods(r).ud = getRodLevelVector(ud, r, sys.ndofpr); end
        
        % Update state vector for each rod
        for r=1:sys.nRods; Rods(r).q = Rods(r).q0 + Rods(r).u; end

        % Print, check termination and advance
        fprintf("i: %d, |R|= %.6f\n", sol.i, sol.err); if sol.i == ana.maxiter; error("maxiter"); end; if sol.err <= ana.tol; break; end; sol.i = sol.i + 1;

        % Print monitor variables for each iteration
        if ~isempty(monitor) & ~isempty(monitor.iter); eval(monitor.iter); end
        
    end
    
    % Update load factor vector
    sol.L = [sol.L, sol.lam]; fprintf("lambda: %.4f\n\n", sol.lam)

    % Assign for each rod
    for r=1:sys.nRods; Rods(r).Q = [Rods(r).Q, Rods(r).q]; Rods(r).U = [Rods(r).U, Rods(r).u]; end
    for r=1:sys.nRods; Rods(r).FI = [Rods(r).FI, Rods(r).Fi]; end
    
    % Show live plot
    if ~isempty(visual); livePlot(Rods, sol.L, visual); end

    % Write in recorder
    if ~isempty(rec); recorder(rec, Rods, sol.t, sol.lam); end
        
    % Print monitor variables for each step
    if ~isempty(monitor) & ~isempty(monitor.step); eval(monitor.step); end
 
end

% Plot final results
if ~isempty(visual); livePlot(Rods, sol.L, visual); end

% Prepare solution struct
solution = struct();
solution.ndofspr = sys.ndofpr;
solution.L = sol.L;
solution.Qs = arrayfun(@(r) r.Q, Rods, 'UniformOutput', false);
solution.Us = arrayfun(@(r) r.U, Rods, 'UniformOutput', false);
solution.FIs = arrayfun(@(r) r.FI, Rods, 'UniformOutput', false);

end