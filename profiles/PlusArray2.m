classdef PlusArray2
    % Creates an array of square base and edge connected (plus) arches

    properties (SetAccess = private)
        m   % Number of rows
        n   % Number of columns
        s   % Grid spacing
    end

    properties (Access = private)

        % Sinusoid
        sinusoid Sinusoid

        % Base grid
        baseGrid SquareGrid2
        
        % Coordinates
        points cell

    end

    methods

        function obj = PlusArray2(m, n, line, sinusoid)
            % PlusArray class constructor

            % Checks
            assert(line.L == sinusoid.L, "Grid line unit and sinusoid unit must have same length")
            assert(mod(sinusoid.N, 2) == 1, "Sinusoid unit must have odd number of nodes")

            % Create base grid
            obj.baseGrid = SquareGrid2(m, n, line);

            % Initialize public properties
            obj.m = m;
            obj.n = n;
            obj.s = obj.baseGrid.s;

            % Initialize private properties
            
            % Sinusoid
            obj.sinusoid = sinusoid; 

            % Generate array points
            obj.points = obj.generatePoints();
   
        end

        function base = Base(obj); base = obj.baseGrid; end

        function points = Points(obj); points = obj.points; end

        function [lines, nodes] = Peaks(obj, direction)
            % Returns arch peak nodes on the lines defined by the direction

            % Number of squares in the grid
            numSq = obj.CountPeaks();

            % Get the center node and construct nodes vector
            cnode = ceil(obj.sinusoid.N / 2);
            nodes = ones(1, numSq) * cnode;

            % Offset due to base lines
            baseOff = obj.baseGrid.CountLines();

            switch direction
                case 'X'; lines = (1:numSq) + baseOff;
                case 'Y'; lines = (1:numSq) + (numSq + baseOff); % Offset due to base lines and F dir arches

                otherwise; error("Direction must be either 'X' or 'Y'");
            end
            
        end

        function val = CountPeaks(obj); val = obj.m * obj.n; end

        function val = CountLines(obj); val = obj.baseGrid.CountLines() + 2*obj.m*obj.n; end
            
    end

    methods (Access = private)

        function points = generatePoints(obj)

            % Get grid lines for the base and arch
            basePts = obj.baseGrid.Points();
            [archGridX, archGridY] = obj.archGrid();

            % Combine base grid and arch grid parts and round coordinates
            points = [basePts, archGridX, archGridY];
            points = cellfun(@(x) round(x, 6), points, 'UniformOutput', false);

        end

        function [gridX, gridY] = archGrid(obj)
            % Returns arch grid lines

            % Get the unit sinusoid points in X and Y dir
            ptsX = obj.sinusoid.Points();
            ptsY = Geometry.RotateByAngle(ptsX, Geometry.Z_AXIS, pi/2);

            % Generate grid in X direction
            ctr = 1;
            for i = 1:obj.m
            for j = 1:obj.n
                gridX{ctr} = Geometry.TranslateByVector(ptsX, [j-1, (i-1)+0.5, 0]*obj.s); ctr = ctr + 1;
            end
            end
            
            % Generate grid in Y direction
            ctr = 1;
            for i = 1:obj.n
            for j = 1:obj.m
                gridY{ctr} = Geometry.TranslateByVector(ptsY, [(i-1)+0.5, j-1, 0]*obj.s); ctr = ctr + 1;
            end 
            end

        end

    end

end