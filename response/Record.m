classdef Record
    % Defines record class for displacement and internal force response

    properties
        folder      % Folder to save files
        dispfile    % Displacement file name
        dispdofs    % Displacement dofs
        forcefile   % Force file name
        forcedofs   % Force dofs
    end

    methods

        function obj = Record(folderPath)
            % Record: Constructor for the record class.
            % Initializes recording settings.

            if ~ischar(folderPath); error('Folder path must be a string.'); end
            obj.folder = folderPath;

            % Initialize properties with default values
            obj.dispfile = [];
            obj.dispdofs = [];
            obj.forcefile = [];
            obj.forcedofs = [];

        end

        function obj = Force(obj, fileName, dofs)
            % Set the force file and dofs.
            obj.forcefile = validateFile(fileName, 'forcefile');
            obj.forcedofs = processDofs(dofs);
        end

        function obj = Displacement(obj, fileName, dofs)
            % Set the displacement file and dofs.
            obj.dispfile = validateFile(fileName, 'dispfile');
            obj.dispdofs = processDofs(dofs);
        end

        function str = Path(obj, type)
            switch type
                case 'disp';  str = fullfile(obj.folder, obj.dispfile);
                case 'force'; str = fullfile(obj.folder, obj.forcefile);
                otherwise; error("Path type should be 'disp' or 'force'");
            end
            
        end

    end

end
