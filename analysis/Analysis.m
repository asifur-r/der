classdef Analysis
    % Defines class for analysis parameters

    properties %(SetAccess = private, GetAccess = public)
        type        % Analysis type: 'static' or 'dynamic'
        tf          % Final time t

        timeSteppingMode
        dt          % Time step
        dtMin
        dtMax

        solver      % Solver type ('nr' or 'mgdm')

        tol         % Tolerance for convergence
        maxResidual
        maxIteration

        constraint  % Boundary specification: 'elimination' or 'penalty'
        penalty     % Penalty value (only for penalty constraint)

        integration % 'euler' or 'newmark'
        velocityUpdate % 'euler' or 'newmark'
        inertialTerms %

        betaN       % newmark beta parameter

        damping     % Damping type: 'viscous'
        eta         % Viscous damping parameter

        timeSeries  % Time series array
        equalDof    % Multi point constraint
        
        isParallel  % Parallel processing logical
    end

    methods
        
        function obj = Analysis(type, tf)
            % Analysis constructor
                        
            % Check analysis type
            assert(strcmp(type, 'static') || strcmp(type, 'dynamic'), ...
                "Supported analysis types are: 'static' and 'dynamic'.");

            % Initialize analysis type
            obj.type = type;
            obj.tf = tf;

            % Default
            obj.isParallel = false;
        end

        function [action, obj] = UpdateTimeStep(obj, isConverged, numIterations)
            % Update time step based on convergence status
            
            % Constants
            DT_DECREASE_FACTOR = 0.90;
            DT_INCREASE_FACTOR = 1.10;
            FAST_CONVERGENCE_THRESHOLD = 10;
            
            action = 'continue';
            
            switch obj.timeSteppingMode

                case 'constant'
                    if ~isConverged; action = 'terminate'; end
                    
                case 'adaptive'

                    if ~isConverged
                        
                        newDt = obj.dt * DT_DECREASE_FACTOR;
                        if newDt < obj.dtMin
                            action = 'terminate';
                        else
                            obj.dt = newDt; action = 'retry';
                        end

                    elseif numIterations < FAST_CONVERGENCE_THRESHOLD

                        newDt = obj.dt * DT_INCREASE_FACTOR;
                        if newDt < obj.dtMax
                            obj.dt = newDt;
                        end
                    end
            end
        end

        function obj = TimeStep(obj, mode, dt, varargin)
            % Configure time step settings
            %
            % Usage:
            %   obj.TimeStep('constant', dt)
            %   obj.TimeStep('adaptive', dt, dtMin, dtMax)
        
            assert(strcmp(mode, 'constant') || strcmp(mode, 'adaptive'), ...
                "Supported time stepping modes are: 'constant' and 'adaptive'.");

            assert(isscalar(dt) && dt > 0, 'dt must be a positive scalar.');
        
            obj.timeSteppingMode = mode;
            obj.dt = dt;
        
            switch mode
                case 'adaptive'
                
                % Expecting dtMin and dtMax as extra inputs
                assert(numel(varargin) == 2, 'For adaptive mode, dtMin and dtMax must be provided.');
                obj.dtMin = varargin{1};
                obj.dtMax = varargin{2};

            case 'constant'

            assert(numel(varargin) == 0, 'For constant mode, dtMin and dtMax are not required.');

                % Clear out adaptive stepping fields
                obj.dtMin = [];
                obj.dtMax = [];
            end
        end
        

        function obj = TimeSeries(obj, seriesArray)
            % Set time series array
            obj.timeSeries = seriesArray;
        end

        function obj = Integration(obj, type, varargin)
            % Set integration parameters and store function handle

            obj.integration = type;

            switch type
                case 'euler'
                    obj.velocityUpdate = @velocityEuler;
                    obj.inertialTerms = @inertialEuler;

                case 'newmark'
                    assert(nargin == 3, "Newmark integration requires a beta.");
                    obj.betaN = varargin{1};
                    obj.velocityUpdate = @velocityrNewmark;
                    obj.inertialTerms = @inertialNewmark;

                otherwise
                    error('Unknown integrator type: "%s". Supported: "euler", "newmark".', type);
            end
        end

        function obj = Solver(obj, type)
            % Set solver type and lam0
            assert(strcmp(type, 'nr') || strcmp(type, 'mgdm'), ...
                "Supported solvers are: 'nr' and 'mgdm'.");

            obj.solver = type;
        end

        function obj = Convergence(obj, tol, maxResidual, maxIteration)
            % Set convergence parameters

            obj.tol = tol;
            obj.maxResidual = maxResidual;
            obj.maxIteration = maxIteration;
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

            % assert(strcmp(type, 'rayleigh') || strcmp(type, 'viscous'), ...
                % "Supported damping types are: 'rayleigh' and 'viscous'.");

            assert(strcmp(type, 'viscous'), "Supported damping types is: 'viscous'.");
            obj.damping = type;

            assert(nargin == 3, "Viscous damping requires an eta.");
            obj.eta = varargin{1};

        end

        function obj = EqualDof(obj, equalDof)
            % Attach a pre-defined EqualDof object
            assert(isa(equalDof, 'EqualDof'), "Input must be an EqualDof object."); 
            
            obj.equalDof = equalDof;
        end
    
        function obj = Parallel(obj, val)
            if val == true; obj.isParallel = val; end
        end

        function Validate(obj)
            % Validate the analysis parameters
            assert(~isempty(obj.type), "Analysis type must be set.");
            assert(~isempty(obj.integration), "Integration must be set.");
            assert(~isempty(obj.solver), "Solver type must be set.");
            assert(~isempty(obj.tf), "tf must be set.");
            assert(~isempty(obj.dt), "dt must be set.");
            assert(~isempty(obj.maxResidual), "maxResidual must be set.");
            assert(~isempty(obj.maxIteration), "maxIteration must be set.");
            assert(~isempty(obj.tol), "tol must be set.");
            assert(~isempty(obj.constraint), "constraint must be set.");

            if strcmp(obj.constraint, 'penalty') && isempty(obj.penalty)
                error("Penalty value is required for 'penalty' constraint.");
            end


            if strcmp(obj.integration, 'newmark') && isempty(obj.betaN)
                error("beta is required for newmark integration.");
            end
        end
    
    end

end