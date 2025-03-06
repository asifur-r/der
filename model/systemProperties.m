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

        timeSeries  % Array storing TimeSeries object
    end

    methods
        function obj = systemProperties(Rods, ana) % Constructor

            obj.nRods = length(Rods);

            [obj.dof, obj.ndof] = sysDofs(Rods);
            obj.ndofpr = ndofsPerRod(Rods);

            [obj.resdof, obj.nresdof] = resDofs(Rods);

            [obj.prddof, obj.nprddof] = presDispDofs(Rods);

            [obj.frdof, obj.nfrdof] = freeSysDofs(Rods, ana);

            % Add a default constant time series of zero value beforehand
            obj.timeSeries = [Series('constant', 0), ana.timeSeries];

        end
    end
end