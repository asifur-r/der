clc; clear all; clf; %close all

% Sinsudoidal arch with compliant base
% Apex displacement is applied using sawtooth ramp, then removed
% One pinned boundary changed to roller after second equilibrium

% ==================================================
% SETUP AND PATHS
% ==================================================
derPath = '../'; addpath(genpath(derPath))

% ==================================================    
% MATERIAL AND SECTION PROPERTIES
% ==================================================

% Strip width
w = 5;

% Strip height
h = 0.50;

% Torsional stiffness modifier
Jmod = 1.0;

%sec = Section(width, height, Jmod);
sec1 = Section(w, h, Jmod);
sec2 = Section(2*w, h, Jmod);

%mat = Material(E, nu, rho);
mat = Material(2.2e3, 0.38, 1.2e-6);

% ==================================================
% RODS GENERATION
% ==================================================

% Base length
L = 99; % mm

% Sinusoid height
H = 19; % mm

% Number of vertices (must be odd)
N = 35;

% Sinusoid flat lengths
a = 3; % At ends
b = 7; % Before sinusoid
c = 2; % At center (halfwidth)

% Generate rod coordinates
arch = Profile.FullSinusoid(L, H, N, a, b, c);
base = [arch(:, 1) zeros(N, 2)];

% Generate rods
rods(1) = InitializeRod(arch, sec1, mat);
rods(2) = InitializeRod(base, sec2, mat);

% Optional: Check geometry by plotting
% for r=1:length(rods); plotRefAndDefGeom(rods(r).q0, [], r); end

% ==================================================
% TIME PARAMETERS
% ==================================================

% Time increment (s)
dt = 0.1;

% Final time (s)
tfinal = 10;

% Time series array
ts = [Series('constant', 1) , ...       % For constant supports
      Series('sawtooth', 1, 0, 8), ...  % For prescribed displacements
      Series('rectangle', 1, 0, 8)];    % For EqualDof release of the apex nodes

% Optional: Check time series by plotting
% plotTimeSeries(timeSeriesArray, tstart, tfinal, dt, tnow)
% plotTimeSeries(ts, 0, tfinal, dt, [])

% ==================================================
% RESTRAINT ASSIGNMENT
% ==================================================

% center node
cnode = ceil(N/2);

% Displacement node (the center node in the arch)
dispNode = cnode;

% Restraint(rods, node, dofs, val, timeseries);
rods(2) = Restraint(rods(2), 2, 1:3, 1, 1);
rods(2) = Restraint(rods(2), N-2, 2:3, 1, 1);

% ==================================================
% LOAD OR DISPLACEMENT ASSIGNMENT
% ==================================================

% Prescribed displacement (mm)
D = - H * 2.1;

% Displacement(rods, node, dofs, val, timeseries);
rods(1) = Displacement(rods(1), dispNode, 3, D, 2);


% ==================================================
% ROD PAIRING AND LINKER SPECIFICATION
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
mon = []; % Monitor('iter', perIter, 'step', perStep);

% Recorder
rec = [];

% ==================================================
% ANALYSIS
% ==================================================

% Analysis object
% ana = Analysis('static', tfinal);
ana = Analysis('dynamic', tfinal);
ana = ana.TimeStep('constant', dt);
% ana = ana.TimeStep('adaptive', dt, dtMin, dtMax);
ana = ana.Integration('euler');
% ana = ana.Integration('newmark', 0.75);
ana = ana.Solver('nr');
ana = ana.Convergence(1e-5, 1000, 100); % (tol, maxRes, maxIter)
ana = ana.Constraint('elimination');
% ana = ana.Constraint('penalty', 1e9);
% ana = ana.Damping('viscous', 1e-4);
ana = ana.TimeSeries(ts);
% ana = ana.Parallel(true);

% ==================================================
% EQUAL DOFS SPECIFICATIONS
% ==================================================
% EqualDof(masterRod, masterNode, slaveRod, slaveNode, dofs, penalty, timeSeriesTag)

% Equal dof penalty
kp = 5e1;

% Constraints center 3 nodes of arch apex during applied displacements
ana = ana.EqualDof(1, cnode-1, 1, cnode,   3, kp, 3);
ana = ana.EqualDof(1, cnode-1, 1, cnode+1, 3, kp, 3);

% Binds arch rod and base rod with stiff springs
for i = 1:3
    ana = ana.EqualDof(1, i,     2, i,     1:3, kp, 1); % For left end nodes
    ana = ana.EqualDof(1, N+1-i, 2, N+1-i, 1:3, kp, 1); % For right end nodes
end

% ==================================================
% EXECUTION
% ==================================================
tic; S = DER(rods, link, ana, vis, mon, rec); toc

% Geometry plot
%figure; for r=1:length(S.Qs); plotRefAndDefGeom(S.Qs{r}(:,1), S.Qs{r}(:,end), r); end