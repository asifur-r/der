classdef PlusArray
    % Creates an array of square base and edge connected (plus) arches

    properties (SetAccess = private)
        m   % Number of rows
        n   % Number of columns
        s   % Grid spacing
    end

    properties (Access = private)

        % Basic unit
        baseGrid SquareGrid

        % Sinusoid series
        seriesX SinusoidSeries
        seriesY SinusoidSeries

        % Coordinates
        points cell

    end

    methods

        function obj = PlusArray(m, n, line, sinusoid)
            % PlusArray class constructor

            % Checks
            assert(line.L == sinusoid.L, "Grid line unit and sinusoid unit must have same length")
            assert(mod(sinusoid.N, 2) == 1, "Sinusoid unit must have odd number of nodes")

            % Create base grid
            obj.baseGrid = SquareGrid(m, n, line);

            % Initialize public properties
            obj.m = m;
            obj.n = n;
            obj.s = obj.baseGrid.s;

            % Initialize private properties
            
            % Sinusoid series
            obj.seriesX = SinusoidSeries(sinusoid, n); 
            obj.seriesY = SinusoidSeries(sinusoid, m);

            % Generate array points
            obj.points = obj.generatePoints();
   
        end

        function base = Base(obj); base = obj.baseGrid; end

        function points = Points(obj); points = obj.points; end

        function [lines, nodes] = Peaks(obj, direction)
            % Returns arch peak nodes on the lines defined by the direction

            % Offset due to base lines
            baseOff = obj.baseGrid.CountLines();

            switch direction

                case 'X'
                    lines = (1:obj.m) + baseOff;
                    nodes = obj.seriesX.Peaks();
                    
                case 'Y'
                    lines = (1:obj.n) + (obj.m + baseOff); % Offset due to base lines and X dir arches
                    nodes = obj.seriesY.Peaks();

                otherwise; error("Direction must be either X or Y");

            end
            
        end

        function val = CountPeaks(obj); val = obj.m * obj.n; end

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

        function PlotNode(obj, i, k)
            % Highlight the i-th line and its k-th node
            
            obj.Plot(); hold on
            
            % Get grid points
            xyz = obj.points;
            
            % Check valid node index
            if i < 1 || i > length(xyz); error('Invalid line index.'); end
                
            % Extract line points
            pts = xyz{i};
            
            % Check valid line index
            if k < 1 || k > size(pts, 1); error('Invalid node index.'); end
                
            % Plot the whole line
            plot3(pts(:,1), pts(:,2), pts(:,3), 'g', 'LineWidth', 1.5);
            
            % Highlight the selected node
            plot3(pts(k,1), pts(k,2), pts(k,3), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
            
            % Label the node
            text(pts(k,1), pts(k,2), pts(k,3), sprintf('N%d', k), 'FontSize', 12, 'Color', 'r');
            
            title(sprintf('Node %d of Line %d', k, i));
            % hold off;
        end

    end

    methods (Access = private)

        function points = generatePoints(obj)
            % Returns grid points (base and sinusoid)
        
            % Generate sinusoid grid points

            % Get the sinusoid points in X and Y directions
            ptsX = obj.seriesX.Points();
            ptsY = Geometry.RotateByAngle(obj.seriesY.Points(), Geometry.Z_AXIS, pi/2);
        
            % Cell storage for the sinusoid grid
            gridX = cell(1, obj.m); gridY = cell(1, obj.n);
        
            % Generate the sinusoid grid points
            for i = 1:obj.m; gridX{i} = Geometry.TranslateByVector(ptsX, [0, (i-0.5)*obj.s, 0]); end
            for i = 1:obj.n; gridY{i} = Geometry.TranslateByVector(ptsY, [(i-0.5)*obj.s, 0, 0]); end
            
            % Get base grid points
            basePts = obj.baseGrid.Points();
        
            % Combine base grid and sinusoid grid points and round coordinates
            points = [basePts, gridX, gridY];
            points = cellfun(@(x) round(x, 6), points, 'UniformOutput', false);
        
        end
        
    end

end