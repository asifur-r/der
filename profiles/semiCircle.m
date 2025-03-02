function mat = semiCircle(R, numPoints)

    % Generate the angles from 0 to pi radians
    theta = linspace(0, pi, numPoints);
    
    % Calculate x and y coordinates using polar to Cartesian conversion
    x = R * cos(theta/2);
    y = R * sin(theta/2);
    
    % Output the coordinates as a matrix
    mat = [x' y' zeros(size(x, 1), 1)];
end