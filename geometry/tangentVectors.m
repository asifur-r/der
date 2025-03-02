function t = tangentVectors(e)
    % Returns tangent vectors from edge vectors
    
    enorm = edgeLengths(e);

    t = e ./ enorm;

end