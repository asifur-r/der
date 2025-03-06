function sol = solver(Rods)

    sol = struct();

    % Store the rod level vectors in their separate cell arrays
    fexts   = arrayfun(@(r) r.fext,   Rods, 'UniformOutput', false);
    ress    = arrayfun(@(r) r.res,    Rods, 'UniformOutput', false);
    prdisps = arrayfun(@(r) r.prdisp, Rods, 'UniformOutput', false);

    mdiags  = arrayfun(@(r) r.mdiag,  Rods, 'UniformOutput', false);
    ellbars = arrayfun(@(r) r.ellbar, Rods, 'UniformOutput', false);

    fextTags   = arrayfun(@(r) r.fextTag,   Rods, 'UniformOutput', false);
    resTags    = arrayfun(@(r) r.resTag,    Rods, 'UniformOutput', false);
    prdispTags = arrayfun(@(r) r.prdispTag, Rods, 'UniformOutput', false);

    % Stack the vectors (containted in the cell arrays) to a system level vectors
    sol.Fext    = vertcat(fexts{:});
    sol.Res     = vertcat(ress{:});
    sol.Prdisp  = vertcat(prdisps{:});

    sol.Mdiag   = vertcat(mdiags{:});
    sol.Ellbar  = vertcat(ellbars{:});

    sol.FextTag    = vertcat(fextTags{:});
    sol.ResTag     = vertcat(resTags{:});
    sol.PrdispTag  = vertcat(prdispTags{:});

    % Pseudo time step
    sol.t = 0;

    % % Load factor at current time step
    % sol.lam = 0;
    
    % % Vector containing the load factors (grows as time progresses)
    % sol.L = sol.lam;

    % Number of system dofs
    [~, ndof] = sysDofs(Rods);

    % Full size internal force vetor (used for liveplot/recorder)
    sol.FINT = zeros(ndof, 1);

    % Displacement and velocity vector
    sol.u  = zeros(ndof, 1); % at current time step
    sol.up = zeros(ndof, 1); % at previous time step
    sol.vp = zeros(ndof, 1); % at previous time step

    % External force vector between time stpes (used in Newmark)
    sol.Fep = zeros(ndof, 1); % at previous time step
    sol.Fe = zeros(ndof, 1); % at current time step

    sol.Fip = zeros(ndof, 1); % at previous time step
    sol.Fi = zeros(ndof, 1); % at current time step

end