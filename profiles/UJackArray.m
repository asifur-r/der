classdef UJackArray
    
    properties (SetAccess = private)
        m   % Number of rows
        n   % Number of columns
        s   % Grid spacing
    end
    
    properties (Access = private)
        
        % Basic units
        plusArray PlusArray
        timesArray TimesArray

        % Coordinates
        points cell

    end

    methods
        function obj = UJackArray(m, n, line, sinOrtho, sinDiag)
            
            obj.plusArray = PlusArray(m, n, line, sinOrtho);
            obj.timesArray = TimesArray(m, n, line, sinDiag);

            % Initialize public properties
            obj.m = m;
            obj.n = n;
            obj.s = obj.Base().s;

            % Generate grid points
            obj.points = obj.generatePoints();
            
        end

        function points = Points(obj); points = obj.points; end
        
        function base = Base(obj); base = obj.plusArray.Base(); end

        function [lines, nodes] = Peaks(obj, direction); [lines, nodes] = obj.plusArray.Peaks(direction); end

        function val = CountPeaks(obj); val = obj.plusArray.CountPeaks(); end

        function Plot(obj)
            % Plot the grid with node numbers and line numbers
        
            clf; hold on; axis equal; grid on;
            xlabel('X'); ylabel('Y'); zlabel('Z');
        
            % Get grid coordinates
            xyz = obj.points;
        
            % Iterate through all lines and plot
            for i = 1:length(xyz)

                pts = xyz{i}; 
                plot3(pts(:,1), pts(:,2), pts(:,3), 'bo');
                
            end
            view([-45 45]);
        end

    end

    methods (Access = private)

        function points = generatePoints(obj)

            % Get base and plus sinusoid points
            baseAndPlusPts = obj.plusArray.Points();

            % Get base and times sinusoid points
            baseAndTimesPts = obj.timesArray.Points();

            % Get the number of base lines
            count = obj.plusArray.Base().CountLines();

            % Extract times sinusoid points only
            timesPts = baseAndTimesPts(count+1:end);

            % Construct points for ujack
            points = [baseAndPlusPts, timesPts];
   
        end
    end

end