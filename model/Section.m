classdef Section
    % Defines class for section parameters

    properties
        w % Width
        h % Height
    end

    methods
        function obj = Section(w, h)
            
            obj.w = w;
            obj.h = h;
         
        end
    end
end