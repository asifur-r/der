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
% LOAD
% --------------------------------------------------

% Load (N or Nmm)
P = -2000.0;

% Displacement (N or Nmm)
D = -15.0;

% --------------------------------------------------    
% SECTION PROPERTIES
% --------------------------------------------------

%sec = Section(width, height);
sec = Section(5, 2);

% --------------------------------------------------
% MATERIAL PROPERTIES
% --------------------------------------------------

%mat = Material(E, nu, rho);
mat = Material(2.2e3, 0.38, 1.2e-4);

% --------------------------------------------------
% RODS GENERATION
% --------------------------------------------------

% Rod length
L = 50; % mm

% Rod height
H = 25; % mm

% Number of vertices (must be odd)
N = 35;

% Flat lengths
a = 1; b = 5; c = 1;

% Generate rods
arch = fullSinusoid(L, H, N, a, b, c);
base = [arch(:, 1) zeros(N,2)];

rods(1) = InitializeRod(arch, sec, mat);
rods(2) = InitializeRod(base, sec, mat);

% Optional: Check geometry by plotting
for r=1:length(rods); plotRefAndDefGeom(rods(r).q0, [], r); end

% --------------------------------------------------
% RESTRAINT ASSIGNMENT
% --------------------------------------------------

TS = [Series('constant', 1), Series('sawtooth', D, 0, 12), Series('rectangular', 1, 0, 15)];

% Assign restraints
rods(1) = Restraint(rods(1), 1, 1:3, 1);
rods(1) = Restraint(rods(1), N, 2:3, 1);
rods(1) = Restraint(rods(1), N, 1, 3);

% --------------------------------------------------
% LOAD ASSIGNMENT
% --------------------------------------------------

cnode = ceil(N/2);

% Assign loads
% rods(1) = PointLoad(rods(1), 10, 4, M, 2); % Torsion in rod 1
% rods(2) = PointLoad(rods(2), 10, 4, M, 2); % Torsion in rod 2
% rods(1) = PointLoad(rods(1), cnode, 3, 2); % Tip load in rod 1
rods(1) = Displacement(rods(1), cnode, 3, 2);
% rods(2) = Displacement(rods(2), 2, 3, 2);

% Record load values to file
%loadFile = strcat('out/square_plus_mtheta_h=', num2str(Hs),'_load'); recordLoad(loadFile, rods);

% --------------------------------------------------
% ROD PAIRS AND LINKER SPECS
% --------------------------------------------------

% % Coordinates rounding decimal places
% roundTol = 6;

% for r=1:length(rods); rods(r).points = round(rods(r).points, roundTol); end

% % Find rod pairs for joints
% pairs = rodPairs(rods, roundTol);

% % Define linker
% penalty = 1e5; EMod = 1.0; mat.E = EMod*mat.E; link = linker(pairs, sec, mat, penalty);

link = [];

% --------------------------------------------------
% MONITORING SETUP
% --------------------------------------------------

% Inspection variables(rod, node, dof)
liveDofs = [1 cnode 3];

% Visual
vis = Visual('dofs', liveDofs, 'deformed', true);

% Monitor
mon = []; %Monitor('iter', perIter, 'step', perStep);

% Recorder
rec = [];%Record('forcefile', 'force.txt', 'forcedofs', liveDisp);

% --------------------------------------------------
% ANALYSIS
% --------------------------------------------------

% Analysis object
% ana = Analysis('static', 0.1);
ana = Analysis('dynamic', 20, 0.2);

% Integration
ana = ana.Integration('euler');
% ana = ana.Integration('newmark', 0.75);

% Solver
ana = ana.Solver('nr');
% ana = ana.Solver('mgdm');

% Convergence
ana = ana.Convergence(1e-6, 100);

% Constraint
ana = ana.Constraint('elimination');
% ana = ana.Constraint('penalty', 1e8);

% Damping
ana = ana.Damping('rayleigh', 0.01, 0.001);

% Time series
ana = ana.TimeSeries(TS);
% ana = ana.TimeSeries([Series('constant', 1), Series('triangular', 1, 4, 8, 12)]);

% Equal dof constraint
kp = 1e7;

% Arch tops (y constraint)
ana = ana.EqualDof(1, cnode-1, 1, cnode, 3, kp);
ana = ana.EqualDof(1, cnode-1, 1, cnode+1, 3, kp);

% Between rods
for i = 2:6
    ana = ana.EqualDof(1, i, 2, i, 1:3, kp);
    ana = ana.EqualDof(1, N+1-i, 2, N+1-i, 1:3, kp);
end

% Call driver
tic; S = DER(rods, link, ana, vis, mon, rec); toc

% Geometry plot
%figure; for r=1:length(S.Qs); plotRefAndDefGeom(S.Qs{r}(:,1), S.Qs{r}(:,end), r); end