function [a1, a2] = referenceDirectors(a1bar, tbar, t)
    
    % a1bar = reference director a1 at reference configuration
    % tbar = tangents at reference configuration
    % t = tangents at current time step

    nele = size(t, 1);

    a1 = zeros(nele, 3);
    a2 = zeros(nele, 3);
    
    for i = 1:nele

        % Tangent from reference configuration (time=0)
        tp = tbar(i, :);

        % Tangent at current time
        tq = t(i, :);

        % Reference director from reference configuration
        a1p = a1bar(i, :);

        % Transport a1p from tp space (t=0) to tq space (current time)
        a1(i, :) = unitVector(parallelTransport(a1p, tp, tq));

        % Cross to get the other director
        a2(i, :) = cross(tq, a1(i, :));
        
    end

end