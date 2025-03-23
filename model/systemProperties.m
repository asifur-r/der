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

        function obj = systemProperties(Rods, ana, sol) % Constructor

            % Time independant properties
            obj.nRods = length(Rods);
            [obj.dof, obj.ndof] = sysDofs(Rods);
            obj.ndofpr = ndofsPerRod(Rods);
            
            % Time dependant properties
            [obj.resdof, obj.nresdof] = resDofs(sol.Res);
            [obj.prddof, obj.nprddof] = presDispDofs(sol.Prdisp);
            [obj.frdof, obj.nfrdof] = freeSysDofs(sol.Res, sol.Prdisp, ana);

        end
        
    end
end

