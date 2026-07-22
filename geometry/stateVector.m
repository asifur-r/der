function vec = stateVector(points, gam)
    % Returns state vector of 4N-1 element from coordinates matrix and angle vector

    % Make n x 4 matrix, [x y z gam]
    mat = [points, [gam; 0]];

    % Transpose it before flattening
    mat = mat';

    % Flatten the matrix to a vector
    vec = mat(:);

    % Drop the last item (zero)
    vec(end) = [];

end