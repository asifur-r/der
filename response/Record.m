classdef Record
    % Define record class for displacement and internal force response

    properties

        dispfile    % Displacement file name
        dispdofs    % Displacement dofs
        forcefile   % Force file name
        forcedofs   % Force dofs

    end

    methods

        function obj = Record(varargin)
            % record: Constructor for the record class.
            % Initializes recording settings.

            % Initialize properties with default values
            obj.dispfile = [];
            obj.dispdofs = [];
            obj.forcefile = [];
            obj.forcedofs = [];

            % Number of argument
            numArgs = length(varargin);

            % Check for pairs
            if mod(numArgs, 2) ~= 0; error('Input arguments must be in key-value pairs.'); end

            % Parse input arguments    
            for i = 1:2:numArgs

                key = varargin{i};
                val = varargin{i+1};

                switch lower(key)
                    case 'dispfile'; obj.dispfile = validateFile(val, 'dispfile');
                    case 'dispdofs'; obj.dispdofs = processDofs(val, 'disp');

                    case 'forcefile'; obj.forcefile = validateFile(val, 'forcefile');
                    case 'forcedofs'; obj.forcedofs = processDofs(val, 'force');

                    otherwise; error(['Unknown key: ', key]);
                end
            end

            % Checks if file and dofs are provided in pairs
            assert((~isempty(obj.dispfile) && ~isempty(obj.dispdofs)) || (isempty(obj.dispfile) && isempty(obj.dispdofs)), 'dispfile and dispdofs must be provided in pairs.');
            assert((~isempty(obj.forcefile) && ~isempty(obj.forcedofs)) || (isempty(obj.forcefile) && isempty(obj.forcedofs)), 'forcefile and forcedofs must be provided in pairs.');
        end
        
    end

end


% function str = record(varargin)

%     % Initialize struct with default field values
%     str = struct();

%     str.dispfile = [];
%     str.dispdofs = [];
    
%     str.forcefile = [];
%     str.forcedofs = [];
    
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
            
%             case 'dispfile'; str.dispfile = validateFile(val, 'dispfile');
%             case 'dispdofs'; str.dispdofs = processDofs(val, 'disp');

%             case 'forcefile'; str.forcefile = validateFile(val, 'forcefile');
%             case 'forcedofs'; str.forcedofs = processDofs(val, 'force');

%             otherwise; error(['Unknown key: ', key]);
        
%         end
%     end

%     % Checks if file and dofs are provided in pairs
%     assert( (~isempty(str.dispfile) && ~isempty(str.dispdofs)) || (isempty(str.dispfile) && isempty(str.dispdofs)), 'dispfile and dispdofs must be provided in pairs.');
%     assert( (~isempty(str.forcefile) && ~isempty(str.forcedofs)) || (isempty(str.forcefile) && isempty(str.forcedofs)), 'forcefile and forcedofs must be provided in pairs.');


% end