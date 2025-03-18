function mat = ell(L, N)
    % Input:
    % L: Length of each leg of the L-shaped rod
    % N: Total number of nodes

    % Determine the number of nodes for each leg
    N1 = ceil(N / 2); % Nodes for the first leg (x-direction)
    N2 = N - N1 + 1;  % Nodes for the second leg (y-direction), including the shared node

    % Generate points for the first leg (x-direction)
    x1 = linspace(0, L, N1)'; % x-coordinates from 0 to L
    y1 = zeros(N1, 1);        % y-coordinates are 0
    z1 = zeros(N1, 1);        % z-coordinates are 0

    % Generate points for the second leg (y-direction)
    x2 = L * ones(N2, 1);     % x-coordinates are fixed at L
    y2 = linspace(0, L, N2)'; % y-coordinates from 0 to L
    z2 = zeros(N2, 1);        % z-coordinates are 0

    % Combine the points, ensuring no duplicate node at the corner
    coords = [x1, y1, z1; x2(2:end), y2(2:end), z2(2:end)];

    mat = coords;

end