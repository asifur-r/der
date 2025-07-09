classdef TimesArray2
    % Creates an array of square base and edge connected (plus) arches

    properties (SetAccess = private)
        m   % Number of rows
        n   % Number of columns
        s   % Grid spacing
    end

    properties (Access = private)

        % Basic unit
        line Line
        sinusoid Sinusoid

        baseGrid SquareGrid2

        % Coordinates
        points cell

    end

    methods

        function obj = TimesArray2(m, n, line, sinusoid)
            % TimesArray class constructor

            % Checks
            assert(abs(line.L*sqrt(2) - sinusoid.L) < 1e-6, "Sinusoid unit length must be of sqrt(2) times of base line unit length")
            assert(mod(sinusoid.N, 2) == 1, "Sinusoid must have odd number of nodes")
            
            % Create base grid
            obj.baseGrid = SquareGrid2(m, n, line);

            % Initialize public properties
            obj.m = m;
            obj.n = n;
            obj.s = obj.baseGrid.s;

            % Initialize private properties
            obj.line = line;
            obj.sinusoid = sinusoid;

            % Generate array points
            obj.points = obj.generatePoints();
   
        end

        function points = Points(obj); points = obj.points; end

        function base = Base(obj); base = obj.baseGrid; end
       
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
                case 'F'; lines = (1:numSq) + baseOff;
                case 'B'; lines = (1:numSq) + (numSq + baseOff); % Offset due to base lines and F dir arches

                otherwise; error("Direction must be either 'F' (/) or 'B' (\)");
            end
            
        end

        function val = CountPeaks(obj); val = obj.m * obj.n; end
        
        function val = CountLines(obj); val = obj.baseGrid.CountLines() + 2*obj.m*obj.n; end
            
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

        % For any grid m x n, rods are of the same size as the unit
        function [gridF, gridB] = archGrid(obj)
            % Returns arch grid lines in forward (/) and backward (\) direction

            % Get the sinusoid points
            ptsX = obj.sinusoid.Points();
            ptsF = Geometry.RotateByAngle(ptsX, Geometry.Z_AXIS, pi/4);
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