function mat = fullSinusoid(B, H, n, a, b, c)

    % Check if n is odd
    assert(mod(n, 2) == 1, "Number of node n must be odd. Given n = %d", n)

    % First halves
    half = sinusoid(B, H, ceil(n/2), a, b, c);

    % Second halves
    flipped = flip(half);
    flipped(:,1) = -flipped(:,1) + 2*B;
    
    % Trim one center point (there is two because of symmetry)
    half(end, :) = []; % Trim this
    % flipped(1, :) = []; % Or trim this

    % Return
    mat = [half; flipped];

end