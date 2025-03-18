classdef (Abstract) Profile

    % properties (Constant)

    % end

    methods (Static)

        function mat = Straight(L, N, a, b)

            % L = length
            % N = Number of nodes
            % a = location of the 2nd point from left
            % b = location of the 2nd point from right
        
            % Effective number of nodes and length
            eN = N - 2;
            eL = L - b;

            vec = [0 linspace(a, eL, eN) L];
            mat = [vec' zeros(N, 2)];
            
        end

        function mat = StraightSimple(L, N)

            % L = length
            % N = Number of nodes

            mat = [linspace(0, L, N)' zeros(N, 2)];
            
        end

        function mat = HalfSinusoid(B, H, N, a, b, c)

            % B = Half base length 
            % H = Specimen height
            % a = Initial flat length 1
            % b = Initial flat length 2
            % c = Central flat length (half)
            % Note: there will be no intermediate nodes in the part 'a' and 'c'
        
            eB = B - (a + b + c); % Effective base length excluding the flat parts
            NB = 5;
            N = N - NB - 1;
        
            % Generate the sinusoid part
            x = linspace(0, eB, N);
            z = H / 2 * (1 + sin( pi * (x/eB - 1/2) ) );
        
            % Insert the flat parts before and after
            x = [0 a+linspace(0, b, 5) a+b+x(2:end) B];
            z = [zeros(1, NB) z H];
            
            mat = [x' zeros(length(x),1) z'];
            
        end

        function mat = FullSinusoid(B, H, N, a, b, c)

            % B = Full base length

            % If N is even, then add one more points, and trim the center point (apex) later
            if(mod(N, 2) == 0); eN = N + 1; else; eN = N; end
        
            % First halves
            half = Profile.HalfSinusoid(B, H, ceil(eN/2), a, b, c);
        
            % Second halves by flipping and translating
            flipped = flip(half);
            flipped(:,1) = -flipped(:,1) + 2*B;
            
            % Trim one center point (there is two because of symmetry)
            half(end, :) = [];

            % If N is even, then also trim the other center point (this makes eN = N again)
            if(mod(N, 2) == 0); flipped(1, :) = []; end
        
            % Return
            mat = [half; flipped];

            % Just making sure the number of rows is equal to number of points
            assert(size(mat, 1) == N)
        
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