classdef Line
    % Line class for generating points along a straight line in X direction

    properties
        L   % Length of the line
        N   % Number of nodes
        a   % Offset of the second point from the first point
        b   % Offset of the N-1 th point from the N th point
    end

    methods
        function obj = Line(L, N, a, b)
            % Constructor for Line class
            obj.L = L;
            obj.N = N;
            obj.a = a;
            obj.b = b;
        end

        function mat = Points(obj)
            % Generates the points along the straight line

            % Adjust nodes and length for the linspace
            Ne = obj.N - 2;
            Le = obj.L - (obj.a + obj.b);

            % Generate the distribution
            vec = linspace(0, Le, Ne);

            % Construct the full vector by offsetting the vec by a
            % and by inserting points before and after it
            vec = [0 obj.a+vec obj.L];

            % Return
            mat = [vec' zeros(obj.N, 2)];
        end
    end

end