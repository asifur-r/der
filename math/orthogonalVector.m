function vec = orthogonalVector(v)
    
    TOLERANCE = 1.0e-6;

    % Define a non-zero vector
    %nonZero = [1 0 0];  % You can choose any non-zero vector
    nonZero = [0 0 -1];
    
    % Compute the cross product
    ortho = cross(v, nonZero);
    
    % If the cross product is zero (parallel vectors), choose a different non-zero vector
    if abs(ortho) < TOLERANCE
        nonZero = [0 1 0];  % Choose another non-zero vector
        ortho = cross(v, nonZero);
    end
    
    vec = ortho;
end
