function sol = solver(Rods, sys)

    sol = struct();

    % Store the rod level vectors in their separate cell arrays
    fexts   = arrayfun(@(r) r.fext,   Rods, 'UniformOutput', false);
    ress    = arrayfun(@(r) r.res,    Rods, 'UniformOutput', false);
    prdisps = arrayfun(@(r) r.prdisp, Rods, 'UniformOutput', false);
    diagms  = arrayfun(@(r) r.mdiag,  Rods, 'UniformOutput', false);
    ellbars = arrayfun(@(r) r.ellbar, Rods, 'UniformOutput', false);

    % Stack the vectors (containted in the cell arrays) to a system level vectors
    sol.Fext    = vertcat(fexts{:});
    sol.Res     = vertcat(ress{:});
    sol.Prdisp  = vertcat(prdisps{:});
    sol.Mdiag   = vertcat(diagms{:});
    sol.Ellbar  = vertcat(ellbars{:});

    % Pseudo time step
    sol.t = 0;

    % Load factor at current time step
    sol.lam = 0;
    
    % Vector containing the load factors (grows as time progresses)
    sol.L = sol.lam;

    % Displacement and velocity vector
    sol.u = zeros(sys.ndof, 1); % at current time step
    sol.up = zeros(sys.ndof, 1); % at previous time step
    sol.vp = zeros(sys.ndof, 1); % at previous time step
    
end