classdef systemProperties
    % Defines class for system properties

    properties (SetAccess = private, GetAccess = public)
        nRods       % Number of rods
        
        dof         % System dof tags
        ndof        % Number of system dof
        ndofpr      % Vector containing number of dofs per rod

        resdof      % Restrained dof tags
        nresdof     % Number of restrained dof

        prddof      % Prescribed displacement dof tags
        nprddof     % Number of prescribed displacement dof

        frdof       % Free system dof tags
        nfrdof      % Number of free system dof
    end

    methods
        function obj = systemProperties(Rods, ana) % Constructor

            obj.nRods = length(Rods);

            [obj.dof, obj.ndof] = sysDofs(Rods);
            obj.ndofpr = ndofsPerRod(Rods);

            [obj.resdof, obj.nresdof] = resDofs(Rods);

            [obj.prddof, obj.nprddof] = presDispDofs(Rods);

            [obj.frdof, obj.nfrdof] = freeSysDofs(Rods, ana);
            
        end
    end
end

% function sys = systemProperties(Rods, ana)
%     % Defines system level variables in a struct
    
%     % Rods = struct containting main rods and linkers
%     % ana = analysis struct
    
%     % Number of rods
%     sys.nRods = length(Rods);

%     % Number of system dof and their tags
%     [sys.dof, sys.ndof] = sysDofs(Rods);

%     % Number of prescribed system dof
%     [sys.prddof, sys.nprddof] = presDispDofs(Rods);

%     % Number of restrained system dof
%     [sys.resdof, sys.nresdof] = resDofs(Rods);

%     % Vector containing number of dofs per rod
%     sys.ndofpr = ndofsPerRod(Rods);

%     % Number of free system dof
%     [sys.frdof, sys.nfrdof] = freeSysDofs(Rods, ana);

% end

