clc; clear; clf; %close all

% Two rods, straight rod, left end fixed, one torional moment applied at the middle of one rod or the other

% --------------------------------------------------
% SETUP, PATHS
% --------------------------------------------------

% Path to DER folder
derPath = "C:\Users\asifu\Dropbox\sbu\research\phd\discrete-elastic-rod\revised_der"; addpath(genpath(derPath))

% Z axis
axisZ = [0 0 1];
axisY = [0 1 0];

% --------------------------------------------------
% LOAD
% --------------------------------------------------

% Load (N or Nmm)
M = 2000.0; % Torsional moment

% --------------------------------------------------    
% SECTION PROPERTIES
% --------------------------------------------------

% Width
w = 5; % mm

% Height / Thickness
h = 5; % mm

% --------------------------------------------------
% MATERIAL PROPERTIES
% --------------------------------------------------

% Young's modulus
E = 2.2e3; % N/mm2

% Poissons Ratio
nu = 0.38;

% --------------------------------------------------
% RODS GENERATION
% --------------------------------------------------

% Rod length
L = 100; % mm

% Number of vertices
N = 8;

% Stiff part length
sb = 10;

% Generate base rods along X-axis
alongX = Profile.Straight(L, N, sb, sb);
%alongX = flip(alongX);
rods(1) = InitializeRod(alongX, w, h, E, nu);
%rods(2) = InitializeRod(Geometry.TranslateByVector(Geometry.RotateByAngle(alongX, axisZ, pi/2), [L 0 0]), w, h, E, nu);

points = ell(L, N);
points = flip(points);
rods(2) = InitializeRod(Geometry.TranslateByVector(points, [L 0 0]), w, h, E, nu);

% Optional: Check geometry by plotting
for r=1:length(rods); plotRefAndDefGeom(rods(r).q0, [], r); end

% --------------------------------------------------
% RESTRAINT ASSIGNMENT
% --------------------------------------------------

% Assign restraints
rods(1) = Restraint(rods(1), 1:2, 1:3); rods(1) = Restraint(rods(1), 1, 4);
%rods(1) = Restraint(rods(1), N-1:N, 1:3); rods(1) = Restraint(rods(1), N-1, 4);

% --------------------------------------------------
% LOAD ASSIGNMENT
% --------------------------------------------------

% Assign loads
rods(1) = PointLoad(rods(1), ceil(N/2), 4, M); % Torsion in rod 1
%rods(2) = PointLoad(rods(2), ceil(N/2), 4, M); % Torsion in rod 2

% Record load values to file
%loadFile = strcat('out/square_plus_mtheta_h=', num2str(Hs),'_load'); recordLoad(loadFile, rods);

% --------------------------------------------------
% ROD PAIRS AND LINKER SPECS
% --------------------------------------------------

% Round coordinates to specified tolerance
roundTol=6; for r=1:length(rods); rods(r).points = round(rods(r).points, roundTol); end

% Find rod pairs for joints
pairs = RodPairs(rods);

% Define linker specifications
penalty = 1e10; EMod = 1.0; linkspec = linker(w, h, EMod*E, nu, penalty);

% --------------------------------------------------
% MONITORING SETUP
% --------------------------------------------------

% Inspection rods (rod, node, dof)
inspSpecs = [1 N-1 4];

% Visual
vis= visual(inspSpecs, 'on', 'on', 'off');

% Monitor
%[extractAngles(Rods(1).q) extractAngles(Rods(2).q)]
perIter = ''; perStep = ''; mon = monitor('iter', perIter, 'step', perStep);

% Recorder
%dispSpecs = [(1:8)' ones(8,1)*Nb-1 ones(8,1)*4];

% Recorder
%dispFile = strcat('out/square_plus_pdelta_h=', num2str(Hs),'_disp'); 

rec = [];%record(dispFile, dispSpecs);

% --------------------------------------------------
% ANALYSIS
% --------------------------------------------------

% Analysis parameters (solver, incr, maxiter, tol)
ana = analysis('mgdm', 0.01, 100, 1e-4);

% Call driver
tic; S = driver(rods, pairs, linkspec, ana, vis, mon, rec); toc
