function [...
    enormbar, ...
    tbar, ...
    ellbar, ...
    a1bar, ...
    mrefbar, ...
    mbar, ...
    kap1bar, kap2bar] ...
    = initializeKinematics(q)

    gam = extractAngles(q);
    nele = length(gam);

    % Stretching

    e = edgeVectors(q);
    enorm = edgeLengths(e);
    enormbar = enorm;

    t = tangentVectors(e);
    tbar = t;

    ell = voronoiLengths(e);
    ellbar = ell;

    % Twisting

    % Directors
    [a1, a2] = initialReferenceDirectors(t);
    a1bar = a1;

    mref = zeros(nele, 1); 
    mrefbar = mref;
    %mref = referenceTwist(a1, t, mrefbar);

    m = integratedTwist(q, mref);
    mbar = m;

    % Bending

    % Material directors
    [m1, m2] = materialDirectors(a1, a2, gam);

    % Curvature
    kapb = curvatureVectors(t);
    [kap1, kap2] = curvature(m1, m2, kapb);
    kap1bar = kap1;
    kap2bar = kap2;

end