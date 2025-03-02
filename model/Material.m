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

% function str = MaterialE, nu, rho)
%     % Returns a struct of material
    
%     % E = Modulus of elasticity
%     % nu = Poisson's ratio
%     % rho = Material density

%     str = struct('E', E, 'nu', nu, 'rho', rho);
    
% end