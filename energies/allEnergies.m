function [Es, Et, Eb] = allEnergies(R)
    % Takes a rod struct R, updates kinematics and computes returns stretching, twisting and bending ebergies
    % Ref: Eq. 8.18

    % Recompute e, t
    e     = edgeVectors(R.q);
    enorm = edgeLengths(e);
    t     = tangentVectors(e);

    % STRETCHING
    Es = stretchingEnergy(R.EA, R.enormbar, enorm);

    % TWISTING
    kapb     = curvatureVectors(t);
    [a1, a2] = referenceDirectors(R.a1bar, R.tbar, t);
    mref     = referenceTwist(a1, t, R.mref);
    m        = integratedTwist(R.q, mref);
    Et       = twistingEnergy(R.GJ, R.mbar, R.ellbar, m);

    % BENDING
    gam         = extractAngles(R.q);
    [m1, m2]    = materialDirectors(a1, a2, gam);
    [kap1, kap2]= curvature(m1, m2, kapb);
    Eb          = bendingEnergy(R.EIx, R.EIy, R.kap1bar, R.kap2bar, R.ellbar, kap1, kap2);

end