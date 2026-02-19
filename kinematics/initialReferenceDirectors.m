function [a1, a2] = initialReferenceDirectors(t)
    
    nele = size(t, 1);

    a1 = zeros(nele, 3);
    a2 = zeros(nele, 3);

    % Construct the first t-a1-a2 triad
    a1(1, :) = orthogonalVector(t(1, :));
    a2(1, :) = cross(t(1, :), a1(1, :));
    
    % The first t and a1 as initial vectors for propagation
    % p = k-1 th item, q = k th item
    
    % Set k-1 th tangent and a1
    tp = t(1, :);
    a1p = a1(1, :);

    for i = 2:nele

        % Set k-th tangent
        tq = t(i, :);
        
        % Transport k-1 th a1 from k-1 tangent space to k th tangent space
        trans = parallelTransport(a1p, tp, tq);
        
        a1(i, :) = trans / vecnorm(trans); % Make unit vector

        % Cross to get the other director
        a2(i, :) = cross(tq, a1(i, :));

        % Set current k-th tangent and a1 as k-1
        tp = t(i, :);
        a1p = a1(i, :);
        
    end

end