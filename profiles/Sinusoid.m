classdef Sinusoid
    % Sinusoid class for generating a half or full sinusoid curve

    properties
        L   % Half base length
        H   % Height
        N   % Number of nodes
        a   % Offset of the second point from the first point
        b   % Flat length before the actual sinusoid
        c   % Offset of the N-1 th point from the N th point (peak)
        isFull % Logical if the sinusoid is full or half
    end

    methods
        function obj = Sinusoid(L, H, N, a, b, c, isFull)
            % Constructor for Sinusoid class
            obj.L = L;
            obj.H = H;
            obj.N = N;
            obj.a = a;
            obj.b = b;
            obj.c = c;
            obj.isFull = isFull;
        end

        function mat = Points(obj)

            if obj.isFull; mat = fullSinusoid(obj); else; mat = halfSinusoid(obj); end

        end
    end

    methods (Access = private)
        
        function mat = halfSinusoid(obj)
            % Generates the points along the half sinusoid

            % Number of points in flat region before sinusoid
            Nb = 5;

            % Remaining nodes for the sinusoid
            Ns = obj.N - Nb - 1;
            
            % Compute the effective sinusoidal base length (excluding flat parts)
            Ls = obj.L - (obj.a + obj.b + obj.c);
            
            % Generate sinusoid x-coordinates within the effective length
            xs = linspace(0, Ls, Ns);
            
            % Compute sinusoid z-coordinates
            zs = (obj.H / 2) * (1 + sin(pi * (xs / Ls - 0.5)));
            
            % Construct full x-coordinates with flat regions
            xb = linspace(0, obj.b, Nb);  % Flat part before sinusoid
            xTotal = [0, obj.a + xb, obj.a + obj.b + xs(2:end), obj.L];
            
            % Construct full z-coordinates
            zTotal = [zeros(1, Nb), zs, obj.H];
            
            % Construct the final matrix with x, y (zeros), and z coordinates
            mat = [xTotal', zeros(obj.N, 1), zTotal'];
            
        end

        function mat = fullSinusoid(obj)

            % Generates the points along the full sinusoid curve

            % Logical if N is even
            isNEven = mod(obj.N, 2) == 0;

            % Allowing only odd number of nodes for the full sinusoid for now
            assert(~isNEven, "Number of nodes must be odd for a full sinusoid. Given N = %d", obj.N)

            % Calculate adjusted L and N for the half sinusoid
            halfL = obj.L / 2;
            if  isNEven; halfN = obj.N / 2 + 1; end
            if ~isNEven; halfN = ceil(obj.N / 2); end
                
            % Create a temporary half sinusoid
            hs = Sinusoid(halfL, obj.H, halfN, obj.a, obj.b, obj.c, false);

            % Get the points for the half sinusoid
            halfPts = hs.Points();

            % Get the second halves by flipping and translating in X direction by L
            flipPts = flip(halfPts);
            flipPts(:, 1) = -flipPts(:, 1) + obj.L;
            
            % Trim one center point from the halfPts (there is two because of symmetry)
            halfPts(end, :) = [];

            % If N is even, then also trim the other center point from the flipped
            if isNEven; flipPts(1, :) = []; end
        
            % If N is odd, there will be ONE point at the center
            % If N is even, there will be NO point at the center

            % Return
            mat = [halfPts; flipPts];
            
        end

    end
        
end
