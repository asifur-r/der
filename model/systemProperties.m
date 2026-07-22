classdef systemProperties
    % Defines class for system properties

    properties (SetAccess = private, GetAccess = public)

        ndof        % Number of system dof
        ndofpr      % Vector containing number of dofs per rod

        prddof      % Prescribed displacement dof tags
        nprddof     % Number of prescribed displacement dof

        frdof       % Free system dof tags
        nfrdof      % Number of free system dof

    end

    methods

        function obj = systemProperties(Rods, ana, sol) 
            % Class constructor

            % Time independant properties
            obj.ndofpr = ndofsPerRod(Rods);
            obj.ndof = sysDofs(Rods);
            
            % Time dependant properties
            
            [obj.prddof, obj.nprddof] = presDispDofs(sol.Prdisp);
            [obj.frdof,  obj.nfrdof ] = freeSysDofs(sol.Res, sol.Prdisp, ana, obj.ndof);

        end
        
    end
end

