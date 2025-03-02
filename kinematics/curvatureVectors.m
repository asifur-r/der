function kapb = curvatureVectors(t)

    % Element size
    nele = size(t, 1);
    n = nele + 1;

    % Curvature vector (size: n x 3)
    kapb = zeros(n, 3);

    for i = 2:nele

        tp = t(i-1, :);
        tq = t(i, :);

        % Eq. 4.3
        kapb(i, :) = 2 * cross(tp, tq) / (1 + dot(tp, tq));

    end
    
end