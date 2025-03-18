clc; clear all; clf; %close all

% Sinsudoidal arch with compliant base
% Tip displacement applied through sawtooth ramp, then removed
% One pinned boundary changed to roller after second equilibrium

% ==================================================
% SETUP AND PATHS
% ==================================================

% Path to DER folder
derPath = '../'; addpath(genpath(derPath))

% Z axis
axisZ = [0 0 1];
axisY = [0 1 0];

% ==================================================    
% MATERIAL AND SECTION PROPERTIES
% ==================================================

%sec = Section(width, height);
sec = Section(5, 2);

%mat = Material(E, nu, rho);
mat = Material(2.2e3, 0.38, 1.2e-4);

% ==================================================
% RODS GENERATION
% ==================================================

% Rod length
L = 50; % mm

% Rod height
H = 25; % mm

% Number of vertices (must be odd)
N = 35;

% Flat lengths
a = 1; b = 5; c = 1;

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
tfinal = 20;

% Time increment (s)
dt = 0.2;

% Prescribed displacement (mm)
D = - 55;

% Time series array
TS = [Series('constant', 1), Series('sawtooth', D, 0, 12), Series('rectangular', 1, 0, 15)];

% ==================================================
% RESTRAINT ASSIGNMENT
% ==================================================

% Assign restraints
rods(1) = Restraint(rods(1), 1, 1:3, 1);
rods(1) = Restraint(rods(1), N, 2:3, 1);
rods(1) = Restraint(rods(1), N, 1, 3);

% ==================================================
% LOAD ASSIGNMENT
% ==================================================

cnode = ceil(N/2);

% Assign loads
rods(1) = Displacement(rods(1), cnode, 3, 2);
% rods(2) = Displacement(rods(2), 2, 3, 2);

% Record load values to file
%loadFile = strcat('out/square_plus_mtheta_h=', num2str(Hs),'_load'); recordLoad(loadFile, rods);

% ==================================================
% ROD PAIRS AND LINKER SPECS
% ==================================================

link = [];

% ==================================================
% MONITORING AND RECORDER SETUP
% ==================================================

% Inspection variables(rod, node, dof)
liveDofs = [1 cnode 3];

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
ana = ana.Integration('euler');
ana = ana.Solver('nr');
ana = ana.Convergence(1e-6, 100);
ana = ana.Constraint('elimination');
ana = ana.Damping('rayleigh', 0.01, 0.001);
ana = ana.TimeSeries(TS);

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

% ==================================================
% EXECUTION
% ==================================================
tic; S = DER(rods, link, ana, vis, mon, rec); toc

% Geometry plot
%figure; for r=1:length(S.Qs); plotRefAndDefGeom(S.Qs{r}(:,1), S.Qs{r}(:,end), r); end