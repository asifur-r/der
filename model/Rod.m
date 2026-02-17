classdef Rod
% Rod class for a DER object

properties (Access = public)
    % Geometry
    n               % Number of nodes
    nele            % Number of elements
    ndof            % Number of degrees of freedom
    points          % Node coordinates [x y z]
    gam             % Initial twist angles
    q0              % Initial state vector
    
    % Material properties
    EA              % Axial rigidity vector
    GJ              % Torsional rigidity vector
    EIx             % Bending rigidity about x-axis
    EIy             % Bending rigidity about y-axis
    
    % Boundary conditions
    res             % Restraint vector
    fext            % External force vector
    prdisp          % Prescribed displacement vector
    
    % Time series tags
    resTag          % Restraint time series tag
    fextTag         % External force time series tag
    prdispTag       % Prescribed displacement time series tag
    
    % Kinematics: reference quantities
    enormbar        % Element normal vectors
    tbar            % Tangent vectors
    ellbar          % Element lengths
    a1bar           % Reference orientation vectors
    mref            % Reference directors
    mbar            % Current directors
    kap1bar         % Reference curvature component 1
    kap2bar         % Reference curvature component 2
    
    % Dynamic terms
    mdiag           % Mass diagonal matrix
    
    % State variables (last iteration)
    q               % Current state vector
    u               % Current displacement vector
    v               % Current velocity vector
    
    % History variables (all iterations)
    Q               % State vector history
    U               % Displacement vector history
    
    % Internal forces
    Fi              % Current internal forces
    FI              % Inertial forces history
    
    % Energies
    Es              % Stretch energy
    Et              % Torsional energy
    Eb              % Bending energy
    E               % Total energy
    
    % Store input parameters for reference
    Section         % Section object
    Material        % Material object
end

methods
    function obj = Rod(points, sec, mat)
        % Constructor - initializes Rod object
        
        % Validate inputs
        obj.validate(points, sec, mat);
        
        % Geometry
        obj.n = size(points, 1);
        obj.nele = obj.n - 1;
        obj.ndof = n2ndof(obj.n);
        
        obj.points = points;
        obj.gam = zeros(obj.nele, 1);
        obj.q0 = stateVector(obj.points, obj.gam);
        
        % Material properties
        [...
        obj.EA,...
        obj.GJ,...
        obj.EIx,...
        obj.EIy] = rigidityVectors(obj.nele, sec.h, sec.w, sec.Jmod, mat.E, mat.nu);
        
        % Store input objects for reference
        obj.Section = sec;
        obj.Material = mat;
        
        % Restraint, force and prescribed displacement vector
        obj.res = sparse(obj.ndof, 1);
        obj.fext = sparse(obj.ndof, 1);
        obj.prdisp = sparse(obj.ndof, 1);
        
        % Corresponding time series tags
        obj.resTag = sparse(obj.ndof, 1);
        obj.fextTag = sparse(obj.ndof, 1);
        obj.prdispTag = sparse(obj.ndof, 1);
        
        % Kinematics: reference quantities
        [...
        obj.enormbar, ...
        obj.tbar,...
        obj.ellbar,...
        obj.a1bar,...
        obj.mref,...
        obj.mbar,...
        obj.kap1bar,...
        obj.kap2bar] = initializeKinematics(obj.q0);
        
        % Dynamic terms
        obj.mdiag = massDiagonal(obj.nele, obj.enormbar, sec.h, sec.w, mat.rho);
        
        % Holds last iteration only (column vectors)
        obj.q = obj.q0;             % State vector
        obj.u = zeros(obj.ndof, 1); % Displacement vector
        obj.v = zeros(obj.ndof, 1); % Velocity vector
        
        % Stores all iterations (matrices)
        obj.Q = obj.q0;
        obj.U = obj.u;
        
        % Stores internal forces
        obj.Fi = zeros(obj.ndof, 1);
        obj.FI = zeros(obj.ndof, 1);
        
        % Energies (would grow as column vectors as time advances)
        obj.Es = 0;
        obj.Et = 0;
        obj.Eb = 0;
        obj.E = 0;
    end
    
end

methods (Static, Access = private)

    function validate(points, sec, mat)

        arguments
            points  (:,3) double
            sec     (1,1) Section
            mat     (1,1) Material
        end
        
    end

end

end