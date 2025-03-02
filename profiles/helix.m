function mat = helix(radius, height, turns, num_points)
    % generate_helix: Generates points on a 3D helix
    
    % Inputs:
    %   radius: Radius of the helix
    %   height: Height of the helix
    %   turns: Number of turns the helix makes
    %   num_points: Number of points to generate
    
    % Outputs:
    %   x, y, z: Coordinates of the points on the helix
    
    % Create theta vector for parametric equation
    theta = linspace(0, 2*pi*turns, num_points);
    
    % Calculate helix coordinates
    x = radius * cos(theta);
    y = radius * sin(theta);
    z = theta * height / (2*pi*turns);

    mat = [x' y' z'];
    
    end