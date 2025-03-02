function plotRotation1(q)
    % Extract points and angles
    pts = extractPoints(q);
    x = pts(:, 1);
    y = pts(:, 2);
    z = pts(:, 3);
    ang = extractAngles(q);
    
    prev_p = [];
    prev_q = [];

    for i = 1:length(ang)
        % Compute tangent vector
        t = [x(i+1) - x(i), y(i+1) - y(i), z(i+1) - z(i)];
        t = t / norm(t); % Normalize
        
        % Compute midpoint
        mid_x = (x(i) + x(i+1)) / 2;
        mid_y = (y(i) + y(i+1)) / 2;
        mid_z = (z(i) + z(i+1)) / 2;
        
        % If it's the first edge, choose an initial (p, q)
        if isempty(prev_p) || isempty(prev_q)
            if abs(t(1)) < 1e-6 && abs(t(2)) < 1e-6
                p = cross(t, [1, 0, 0]); % If t is close to z-axis, use x-axis
            else
                p = cross(t, [0, 0, 1]); % Default perpendicular vector
            end
            p = p / norm(p);
            q = cross(t, p);
        else
            % Parallel transport p and q from the previous edge
            p = parTrans(prev_p, prev_q, prev_t, t);
            q = cross(t, p); % Ensure orthogonality
        end
        
        % Apply the rotation matrix to p and q
        R = rotationMatrix(t, ang(i)); 
        p = (R * p')'; 
        q = (R * q')';

        % Store current frame for next iteration
        prev_p = p;
        prev_q = q;
        prev_t = t;
        
        % Scaling factor
        s = 10;

        % Plot triad vectors
        quiver3(mid_x, mid_y, mid_z, t(1), t(2), t(3), s, 'r', 'LineWidth', 1.5, 'MaxHeadSize', 0.5);
        quiver3(mid_x, mid_y, mid_z, p(1), p(2), p(3), s, 'g', 'LineWidth', 1.5, 'MaxHeadSize', 0.5);
        quiver3(mid_x, mid_y, mid_z, q(1), q(2), q(3), s, 'b', 'LineWidth', 1.5, 'MaxHeadSize', 0.5);
    end

end

function p_new = parTrans(p, q, t_old, t_new)
    % Parallel transport p to the new edge
    v = cross(t_old, t_new); % Rotation axis
    if norm(v) < 1e-6
        p_new = p; % No rotation needed if t_old == t_new
        return;
    end
    v = v / norm(v); % Normalize
    angle = acos(dot(t_old, t_new)); % Compute rotation angle
    R = rotationMatrix(v, angle); % Get rotation matrix
    p_new = (R * p')'; % Apply rotation
end

function R = rotationMatrix(axis, theta)
    % Rodrigues' formula for rotating around an arbitrary axis
    k = axis / norm(axis);
    K = [0 -k(3) k(2); k(3) 0 -k(1); -k(2) k(1) 0]; % Skew-symmetric matrix
    R = eye(3) + sin(theta) * K + (1 - cos(theta)) * (K * K);
end