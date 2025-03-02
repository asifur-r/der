function points = extractPoints(q)
    % Returs the coordinate matrix [x y z] from a state vector q

    % Drop the angles
    q(4:4:end) = [];

    % Reshape and return the coordinates
    points = reshape(q, 3, [])';

end