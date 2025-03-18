classdef Monitor
    
    properties
        iter    % For displaying per iteration
        step    % For displaying per step
    end

    methods

        function obj = Monitor(varargin)
            % monitor: Constructor for the monitor class.
            % Initializes monitoring settings.

            % Initialize properties with default field values
            obj.iter = [];
            obj.step = [];

            % Parse input arguments
            numArgs = length(varargin);

            % Check for pairs
            if mod(numArgs, 2) ~= 0, error('Input arguments must be in key-value pairs.'); end

            % Define each key-value one by one
            for i = 1:2:numArgs
                
                key = varargin{i};
                val = varargin{i+1};

                % Match and assign
                switch lower(key)
                    case 'iter', obj.iter = val;
                    case 'step', obj.step = val;

                    otherwise, error(['Unknown key: ', key]);
                end
            end
        end
        
    end

end
