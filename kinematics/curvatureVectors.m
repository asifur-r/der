function kapb = curvatureVectors(t)
    % Returns the list of curvature vector kapb from a list of tangent vectors t

    % Number of elements
    nele = size(t, 1);

    % Number of ndoes
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