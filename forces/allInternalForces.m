function f = allInternalForces(R)
    % Takes a rod struct R, updates kinematics and recomputes internal forces

    % Recompute e, t
    e     = edgeVectors(R.q);
    enorm = edgeLengths(e);
    t     = tangentVectors(e);

    % STRETCHING
    Fs       = stretchingForcesSPARSE(t, enorm, R.enormbar, R.EA);

    % TWISTING
    kapb     = curvatureVectors(t);
    [a1, a2] = referenceDirectors(R.a1bar, R.tbar, t);
    mref     = referenceTwist(a1, t, R.mref);
    m        = integratedTwist(R.q, mref);
    Ft       = twistingForcesSPARSE(t, enorm, kapb, m, R.mbar, R.ellbar, R.GJ);

    % BENDING
    gam         = extractAngles(R.q);
    [m1, m2]    = materialDirectors(a1, a2, gam);
    [kap1, kap2]= curvature(m1, m2, kapb);
    Fb          = bendingForcesSPARSE(t, enorm, kapb, kap1, kap2, R.kap1bar, R.kap2bar, m1, m2, R.ellbar, R.EIx, R.EIy);

    % Return
    f = Fs + Ft + Fb;

end