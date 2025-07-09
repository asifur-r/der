classdef SquareGrid
    % Creates a square base grid object of m by n size for plus, times and ujack array

    properties (SetAccess = private)
        m   % Number of rows
        n   % Number of columns
        s   % Grid spacing
    end

    properties (Access = private)

        % Series
        seriesX LineSeries
        seriesY LineSeries
        
        % Coordinates
        points cell
    end

    methods

        function obj = SquareGrid(m, n, line)
            % SquareGrid class constructor
            
            % Checks
            assert(mod(line.N, 2) == 1, "Grid line unit must have odd number of nodes")

            % Initialize public properties
            obj.m = m;
            obj.n = n;
            obj.s = line.L;

            % Initialize private properties
            obj.seriesX = LineSeries(line, n);
            obj.seriesY = LineSeries(line, m);
            obj.points = obj.generatePoints();
   
        end

        function points = Points(obj); points = obj.points; end
        
        function innerLines = InnerLines(obj)
            % Returns inner base line ids

            % Outer base lines
            outerLines = [1, obj.m+1, obj.m+2, obj.m+obj.n+2];

            % All base lines
            allLines = 1:outerLines(end);
  
            % Inner base lines
            innerLines = setdiff(allLines, outerLines);

        end

        function [lines, nodes] = Joints(obj, direction)
            % Returns base joint nodes on the lines defined by the direction

            switch direction

                case 'X'
                    lines = 1:obj.m+1;
                    nodes = obj.seriesX.Joints();
                    
                case 'Y'
                    lines = (1:obj.n+1) + (obj.m+1);
                    nodes = obj.seriesY.Joints();

                otherwise; error("Direction must be either X or Y");
                    
            end
            
        end

        function [lines, nodes] = JointsIn(obj, p, q, direction)

            % Valid square position check
            if p > obj.m; error('p must be less than or equal to %d', obj.m); end
            if q > obj.n; error('q must be less than or equal to %d', obj.n); end

            switch direction
                case 'X'
                    % Get line and base joints
                    ln = [p p+1];
                    jt = obj.seriesX.Joints();

                    % Arrange them counterclockwise
                    lines = [ln(1) ln(1) ln(2) ln(2)];
                    nodes = [jt(q) jt(q+1) jt(q+1) jt(q)];

                    % For m-th row, update the 3rd and 4th items in nodes because the line is flipped
                    if p == obj.m; jt = flip(jt); nodes([3 4]) = [jt(q+1) jt(q)]; end

                case 'Y'
                    % Get line and base joints
                    ln = [q q+1] + (obj.m+1);
                    jt = obj.seriesY.Joints();

                    % Arrange them counterclockwise
                    lines = [ln(1) ln(2) ln(2) ln(1)];
                    nodes = [jt(p) jt(p) jt(p+1) jt(p+1)];

                    % For first column, update the 1st and 4th items in nodes because the line is flipped
                    if q == 1; jt = flip(jt); nodes([1 4]) = [jt(p) jt(p+1)]; end

                otherwise; error("Direction must be either X or Y")
                    
            end
        end

        function val = CountJoints(obj); val = (obj.m+1) * (obj.n+1); end

        function val = CountLines(obj); val = (obj.m+1) + (obj.n+1); end

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
                
                % % Initialize node and line counters
                % nodeCounter = 1;

                % % Label each node with its number
                % for j = 1:size(pts, 1)
                %     text(pts(j, 1), pts(j, 2), pts(j, 3), sprintf('%d', nodeCounter), 'Color', 'k', 'FontSize', 6);
                %     nodeCounter = nodeCounter + 1;
                % end
        
                % Label the line at the beginning
                % text(pts(1, 1), pts(1, 2), pts(1, 3)+1, sprintf('Line %d', i), 'Color', 'r', 'FontSize', 12);
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

            % Returns base grid lines

            % Get the points
            linePtsX = obj.seriesX.Points();
            linePtsY = Geometry.RotateByAngle(obj.seriesY.Points(), Geometry.Z_AXIS, pi/2);

            % Cell storage for the grid
            gridX = cell(1, obj.m+1);
            gridY = cell(1, obj.n+1);

            % Generate the grid
            for i = 1:obj.m+1; gridX{i} = Geometry.TranslateByVector(linePtsX, [0, (i-1)*obj.s, 0]); end
            for i = 1:obj.n+1; gridY{i} = Geometry.TranslateByVector(linePtsY, [(i-1)*obj.s, 0, 0]); end

            % Flip two perimeter lines to make the outer grid a loop (required for positive linkers)
            gridX{end} = flip(gridX{end});
            gridY{1} = flip(gridY{1});

            % Combine all grid parts and round coordinates
            points = [gridX, gridY];
            points = cellfun(@(x) round(x, 6), points, 'UniformOutput', false);

        end

    end

end
