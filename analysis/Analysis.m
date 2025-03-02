classdef Analysis
    % Defines class for analysis parameters

    properties (SetAccess = private, GetAccess = public)
        type        % Analysis type: 'static' or 'dynamic'
        lam0        % Increment for NR, or first lambda for MGDM
        tf          % Final time t (for dynamic)
        dt          % Time step (for dynamic)
        solver      % Solver type ('nr' or 'mgdm')

        maxiter     % Maximum iterations
        tol         % Tolerance for convergence

        constraint  % Boundary specification: 'elimination' or 'penalty'
        penalty     % Penalty value (only for penalty constraint)
        

        integration % 'euler' or 'newmark'
        betaN       % newmark beta parameter

        damping     % Damping type: 'rayleigh' or 'vertices'
        alpha       % Rayleigh damping parameter
        beta        % Rayleigh damping parameter
        eta         % Viscous damping parameter
    end

    methods
        
        function obj = Analysis(varargin)

            % Valid function calls: analysis('static', lam0), analysis('dynamic', dt, tfinal)
            
            % Check analysis type
            assert(strcmp(varargin{1}, 'static') || strcmp(varargin{1}, 'dynamic'), ...
                "Supported analysis types are: 'static' and 'dynamic'.");

            % Initialize analysis type
            obj.type = varargin{1};
           
            switch obj.type
                case 'static'
                    assert(nargin == 2, "Static analysis requires lam0.");
                    obj.lam0 = varargin{2};

                case 'dynamic'
                    assert(nargin == 3, "Dynamic analysis requires tfinal and dt.");
                    obj.tf = varargin{2};
                    obj.dt = varargin{3};
            end

        end

        function obj = Integration(obj, type, varargin)
            % Set integration parameters
            assert(strcmp(type, 'euler') || strcmp(type, 'newmark'), ...
                "Supported integration types are: 'euler' and 'newmark'.");

            obj.integration = type;

            if strcmp(type, 'newmark')
                assert(nargin == 3, "Newmark integration requires a beta.");
                obj.betaN = varargin{1};
            end

        end

        function obj = Solver(obj, type)
            % Set solver type and lam0
            assert(strcmp(type, 'nr') || strcmp(type, 'mgdm'), ...
                "Supported solvers are: 'nr' and 'mgdm'.");

            obj.solver = type;
        end

        function obj = Convergence(obj, tol, maxiter)
            % Set convergence parameters

            obj.tol = tol;
            obj.maxiter = maxiter;
        end

        function obj = Constraint(obj, type, varargin)
            % Set constraint type and penalty

            assert(strcmp(type, 'elimination') || strcmp(type, 'penalty'), ...
                "Supported constraints are: 'elimination' or 'penalty'.");

            obj.constraint = type;

            if strcmp(type, 'penalty')
                assert(nargin == 3, "Penalty constraint requires penalty value.");
                obj.penalty = varargin{1};
            end
        end

        function obj = Damping(obj, type, varargin)
            % Set damping parameters

            assert(strcmp(type, 'rayleigh') || strcmp(type, 'vertices'), ...
                "Supported damping types are: 'rayleigh' and 'vertices'.");

            obj.damping = type;

            switch type
                case 'rayleigh'
                    assert(nargin == 4, "Rayleigh damping requires alpha and beta.");
                    obj.alpha = varargin{1};
                    obj.beta = varargin{2};

                case 'vertices'
                    assert(nargin == 3, "Vertices damping requires an eta.");
                    obj.eta = varargin{1};
                    
            end

        end

        function Validate(obj)
            % Validate the analysis parameters
            assert(~isempty(obj.type), "Analysis type must be set.");
            assert(~isempty(obj.solver), "Solver type must be set.");
            assert(~isempty(obj.lam0), "lam0 must be set.");
            assert(~isempty(obj.maxiter), "maxiter must be set.");
            assert(~isempty(obj.tol), "tol must be set.");
            assert(~isempty(obj.constraint), "constraint must be set.");

            if strcmp(obj.constraint, 'penalty') && isempty(obj.penalty)
                error("Penalty value is required for 'penalty' constraint.");
            end

            if strcmp(obj.type, 'dynamic') && (isempty(obj.tf) || isempty(obj.dt))
                error("tf and dt are required for 'dynamic' analysis.");
            end

            if ~isempty(obj.damping) && strcmp(obj.damping, 'rayleigh') && (isempty(obj.alphaR) || isempty(obj.betaR))
                error("alpha and beta are required for rayleigh damping.");
            end

            if ~isempty(obj.damping) && strcmp(obj.damping, 'vertices') && isempty(obj.eta)
                error("eta is required for vertices damping.");
            end

            assert(~isempty(obj.integration), "Integration type must be set.");
            if strcmp(obj.integration, 'newmark') && isempty(obj.betaN)
                error("beta is required for newmark integration scheme.");
            end
        end
    
    end

end