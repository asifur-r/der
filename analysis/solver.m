function sol = solver(Rods)

    sol = struct();

    % Store the rod level vectors in their separate cell arrays
    mdiags  = {Rods.mdiag};
    % ellbars = {Rods.ellbar};

    sol.staticMdiag  = vertcat(mdiags{:});
    % sol.Ellbar  = vertcat(ellbars{:});

    qs = {Rods.q};
    sol.q = vertcat(qs{:});

    % Time step
    sol.t = 0;

    % Time steps vector
    sol.T = 0;

    % Number of system dofs
    ndof = sysDofs(Rods);

    % Displacement and velocity vector
    sol.u  = zeros(ndof, 1); % at current time step
    sol.up = zeros(ndof, 1); % at previous time step
    sol.vp = zeros(ndof, 1); % at previous time step
    
    % External and internal force vector between time stpes (used in Newmark)
    sol.Fep = zeros(ndof, 1); % at previous time step
    sol.Fe  = zeros(ndof, 1); % at current time step

    sol.Fip = zeros(ndof, 1); % at previous time step
    sol.Fi  = zeros(ndof, 1); % at current time step

    % Full size internal force vetor (used for liveplot/recorder)
    sol.FINT = zeros(ndof, 1);
    
    sol.Ellbar = zeros(ndof, 1); % at current time step

end