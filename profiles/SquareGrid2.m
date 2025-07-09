classdef SquareGrid2
    % Creates a square base grid object of m by n size for plus, times and ujack array

    properties (SetAccess = private)
        m   % Number of rows
        n   % Number of columns
        s   % Grid spacing
    end

    properties (Access = private)

        % Segment
        line Line
        
        % Coordinates
        points cell
    end

    methods

        function obj = SquareGrid2(m, n, line)
            % SquareGrid2 class constructor
            
            % Checks
            assert(mod(line.N, 2) == 1, "Grid line unit must have odd number of nodes")

            % Initialize public properties
            obj.m = m;
            obj.n = n;
            obj.s = line.L;

            % Initialize private properties
            obj.line = line;
            obj.points = obj.generatePoints();
   
        end

        function points = Points(obj); points = obj.points; end

        function val = CountLines(obj); val = 2*obj.m*obj.n + obj.m + obj.n; end

        function val = CountJoints(obj); val = (obj.m+1) * (obj.n+1); end

        function innerLines = InnerLines(obj)
            % Returns inner base line ids

            m = obj.m;
            n = obj.n;

            % Get line ids
            linesX = obj.getLines('X');
            linesY = obj.getLines('Y');
            
            % Outer lines
            outerLinesX = [linesX(1:n) linesX(end+1-n:end)]; % Pick n items from linesX from both ends
            outerLinesY = [linesY(1:m) linesY(end+1-m:end)]; % Pick m items from linesY from both ends
            outerLines = [outerLinesX outerLinesY];

            % All base lines
            allLines = 1:obj.CountLines();

            % Inner base lines
            innerLines = setdiff(allLines, outerLines);

        end

        function [lines, nodes] = Joints(obj)
            % Returns lines ids in X direction and joint ids

            m = obj.m;
            n = obj.n;
        
            lines = [];
            ctr = 0;

            % Prepare lines
            for i = 1:m; lines = [lines; ctr+(1:n), ctr+n]; ctr = ctr + n; end
            lines = [lines; lines(end)+1, lines(end)+(1:n)];
            lines = lines';
            lines = [lines(:)]';
            
            % Prepare nodes
            tmp = [ones(obj.n, obj.m+1); ones(1, obj.m+1) * obj.line.N];
            tmp = [tmp(:,1:end-1) flip(tmp(:,end))];
            nodes = [tmp(:)]';

        end

        function [lines, nodes] = JointsIn(obj, p, q)

            % Valid square position check
            if p > obj.m; error('p must be less than or equal to %d', obj.m); end
            if q > obj.n; error('q must be less than or equal to %d', obj.n); end

            % Get all lines and nodes
            [ln, nd] = obj.Joints();

            % Get index to extract
            ids = obj.getSquareIndices(p, q);
            
            % Extract the corrensponding items
            lines = ln(ids);
            nodes = nd(ids);

        end

    end

    methods (Access = private)

        function idx = getSquareIndices(obj, p, q)
        % Returns the four node indices of the (p,q)-th square in an m-by-n grid
        % p = row index (1 to m), q = column index (1 to n)

            % Number of nodes per row
            nodesPerRow = obj.n + 1;

            % Bottom-left corner index
            bottomLeft = (p - 1) * nodesPerRow + q;

            % Compute the rest
            bottomRight = bottomLeft + 1;
            topLeft = bottomLeft + nodesPerRow;
            topRight = topLeft + 1;

            % Return as vector
            idx = [bottomLeft, bottomRight, topLeft, topRight];
        end

        function lines = getLines(obj, dir)
            % Returns inner base line ids on X or Y direction

            numLinesX = (obj.m+1) * obj.n;
            numLinesY = obj.m * (obj.n+1);

            switch dir

                case 'X'; lines = 1:numLinesX;
                case 'Y'; lines = (1:numLinesY) + numLinesX; % numLinesX is equal to offset
                otherwise; error("Direction must be either X or Y");
                
            end

        end

        function points = generatePoints(obj)

            % Returns base grid lines

            % Get the points
            linePtsX = obj.line.Points();
            linePtsY = Geometry.RotateByAngle(linePtsX, Geometry.Z_AXIS, pi/2);

            % Generate grid in X direction
            ctr = 1;
            for i = 1:obj.m+1
            for j = 1:obj.n
                gridX{ctr} = Geometry.TranslateByVector(linePtsX, [j-1, i-1, 0]*obj.s); ctr = ctr + 1;
            end
            end
            
            % Generate grid in Y direction
            ctr = 1;
            for i = 1:obj.n+1
            for j = 1:obj.m
                gridY{ctr} = Geometry.TranslateByVector(linePtsY, [i-1, j-1, 0]*obj.s); ctr = ctr + 1;
            end 
            end

            % Flip perimeter lines to make the outer grid a loop (required for positive linkers)
            for i = 1:obj.n; gridX{end-i+1} = flip(gridX{end-i+1}); end % Flips last n lines
            for i = 1:obj.m; gridY{i} = flip(gridY{i}); end % Flips first m lines

            % Combine all grid parts and round coordinates
            points = [gridX, gridY];
            points = cellfun(@(x) round(x, 6), points, 'UniformOutput', false);
            
        end


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
                
                % Initialize node and line counters
                nodeCounter = 1;

                % Label each node with its number
                for j = 1:size(pts, 1)
                    text(pts(j, 1), pts(j, 2), pts(j, 3), sprintf('%d', nodeCounter), 'Color', 'k', 'FontSize', 6);
                    nodeCounter = nodeCounter + 1;
                end
        
                % Label the line at the beginning
                text(pts(1, 1), pts(1, 2), pts(1, 3)+1, sprintf('Line %d', i), 'Color', 'r', 'FontSize', 12);
            end
            view([-45 45]);
        end

    end
end