function e = edgeVectors(q)
    % Returs the edge vectors list from a state vector q

    % Extract the coordinates [x y z]
    points = extractPoints(q);

    % Edge vectors (Eq. 3.2)
    e = diff(points);
    
end