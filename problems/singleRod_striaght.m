clc; clear; clf; %close all

% Single straight rod, left end fixed, one torional moment applied at the tip or in the middle

% --------------------------------------------------
% SETUP, PATHS
% --------------------------------------------------

% Path to DER folder
derPath = "C:\Users\asifu\Dropbox\sbu\research\phd\discrete-elastic-rod\revised_der"; addpath(genpath(derPath))

% Z axis
axisZ = [0 0 1];

% --------------------------------------------------
% LOAD
% --------------------------------------------------

% Load (N or Nmm)
M = 100.0; % Torsional moment

% --------------------------------------------------    
% SECTION PROPERTIES
% --------------------------------------------------

% Width
w = 5; % mm

% Height / Thickness
h = 0.5; % mm

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
N = 15;

% Stiff part length
sb = 2.0;

% Generate base rods along X-axis
alongX = straightLine(L, N, sb, sb);
rods(1) = InitializeRod(alongX, w, h, E, nu);

% Translate rod 1 to get other three rods parallel to X
%rods(2) = InitializeRod(Geometry.TranslateByVector(Geometry.RotateByAngle(alongX, axisZ, pi), [2*Lb 0 0]), w, h, E, nu);
%rods(3) = InitializeRod(Geometry.TranslateByVector(alongX, [0 2*Lb 0]), w, h, E, nu);

% Generate base rods along Y-axis
%alongY = Geometry.RotateByAngle(alongX, axisZ, pi/2);
%rods(5) = InitializeRod(alongY, w, h, E, nu);

% Translate rod 5 to get other three rods parallel to Y
%rods(6) = InitializeRod(Geometry.TranslateByVector(Geometry.RotateByAngle(alongY, axisZ, pi), [0 2*Lb 0]), w, h, E, nu);
%rods(7) = InitializeRod(Geometry.TranslateByVector(alongY, [2*Lb 0 0]), w, h, E, nu);
%rods(8) = InitializeRod(Geometry.TranslateByVector(Geometry.RotateByAngle(alongY, axisZ, pi), [2*Lb 2*Lb 0]), w, h, E, nu);

% Optional: Check geometry by plotting
for r=1:length(rods); plotRefAndDefGeom(rods(r).q0, [], r); end

% --------------------------------------------------
% RESTRAINT ASSIGNMENT
% --------------------------------------------------

% Assign restraints
rods(1) = Restraint(rods(1), 1:2, 1:3); rods(1) = Restraint(rods(1), 1, 4);

% --------------------------------------------------
% LOAD ASSIGNMENT
% --------------------------------------------------

% Assign loads
%rods(1) = PointLoad(rods(1), N-1, 4, M); % At tip
rods(1) = PointLoad(rods(1), 10, 4, M); % At middle

% Record load values to file
%loadFile = strcat('out/square_plus_mtheta_h=', num2str(Hs),'_load'); recordLoad(loadFile, rods);

% --------------------------------------------------
% ROD PAIRS AND LINKER SPECS
% --------------------------------------------------

% Round coordinates to specified tolerance
roundTol=6; for r=1:length(rods); rods(r).points = round(rods(r).points, roundTol); end

% Find rod pairs for joints
pairs = rodPairs(rods);

% Define linker specifications
penalty = 1e4; EMod = 1.0; linkspec = linker(w, h, EMod*E, nu, penalty);

% --------------------------------------------------
% MONITORING SETUP
% --------------------------------------------------

% Inspection rods (rod, node, dof)
inspSpecs = [1 N-1 4];

% Visual
vis= visual(inspSpecs, 'on', 'on', 'off');

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
tic; S = driver(rods, pairs, linkspec, analysis, visual, rec); toc
