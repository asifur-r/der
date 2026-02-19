function points = extractPoints(q)
    % Returs the coordinate matrix [x y z] from a state vector q

    points = [q(1:4:end), q(2:4:end), q(3:4:end)];

end