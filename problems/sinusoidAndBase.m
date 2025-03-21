clc; clear all; clf; %close all

% Sinsudoidal arch with compliant base
% Tip displacement applied through sawtooth ramp, then removed
% One pinned boundary changed to roller after second equilibrium

% ==================================================
% SETUP AND PATHS
% ==================================================

% Path to DER folder
derPath = '../'; addpath(genpath(derPath))

% ==================================================    
% MATERIAL AND SECTION PROPERTIES
% ==================================================

%sec = Section(width, height);
sec = Section(5, 0.5001);

%mat = Material(E, nu, rho);
mat = Material(2.2e3, 0.38, 1.2e-6);

% ==================================================
% RODS GENERATION
% ==================================================

% Base length
L = 90; % mm

% Sinusoid height
H = 25; % mm

% Number of vertices (must be odd)
N = 35;

% Flat lengths
a = 1; b = 4; c = 1;

% Generate rods
arch = Profile.FullSinusoid(L, H, N, a, b, c);
base = [arch(:, 1) zeros(N,2)];

rods(1) = InitializeRod(arch, sec, mat);
rods(2) = InitializeRod(base, sec, mat);

% Optional: Check geometry by plotting
for r=1:length(rods); plotRefAndDefGeom(rods(r).q0, [], r); end

% ==================================================
% TIME PARAMETERS
% ==================================================

% Final time (s)
tfinal = 15;

% Time increment (s)
dt = 0.2;

% Prescribed displacement (mm)
D = - H * 2.1;

% Time series array
TS = [Series('constant', 1),...
      Series('sawtooth', D, 0, 8),...
      Series('rectangle', 1, 0, 10),...
      Series('rectangle', 1, 0, 2)];

% ==================================================
% RESTRAINT ASSIGNMENT
% ==================================================

cnode = ceil(N/2) - 1;
dispNode = cnode - 1;

% Assign restraints
rods(1) = Restraint(rods(1), 1, 1:3, 1);
rods(1) = Restraint(rods(1), N, 2:3, 1);
rods(1) = Restraint(rods(1), N, 1, 3);

% ==================================================
% LOAD ASSIGNMENT
% ==================================================

% Assign loads
rods(1) = Displacement(rods(1), dispNode, 3, 2);
% rods(2) = Displacement(rods(2), 2, 3, 2);

% ==================================================
% ROD PAIRS AND LINKER SPECS
% ==================================================

link = [];

% ==================================================
% MONITORING AND RECORDER SETUP
% ==================================================

% Inspection variables(rod, node, dof)
liveDofs = [1 dispNode 3];

% Visual
vis = Visual('dofs', liveDofs, 'deformed', true);

% Monitor
mon = []; %Monitor('iter', perIter, 'step', perStep);

% Recorder
rec = [];

% ==================================================
% ANALYSIS
% ==================================================

% Analysis object
ana = Analysis('static', tfinal, dt);
% ana = Analysis('dynamic', tfinal, dt);
ana = ana.Integration('euler');
% ana = ana.Integration('newmark', 0.75);
ana = ana.Solver('nr');
ana = ana.Convergence(1e-4, 100);
ana = ana.Constraint('elimination');
% ana = ana.Constraint('penalty', 1e9);
% ana = ana.Damping('rayleigh', 0.01, 0.0001);
ana = ana.TimeSeries(TS);

% Equal dof constraint
kp = 1e7;

% EqualDof(obj, masterRod, masterNode, slaveRod, slaveNode, dofs, penalty)

% Arch tops (z constraint)
ana = ana.EqualDof(1, cnode-1, 1, cnode, 3, kp, 4);
ana = ana.EqualDof(1, cnode-1, 1, cnode+1, 3, kp, 4);

% Between rods
for i = 2:6
    ana = ana.EqualDof(1, i, 2, i, 1:3, kp, 1);
    ana = ana.EqualDof(1, N+1-i, 2, N+1-i, 1:3, kp, 1);
end

% ==================================================
% EXECUTION
% ==================================================
tic; S = DER(rods, link, ana, vis, mon, rec); toc

% Geometry plot
%figure; for r=1:length(S.Qs); plotRefAndDefGeom(S.Qs{r}(:,1), S.Qs{r}(:,end), r); end