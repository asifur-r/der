function ell = voronoiLengths(e)
    % Returns voronoi length vectors from edge vectors

    enorm = edgeLengths(e);

    % Voronoi lengths (Eq. 3.5)
    ell = 0.5 * [enorm(1); enorm(1:end-1)+enorm(2:end); enorm(end)];
    
end