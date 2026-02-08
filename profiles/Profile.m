classdef (Abstract) Profile
    % Returns coordinate matrix, mat = [x y z] where x, y and z are column vectors

    methods (Static)

        function mat = Straight(L, N, a, b)

            % L = length
            % N = Number of nodes
            % a = location of the 2nd point from left
            % b = location of the 2nd point from right
        
            % Effective number of nodes and length for linspace
            eN = N - 2;
            eL = L - b;

            vec = [0 linspace(a, eL, eN) L];
            mat = [vec' zeros(N, 2)];
            
        end

        function mat = StraightSeries(L, N, M, a, b)
            % M = number of segments to concatenate
            
            % Generate a segment
            segment = Profile.Straight(L, N, a, b);
            
            % Concatenate M segments
            mat = [];
            for i = 1:M

                % Shift X coordinates
                translated = Geometry.TranslateByVector(segment, [(i-1)*L 0 0]);

                % Append
                mat = [mat(1:end-1,:); translated];
            end
            
        end

        function mat = StraightSimple(L, N)

            % L = length
            % N = Number of nodes

            mat = [linspace(0, L, N)' zeros(N, 2)];
            
        end

        function mat = HalfSinusoid(L, H, N, a, b, c)

            % L = Length of the half base
            % H = Height
            % N = Number of nodes
            % a = Initial flat length 1
            % b = Initial flat length 2
            % c = Central flat length (half)
            % Note: No intermediate nodes in 'a' and 'c'
            
            % Number of points in 'b' region
            Nb = 5;

            % Remaining nodes for sinusoidal part
            Ns = N - Nb - 1;
            
            % Compute the effective sinusoidal base length (excluding flat parts)
            Ls = L - (a + b + c);
            
            % Generate sinusoidal x-coordinates within the effective length
            xs = linspace(0, Ls, Ns);
            
            % Compute sinusoidal z-coordinates
            zs = (H / 2) * (1 + sin(pi * (xs / Ls - 0.5)));
            
            % Construct full x-coordinates with flat regions
            xb = linspace(0, b, Nb);  % Flat part 'b'
            xTotal = [0, a + xb, a + b + xs(2:end), L];
            
            % Construct full z-coordinates
            zTotal = [zeros(1, Nb), zs, H];
            
            % Construct the final matrix with x, y (zeros), and z coordinates
            mat = [xTotal', zeros(N, 1), zTotal'];
            
        end

        function mat = FullSinusoid(L, H, N, a, b, c)

            % L = Full base length

            % If N is even, then add one more points, and trim the center point (apex) later
            if(mod(N, 2) == 0); eN = N + 1; else; eN = N; end
        
            % First halves
            half = Profile.HalfSinusoid(L/2, H, ceil(eN/2), a, b, c);
        
            % Second halves by flipping and translating
            flipped = flip(half);
            flipped(:,1) = -flipped(:,1) + L;
            
            % Trim one center point (there is two because of symmetry)
            half(end, :) = [];

            % If N is even, then also trim the other center point (this makes eN = N again)
            if(mod(N, 2) == 0); flipped(1, :) = []; end
        
            % Return
            mat = [half; flipped];

            % Just making sure the number of rows is equal to number of points asked
            assert(size(mat, 1) == N)
        
        end

        function mat = FullSinusoidSeries(L, H, N, M, a, b, c)
            
            % Generate a segment
            segment = Profile.FullSinusoid(L, H, N, a, b, c);
            
            % Concatenate M segments
            mat = [];
            for i = 1:M

                % Shift X coordinates
                translated = Geometry.TranslateByVector(segment, [(i-1)*L 0 0]);

                % Append
                mat = [mat(1:end-1,:); translated];
            end

        end

        function mat = HalfSinusoidSimple(L, H, N)
            % This function generates a cosine curve scaled by L in x-direction and H in y-direction
            % No flat length at the ends

            % L: total length in the x-direction
            % H: height of the curve in the y-direction
            % N: number of points
            
            % Generate N points in the x direction, equally spaced between 0 and L
            x = linspace(0, L, N);
            
            % Compute y values
            y = 0*x;
        
            % Compute the corresponding z values using the cosine function
            z = - H * cos((2*pi / L) * x) / 2 + H / 2;
            
            % Combine x and y into an Nx2 matrix
            mat = [x', y', z'];
        end

    end

end