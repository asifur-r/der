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

% function str = Section(w, h)
%     % Returns a struct of section

%     % Rectangular section for now

%     % w = width
%     % h = height

%     str = struct('w', w, 'h', h);
    
% end