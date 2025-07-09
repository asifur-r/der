classdef TimesArray
    % Creates an array of square base and edge connected (plus) arches

    properties (SetAccess = private)
        m   % Number of rows
        n   % Number of columns
        s   % Grid spacing
    end

    properties (Access = private)

        % Basic unit
        sinusoid Sinusoid
        baseGrid SquareGrid

        % Sinusoid series list
        seriesList cell

        % Center node of the basic sinusoid
        centerNode

        % Coordinates
        points cell

    end

    methods

        function obj = TimesArray(m, n, line, sinusoid)
            % TimesArray class constructor

            % Checks
            assert(abs(line.L*sqrt(2) - sinusoid.L) < 1e-6, "Sinusoid unit length must be of sqrt(2) times of base line unit length")
            assert(mod(sinusoid.N, 2) == 1, "Sinusoid must have odd number of nodes")
            
            % Create base grid
            obj.baseGrid = SquareGrid(m, n, line);

            % Initialize public properties
            obj.m = m;
            obj.n = n;
            obj.s = obj.baseGrid.s;

            % Initialize private properties
            obj.sinusoid = sinusoid;

            % Generate sinusoid series in decending length order
            obj.seriesList = flip(arrayfun(@(i) SinusoidSeries(sinusoid, i), 1:obj.m, 'UniformOutput', false));

            % Generate array points
            obj.points = obj.generatePoints();
   
        end

        function points = Points(obj); points = obj.points; end

        function base = Base(obj); base = obj.baseGrid; end

        function val = CountLines(obj); val = obj.baseGrid.CountLines() + 2*obj.m*obj.n; end

        function [lines, nodes] = Peaks(obj, direction)
            % Returns arch peak nodes on the lines defined by the direction

            % Get the center node
            nodes = ceil(obj.sinusoid.N / 2);

            % Number of squares in the grid
            numSq = obj.CountPeaks();

            % Offset due to base lines
            baseOff = obj.baseGrid.CountLines();

            switch direction
                case 'F'; lines = (1:numSq) + baseOff;
                case 'B'; lines = (1:numSq) + (numSq + baseOff); % Offset due to base lines and F dir arches

                otherwise; error("Direction must be either 'F' (/) or 'B' (\)");
            end
            
        end

        % function [lines, nodes] = Peaks(obj, direction)
        %     % Returns arch peak nodes and the lines based on direction

        %     % Insert main diagonal nodes
        %     nodes{1} = obj.seriesList{1}.Peaks();

        %     % Insert off-diagonal nodes
        %     for i = 2:obj.m; pk = obj.seriesList{i}.Peaks(); nodes = [nodes, pk, pk]; end
            
        %     % Number of diagonals in each direction
        %     numDiag = 2 * obj.m - 1;

        %     % Offset due to base lines
        %     baseOff = obj.baseGrid.CountLines();

        %     switch direction
        %         case 'F'; lines = (1:numDiag) + baseOff;
        %         case 'B'; lines = (1:numDiag) + (numDiag + baseOff); % Offset due to base lines and F dir arches

        %         otherwise; error("Direction must be either 'F' (/) or 'B' (\)");
        %     end
            
        % end

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

        % function archLines = ArchLines(obj)
        
        %     % Total lines in the system
        %     totalN = length(obj.Points());

        %     % Number of base lines
        %     baseN = obj.baseGrid.CountLines();

        %     % Number of arch lines
        %     archN = totalN - baseN;
            
        %     % Genereta index of arch lines by adding base line offset
        %     archLines = (1:archN) + baseN;
            
        % end

    end

    methods (Access = private)

        function points = generatePoints(obj)

            % Get grid lines for the base and arch
            basePts = obj.baseGrid.Points();
            [archGridF, archGridB] = obj.archGrid();

            % Combine base grid and arch grid parts and round coordinates
            points = [basePts, archGridF, archGridB];
            points = cellfun(@(x) round(x, 6), points, 'UniformOutput', false);

        end

        % function [gridF, gridB] = archGrid(obj)
        %     % Returns arch grid lines in forward (/) and backward (\) direction
        
        %     % Ensure grid is square
        %     assert(obj.m == obj.n, 'Grid size m=%d and n=%d must be equal', obj.m, obj.n);
        
        %     % Number of diagonals in each direction
        %     numDiag = 2 * obj.m - 1;
        
        %     % Initialize cell arrays for grid lines
        %     gridF = cell(1, numDiag); gridB = cell(1, numDiag);
        
        %     for i = 1:obj.m
        %         % Get the sinusoid for this iteration
        %         arch = obj.seriesList{i};

        %         % Rotate by 45 degree for the forward, rotate by 135 and translate for the backward
        %         rotF = Geometry.RotateByAngle(arch.Points(), Geometry.Z_AXIS, pi/4);
        %         rotB = Geometry.RotateByAngle(arch.Points(), Geometry.Z_AXIS, 3*pi/4);
        %         transB = Geometry.TranslateByVector(rotB, [obj.s * obj.m, 0, 0]);
        
        %         if i == 1 % Main diagonal
        %             gridF{1} = rotF; gridB{1} = transB;
        %             ctrF = 2; ctrB = 2;
                
        %         else % Offset diagonals
        %             % Translation amount
        %             t = (i - 1) * obj.s;

        %             % Assign forward and backward 
        %             gridF{ctrF}   = Geometry.TranslateByVector(rotF,   [ t, 0, 0]);
        %             gridF{ctrF+1} = Geometry.TranslateByVector(rotF,   [ 0, t, 0]);
        %             gridB{ctrB}   = Geometry.TranslateByVector(transB, [-t, 0, 0]);
        %             gridB{ctrB+1} = Geometry.TranslateByVector(transB, [ 0, t, 0]);

        %             % Increase both counters
        %             ctrF = ctrF + 2; ctrB = ctrB + 2;
        %         end
        %     end
        % end

        % For any grid m x n, rods are of the same size as the unit
        function [gridF, gridB] = archGrid(obj)
            % Returns arch grid lines in forward (/) and backward (\) direction

            % Get the sinusoid points
            ptsX = obj.sinusoid.Points();
            ptsF = Geometry.RotateByAngle(ptsX, Geometry.Z_AXIS,   pi/4);
            ptsB = Geometry.TranslateByVector(Geometry.RotateByAngle(ptsX, Geometry.Z_AXIS, 3*pi/4), [obj.s 0 0]);

            % Cell storage for the grid
            numSq = obj.CountPeaks();
            gridF = cell(1, numSq);
            gridB = cell(1, numSq);

            ctr = 1;

            % Generate the grid
            for i = 1:obj.m
            for j = 1:obj.n

                % Translation vector
                transVec = [(j-1)*obj.s, (i-1)*obj.s, 0];

                gridF{ctr} = Geometry.TranslateByVector(ptsF, transVec);
                gridB{ctr} = Geometry.TranslateByVector(ptsB, transVec);

                ctr = ctr + 1;
            end
            end

        end
        
    end

end
