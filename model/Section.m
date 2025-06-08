classdef Section
    % Defines class for section parameters

    properties
        w % Width
        h % Height
        Jmod % Torsional stiffness modifier
    end

    methods
        function obj = Section(w, h, Jmod)
            
            obj.w = w;
            obj.h = h;
            obj.Jmod = Jmod;

        end
    end
end