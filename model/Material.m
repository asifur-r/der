classdef Material
    % Defines class for material properties

    properties
        E   % Modulus of elasticity
        nu  % Poisson's ratio
        rho % Material density
    end

    methods
        function obj = Material(E, nu, rho)
            
            obj.E = E;
            obj.nu = nu;
            obj.rho = rho;
         
        end
    end
end