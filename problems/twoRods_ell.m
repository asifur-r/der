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

%sec = Section(width, height);
sec = Section(5, 5);

% --------------------------------------------------
% MATERIAL PROPERTIES
% --------------------------------------------------

%mat = MaterialE, nu, rho);
mat = Material2.2e3, 0.38, 1.2e-6);

% --------------------------------------------------
% RODS GENERATION
% --------------------------------------------------

% Rod length
L = 100; % mm

% Number of vertices
N = 10;

% Stiff part length
sb = 1.0;

% Generate base rods along X-axis
alongX = straightLine(L, N, sb, sb);

rods(1) = InitializeRod(alongX, sec, mat);
rods(2) = InitializeRod(Geometry.TranslateByVector(Geometry.RotateByAngle(alongX, axisZ, pi/2), [L 0 0]), sec, mat);
%rods(2) = InitializeRod(Geometry.TranslateByVector(Geometry.RotateByAngle(alongX, axisZ, 3*pi/2), [L L 0]), sec, mat);

% Optional: Check geometry by plotting
%for r=1:length(rods); plotRefAndDefGeom(rods(r).q0, [], r); end

% --------------------------------------------------
% RESTRAINT ASSIGNMENT
% --------------------------------------------------

% Assign restraints
rods(1) = Restraint(rods(1), 1:2, 1:3, 1); rods(1) = Restraint(rods(1), 1, 4, 1);
rods(2) = Restraint(rods(2), N-1:N, 1:3, 1); rods(2) = Restraint(rods(2), N-1, 4, 1);

% --------------------------------------------------
% LOAD ASSIGNMENT
% --------------------------------------------------

% Assign loads
%rods(1) = PointLoad(rods(1), 10, 4, M); % Torsion in rod 1
%rods(2) = PointLoad(rods(2), 10, 4, M); % Torsion in rod 2
%rods(1) = PointLoad(rods(1), N, 3, M/25); % Tip load in rod 1
rods(1) = displacement(rods(1), N, 3, 30); % Tip displacement in rod 1

% Record load values to file
%loadFile = strcat('out/square_plus_mtheta_h=', num2str(Hs),'_load'); recordLoad(loadFile, rods);

% --------------------------------------------------
% ROD PAIRS AND LINKER SPECS
% --------------------------------------------------

% Coordinates rounding decimal places
roundTol=6;

% Find rod pairs for joints
pairs = rodPairs(rods, roundTol);

% Define linker
penalty = 1e5; EMod = 1.0; mat.E = EMod*mat.E; link = linker(pairs, sec, mat, penalty);

% --------------------------------------------------
% MONITORING SETUP
% --------------------------------------------------

% Inspection variables(rod, node, dof)
liveDisp = [1 N 3]; %liveForce = [1 3 3];

% Visual
vis = [];%visual('deformed', true, 'force', liveDisp);

% Monitor
mon = []; %monitor('iter', perIter, 'step', perStep);

% Recorder
rec = [];%record('forcefile', 'force.txt', 'forcedofs', liveDisp);

% --------------------------------------------------
% ANALYSIS
% --------------------------------------------------

% Analysis parameters (solver, incr, maxiter, tol, 'constraint', 'constraintPenalty')
ana = analysis('nr', 0.1, 100, 1e-4, 'elimination', []);
%ana = analysis('mgdm', 0.1, 100, 1e-4, 'elimination', []);
% ana = analysis('nr', 0.1, 100, 1e-4, 'penalty', 1e8);
%ana = analysis('mgdm', 0.05, 100, 1e-4, 'penalty', 1e8);

% Call driver
tic; S = driver(rods, link, ana, vis, mon, rec); toc

% Geometry plot
%figure; for r=1:length(S.Qs); plotRefAndDefGeom(S.Qs{r}(:,1), S.Qs{r}(:,end), r); end