function R = InitializeRod(points, sec, mat)
    % Returns rod struct

    % points = [x y z], 3 column coordinate matrix
    % sec = section object
    % mat = material object
    
    R = struct();

    % Geometry
    R.n = size(points, 1);
    R.nele = R.n-1;
    R.ndof = n2ndof(R.n);
    
    R.points = points;
    R.gam = zeros(R.nele, 1);
    R.q0 = stateVector(R.points, R.gam);

    % Material
    [...
    R.EA,...
    R.GJ,...
    R.EIx,...
    R.EIy] = rigidityVectors(R.nele, sec.h, sec.w, mat.E, mat.nu);
    
    % Restrain, force and prescribed displacement vector
    R.res = sparse(R.ndof, 1);
    R.fext = sparse(R.ndof, 1);
    R.prdisp = sparse(R.ndof, 1);

    % Corresponding time series tags
    R.resTag = ones(R.ndof, 1);
    R.fextTag = ones(R.ndof, 1);
    R.prdispTag = ones(R.ndof, 1);

    % Kinematics
    [...
    R.enormbar, ...
    R.tbar,...
    R.ellbar,...
    R.a1bar,...
    R.mref,...
    R.mbar,...
    R.kap1bar,...
    R.kap2bar] = initializeKinematics(R.q0);

    % Dynamic terms
    R.mdiag = massDiagonal(R.nele, R.enormbar, sec.h, sec.w, mat.rho);

    % Holds last iteration only (column vectors)
    R.q = R.q0;             % State vector
    R.u = zeros(R.ndof, 1); % Displacement vector
    R.v = zeros(R.ndof, 1); % Velocity vector

    % Stores all iterations (matrices)
    R.Q = R.q0;
    R.U = R.u;
    R.V = R.v;

    % Stores internal forces
    R.Fi = zeros(R.ndof, 1);
    R.FI = zeros(R.ndof, 1);

end