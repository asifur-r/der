% Khalids
run('khalid/Main_modified.m')

% Ours
%clc; clear; close all;
%clear

addpath(genpath(pwd))

[n, nele, points, gam, h, w, E, nu, res, fext, loadNodes, loadDofs, loads] = problem_kh();
[EA, EIx, EIy, GJ] = stiffness_kh(nele, h, w, E, nu);
[solver, nsteps, tol, maxiter] = analysisParameter();

%q = stateVector(points, gam);
q = x; 

[enormbar, tbar, ellbar, a1bar, mref, mbar, kap1bar, kap2bar] = initializeKinematics(q, nele);

% Do perturbation
q = xPerturbed;

[Fs, Ks, Ft, Kt, Fb, Kb] = allForcesStiffness(q, enormbar, EA, a1bar, tbar, mbar, ellbar, mref, GJ, kap1bar, kap2bar, EIx, EIy);

% % Recompute e, t
% e = edgeVectors(q);
% enorm = edgeLengths(e);

% t = tangentVectors(e);

% % Compute force, stifness
% [Fs, Ks] = stretchingForceStiffness(t, enorm, enormbar, EA);

% % TWIST
% kapb = curvatureVectors(t);
% [a1, a2] = referenceDirectors(a1bar, tbar, t);
% mref = referenceTwist(a1, t, mref);
% m = integratedTwist(q, mref);
% [Ft, Kt] = twistingForceStiffness(t, enorm, kapb, m, mbar, ellbar, GJ);

% % BENDING
% gam = extractAngles(q);
% [m1, m2] = materialDirectors(a1, a2, gam);
% [kap1, kap2] = curvature(m1, m2, kapb);
% [Fb, Kb] = bendingForceStiffness(t, enorm, kapb, kap1, kap2, kap1bar, kap2bar, m1, m2, ellbar, EIx, EIy);

% Checking forces and jacobians with Khalids
% Signs are flipped in my code

disp("Checking stretching force"); [Fstretch + Fs]
disp("Checking stretching stiffness"); [JAnalyticalStretch + Ks]

disp("Checking twisting force"); [Ftwist+Ft]
disp("Checking twisting stiffness"); [JAnalyticalTwist + Kt]

disp("Checking bending force"); [Fbend+Fb]
disp("Checking bending stiffness"); [JAnalyticalBend + Kb]

%var_ar - var_kh