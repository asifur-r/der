classdef Visual

    properties

        deformed    % For deformed shape plot
        triad       % For triads in on the deformed shape
        nodetags    % For node tags
        dofs        % Plot dofs matrix
        variable    % 'forcedisp' or 'timehistory'

    end

    methods

        function obj = Visual(varargin)
            % Initializes visualization settings.

            % Initialize properties with default values
            obj.deformed = false;
            obj.triad = false;
            obj.nodetags = false;
            obj.dofs = [];
            obj.variable = 'forcedisp';
            
            % Number of arguments
            numArgs = length(varargin);

            % Check for key-value pairs
            if mod(numArgs, 2) ~= 0; error('Input arguments must be in key-value pairs.'); end

            % Parse input arguments
            for i = 1:2:numArgs

                key = varargin{i};
                val = varargin{i+1};

                switch lower(key)
                    case 'deformed', obj.deformed = val;
                    case 'triad', obj.triad = val;
                    case 'node', obj.nodetags = val;
                    case 'dofs', obj.dofs = processDofs(val);

                    case 'variable'
                        assert(strcmp(val, 'forcedisp') || strcmp(val, 'timehistory'), "Visual property 'variable' must be either 'forcedisp' or 'timehistory'")
                        obj.variable = val;

                    otherwise, error(['Unknown key: ', key]);
                end
            end

        end

    end

end

% function str = visual(varargin)
%     % Returns struct containing what to display in deformed plots during analysis

%     % Initialize struct with default field values
%     str = struct();
%     str.deformed = false; % For deformed shape plot
%     str.triad = false; % For triads in on the deformed shape
%     str.nodetags = false; % For node tags

%     str.dispdofs = []; % Displacement plot dofs
%     str.forcedofs = [];% Force plot dofs
    
%     % Parse input arguments
%     numArgs = length(varargin); 
    
%     % Check for pairs
%     if mod(numArgs, 2) ~= 0; error('Input arguments must be in key-value pairs.'); end

%     % Define each key-value one by one
%     for i = 1:2:numArgs
        
%         % Pick current key-value
%         key = varargin{i};
%         val = varargin{i+1};

%         % Match and assign
%         switch lower(key) % Use lower() for case-insensitive matching
            
%             case 'deformed'; str.deformed = val;
%             case 'triad'; str.triad = val;
%             case 'node'; str.nodetags = val;
%             case 'disp'; str.dispdofs = processDofs(val, 'disp');
%             case 'force'; str.forcedofs = processDofs(val, 'force');

%             otherwise; error(['Unknown key: ', key]);
%         end
%     end

% end