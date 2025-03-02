function plotRotation(q)

    points = extractPoints(q);
    ang = extractAngles(q);

    x = points(:, 1);
    y = points(:, 2);
    z = points(:, 3);
    
    % Length of the arrow, adjust as needed
    sc = averageElementSize(points)*0.75;

    xaxis = [1 0 0]; yaxis = [0 1 0]; zaxis = [0 0 1];
    noise = rand(1, 3)/1e6;

    for i = 1:length(ang)
        
        % Calculate midpoint of the edge
        mid_x = (x(i) + x(i+1)) / 2;
        mid_y = (y(i) + y(i+1)) / 2;
        mid_z = (z(i) + z(i+1)) / 2;
        
        c = cos(ang(i));
        s = sin(ang(i));

        % Tangent vector
        t = [x(i+1) - x(i), y(i+1) - y(i), z(i+1) - z(i)];
        
        % Unit tangent
        t = t/norm(t);
        
        tol = 1e-6; zeroColumn = ~all(abs(points) < tol, 1);

        % Calculate rotation vector
        if zeroColumn(1)
            refAxis = xaxis + noise; p = -[0 c s];
        elseif zeroColumn(2)
            refAxis = yaxis + noise; p = -[c 0 s];
        elseif  zeroColumn(3)
            refAxis = zaxis + noise; p = -[c s 0];
        end

        % Transported vectors
        p = parallelTransport(p, refAxis, t);
        q = cross(p, t); %parallelTransport(q, refAxis, t);

        % Plot the rotation vector as an arrow
        quiver3(mid_x, mid_y, mid_z, t(1), t(2), t(3), sc, 'r', 'LineWidth', 1.5, 'MaxHeadSize', 0.75);
        quiver3(mid_x, mid_y, mid_z, q(1), q(2), q(3), sc, 'g', 'LineWidth', 1.5, 'MaxHeadSize', 0.75);
        quiver3(mid_x, mid_y, mid_z, p(1), p(2), p(3), sc, 'b', 'LineWidth', 1.5, 'MaxHeadSize', 0.75);
    end

end

function val = averageElementSize(points)
    % Input:
    % points: n x 3 matrix of x, y, z coordinates of the nodes

    % Compute edge vectors
    edge_vectors = diff(points, 1, 1); % Difference between consecutive points

    % Compute edge lengths (Euclidean norm of each edge vector)
    edge_lengths = vecnorm(edge_vectors, 2, 2); % 2-norm along rows

    % Compute the average element size
    val = mean(edge_lengths);
end