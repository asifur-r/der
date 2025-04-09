classdef PlusGrid
    % Creates an array of square base and edge connected (plus) arches

    properties
        
        m  % Number of grid rows
        n  % Number of grid columns
        spacing % Grid spacing

        % Basic segments
        line Line
        sinusoid Sinusoid

        points cell % Coordinates

        % Series
        lineSeriesX LineSeries
        lineSeriesY LineSeries

        sinSeriesX SinusoidSeries
        sinSeriesY SinusoidSeries
        
    end

    methods

        function obj = PlusGrid(m, n, line, sinusoid)
            % PlusGrid class constructor

            % Checks
            assert(line.L == sinusoid.L, "Line and the sinusoid must have same length")
            assert(mod(line.N, 2) == 1, "Line must have odd number of nodes")
            assert(mod(sinusoid.N, 2) == 1, "Sinusoid must have odd number of nodes")
            
            % Initialize public properties
            obj.m = m;
            obj.n = n;
            obj.spacing = line.L;

            obj.line = line;
            obj.sinusoid = sinusoid;

            % Initialize private properties

            % Generate the base and sin series
            obj.lineSeriesX = LineSeries(line, n);
            obj.lineSeriesY = LineSeries(line, m);
            obj.sinSeriesX = SinusoidSeries(sinusoid, n);
            obj.sinSeriesY = SinusoidSeries(sinusoid, m);

            % Generate grid points
            obj.points = obj.generatePoints();
   
        end

        function points = Points(obj); points = obj.points; end
            
        function innerLines = InnerBaseLines(obj)
            % Returns inner base line ids

            % Outer base lines
            outerLines = [1, obj.m+1, obj.m+2, obj.m+obj.n+2];

            % All base lines
            allLines = 1:outerLines(end);

            % Inner base lines
            innerLines = setdiff(allLines, outerLines);

        end

        function [lines, nodes] = ArchPeaks(obj, direction)
            % Returns arch peak nodes on the lines defined by the direction

            % Offset due to base lines
            baseOff = obj.m + obj.n + 2;

            switch direction

                case 'X'
                    lines = (1:obj.m) + baseOff;
                    nodes = obj.sinSeriesX.Peaks();
                    
                case 'Y'
                    lines = (1:obj.n) + (obj.m + baseOff);
                    nodes = obj.sinSeriesY.Peaks();

                otherwise; error("Direction must be either X or Y");

            end
            
        end

        function [lines, nodes] = BaseJoints(obj, direction)
            % Returns base joint nodes on the lines defined by the direction

            switch direction

                case 'X'
                    lines = 1:obj.m+1;
                    nodes = obj.lineSeriesX.Joints();
                    
                case 'Y'
                    lines = (1:obj.n+1) + (obj.m+1);
                    nodes = obj.lineSeriesY.Joints();

                otherwise; error("Direction must be either X or Y");
                    
            end
            
        end

        function PlotGrid(obj)
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
            
            obj.PlotGrid(); hold on
            
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

            % Get grid lines for the base and arch
            [baseGridX, baseGridY] = obj.baseGrid();
            [archGridX, archGridY] = obj.archGrid();

            % Combine all grid parts and round coordinates
            points = [baseGridX, baseGridY, archGridX, archGridY];
            points = cellfun(@(x) round(x, 6), points, 'UniformOutput', false);

        end

        function [gridX, gridY] = baseGrid(obj)
            % Returns base grid lines

            % Get the points
            linePtsX = obj.lineSeriesX.Points();
            linePtsY = Geometry.RotateByAngle(obj.lineSeriesY.Points(), Geometry.Z_AXIS, pi/2);

            % Cell storage for the grid
            gridX = cell(1, obj.m+1);
            gridY = cell(1, obj.n+1);

            % Generate the grid
            for i = 1:obj.m+1; gridX{i} = Geometry.TranslateByVector(linePtsX, [0, (i-1)*obj.spacing, 0]); end
            for i = 1:obj.n+1; gridY{i} = Geometry.TranslateByVector(linePtsY, [(i-1)*obj.spacing, 0, 0]); end

            % Flip two perimeter lines to make the outer grid a loop (required for positive linkers)
            gridX{end} = flip(gridX{end});
            gridY{1} = flip(gridY{1});

        end

        function [gridX, gridY] = archGrid(obj)
            % Returns arch grid lines

            % Get the points
            sinPtsX = obj.sinSeriesX.Points();
            sinPtsY = Geometry.RotateByAngle(obj.sinSeriesY.Points(), Geometry.Z_AXIS, pi/2);

            % Cell storage for the grid
            gridX = cell(1, obj.m);
            gridY = cell(1, obj.n);

            % Generate the grid
            for i = 1:obj.m; gridX{i} = Geometry.TranslateByVector(sinPtsX, [0, (i-0.5)*obj.spacing, 0]); end
            for i = 1:obj.n; gridY{i} = Geometry.TranslateByVector(sinPtsY, [(i-0.5)*obj.spacing, 0, 0]); end

        end
        
    end

end

% function [lines, nodes] = BaseIntersection(obj, p, q)
%     % Returns the x parallel intersecting lines and the nodes from base in grid unit (p, q)

%     assert(p <= obj.m && q <= obj.n, "Grid unit (%d, %d) doesn't exist", p, q)

%     % X parallel lines
%     xLines = [p, p+1];
    
%     % Y parallel lines (shifted by m+1)
%     yLines = [q, q+1] + (obj.m+1);

%     % Get the line points
%     xPts = obj.points(xLines);
%     yPts = obj.points(yLines);

%     % Find intersection nodes
%     c = zeros(2, 2);  % rows: x lines, cols: y lines
    
%     for i = 1:2
%     for j = 1:2
        
%         % Find the intersection node from xLines
%         [~, xRow, ~] = intersect(xPts{i}, yPts{j}, 'rows');
        
%         % Make sure there is only one intersection
%         assert(isscalar(xRow));

%         % Store the current node
%         c(i, j) = xRow;
%     end
%     end
    
%     % Nodes arranged counter-clockwise
%     nodes = [c(1,1) c(1,2) c(2,2) c(2,1)];
%     lines = [xLines(1) xLines(1) xLines(2) xLines(2)];

%     % for i=1:length(nodes); obj.PlotNode(lines(i), nodes(i)); end            
% end

% function [line, node] = ArchIntersection(obj, p, q)
%     % Returns the x parallel intersecting arch lines in grid unit (p, q)

%     assert(p <= obj.m && q <= obj.n, "Grid unit (%d, %d) doesn't exist", p, q)

%     % Offset due to base lines
%     baseOff = obj.m+1 + obj.n+1;

%     % X parallel line
%     xLine = p + baseOff;
    
%     % Y parallel line
%     yLine = q + (obj.m) + baseOff;

%     % Extract nodes of the current y-line and x-line
%     xPts = obj.points{xLine};
%     yPts = obj.points{yLine};
    
%     % Find the intersection node index from x lines
%     [~, xRow, ~] = intersect(xPts, yPts, 'rows');
    
%     % Make sure there is only one intersection
%     assert(isscalar(xRow));
    
%     % Return
%     node = xRow; line = xLine;

%     % obj.PlotNode(line, node);
% end