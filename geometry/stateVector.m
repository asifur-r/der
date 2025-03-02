function vec = stateVector(points, gam)
    % Returns state vector of 4N-1 element from coordinates matrix and angle vector

    % Make n x 4 matrix, [x y z gam]
    mat = [points, [gam; 0]];

    % Transpose it before flattening
    mat = mat';

    % Flatten the matrix to a vector
    vec = mat(:);

    % Drop the last item
    vec(end) = [];

    % Alternate approach
    % Maps local n x 4 matrix to global vector (4n-1) x 1
    %n = size(mat, 1);
    %vec = reshape(mat', [4*n 1]);
    %vec(end) = []; % Drop the last item

end