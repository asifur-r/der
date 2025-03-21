clc; clear; clf; %close all

% Two rods, straight rod, left end fixed, one torional moment applied at the middle of one rod or the other

% --------------------------------------------------
% SETUP, PATHS
% --------------------------------------------------

% Path to DER folder
derPath = '../'; addpath(genpath(derPath))

% Z axis
axisZ = [0 0 1];
axisY = [0 1 0];

% --------------------------------------------------
% LOAD / DISP
% --------------------------------------------------

% Load (N or Nmm)
P = 40; % 
D = 50.0; 

% --------------------------------------------------    
% SECTION PROPERTIES
% --------------------------------------------------

%sec = Section(width, height);
sec = Section(5, 5);

% --------------------------------------------------
% MATERIAL PROPERTIES
% --------------------------------------------------

%mat = Material(E, nu, rho);
mat = Material(2.2e3, 0.38, 1.2e-6);

% --------------------------------------------------
% RODS GENERATION
% --------------------------------------------------

% Rod length
L = 100; % mm

% Number of vertices
N = 201;

% Stiff part length
sb = 1.0;

% Generate base rods along X-axis
alongX = Profile.Straight(L, N, sb, sb);

rods(1) = InitializeRod(alongX, sec, mat);
% rods(2) = InitializeRod(Geometry.TranslateByVector(Geometry.RotateByAngle(alongX, axisZ, pi/2), [L 0 0]), sec, mat);
rods(2) = InitializeRod(Geometry.TranslateByVector(Geometry.RotateByAngle(alongX, axisZ, pi/2), [L/2 -L/2 0]), sec, mat);

% Optional: Check geometry by plotting
% for r=1:length(rods); plotRefAndDefGeom(rods(r).q0, [], r); end

% --------------------------------------------------
% RESTRAINT ASSIGNMENT
% --------------------------------------------------

TS = [Series('constant', 1), Series('linear', D, 0, 10)];

% Assign restraints
rods(1) = Restraint(rods(1), 1:2, 1:3, 1); rods(1) = Restraint(rods(1), 1, 4, 1);
rods(2) = Restraint(rods(2), N-1:N, 1:3, 1); rods(2) = Restraint(rods(2), N-1, 4, 1);

% --------------------------------------------------
% LOAD ASSIGNMENT
% --------------------------------------------------

% Assign loads
% rods(1) = PointLoad(rods(1), N, 3, 2); % Tip load in rod 1
rods(1) = Displacement(rods(1), N, 3, 2);

% --------------------------------------------------
% ROD PAIRS AND LINKER SPECS
% --------------------------------------------------

% Apply rounding to coordinates
for r=1:length(rods); rods(r).points = round(rods(r).points, 6); end

% Find rod pairs for joints
pairs = RodPairs(rods);

% Define linker
penalty = 1e5; EMod = 1.0; mat.E = EMod*mat.E; link = Linker(pairs, sec, mat, penalty);

% --------------------------------------------------
% MONITORING SETUP
% --------------------------------------------------

% Inspection variables(rod, node, dof)
liveDofs = [1 N 3];

% Visual
vis = [];%Visual('dofs', liveDofs, 'deformed', true);%, 'triad', true);

% Monitor
mon = []; %Monitor('iter', perIter, 'step', perStep);

% Recorder
rec = [];%Record('forcefile', 'force.txt', 'forcedofs', liveDisp);

% --------------------------------------------------
% ANALYSIS
% --------------------------------------------------

% Analysis object
ana = Analysis('static', 10, 1);
% ana = Analysis('dynamic', 10, 1);
ana = ana.Integration('euler');
% ana = ana.Integration('newmark', 0.5);
ana = ana.Solver('nr');
ana = ana.Convergence(1e-4, 100);
ana = ana.Constraint('elimination');
% ana = ana.Constraint('penalty', 1e8);
% ana = ana.Damping('rayleigh', 0.01, 0.001);
ana = ana.TimeSeries(TS);

% Call driver
tic; S = DER(rods, link, ana, vis, mon, rec); toc

% Geometry plot
%figure; for r=1:length(S.Qs); plotRefAndDefGeom(S.Qs{r}(:,1), S.Qs{r}(:,end), r); end