function points = simpleSinusoid(L, H, N)
    % This function generates a cosine curve scaled by L in x-direction and H in y-direction
    % L: total length in the x-direction
    % H: height of the curve in the y-direction
    % N: number of points
    % points: Nx3 matrix where each row is a point [x, y, z]
    
    % Generate N points in the x direction, equally spaced between 0 and L
    x = linspace(0, L, N);
    
    % Compute y values
    y = 0*x;

    % Compute the corresponding z values using the cosine function
    z = - H * cos((2*pi / L) * x) / 2 + H / 2;
    
    % Combine x and y into an Nx2 matrix
    points = [x', y', z'];
end

