clc; clear all; close all

% Three unit array of sinsudoidal arch with compliant base

% ==================================================
% SETUP AND PATHS
% ==================================================

% Path to DER folder
derPath = '../'; addpath(genpath(derPath))

% ==================================================    
% MATERIAL AND SECTION PROPERTIES
% ==================================================

%sec = Section(width, height);
sec = Section(5, 0.50001);

%mat = Material(E, nu, rho);
mat = Material(2.2e3, 0.38, 1.2e-6);

% ==================================================
% RODS GENERATION
% ==================================================

% Base length
L = 90; % mm

% Sinusoid height
H = 20; % mm

% Number of vertices in one unit (must be odd)
N = 35;

% Number of units
Nunits = 3;

% Flat lengths
a = 1; b = 9; c = 1.0;

% Generate the sinusoid rod
arch = Sinusoid(L, H, N, a, b, c, true);
archSeries = SinusoidSeries(arch, Nunits);
archPoints = archSeries.Points();
rods(1) = InitializeRod(archPoints, sec, mat);

% Generate the base rod
basePoints = [archPoints(:,1) zeros(archSeries.countNodes(), 2)];
sec.w = 2 * sec.w; % Double base width
rods(2) = InitializeRod(basePoints, sec, mat);

% Optional: Check geometry by plotting
% for r=1:length(rods); plotRefAndDefGeom(rods(r).q0, [], r); end

% ==================================================
% TIME PARAMETERS
% ==================================================

% Time increment (s)
dt = 0.5;

% Time assigned for each prescribed displacement
dtDisp = 10;

% Time assigned after each support release
dtSupp = 5;

% Generate Time series array
TS = [];

% Insert the time serires for the prescribed displacements
for i=1:Nunits; TS = [TS, Series('sawtooth', 1, (i-1)*dtDisp, i*dtDisp)]; end

% Time so far
tdisp = i*dtDisp;

% Insert the time serires for the boundary conditions
for i=1:Nunits; tend = tdisp + i*dtSupp; TS = [TS, Series('rectangle', 1, 0, tend)]; end

% Insert time series for equal dof release
TS = [TS, Series('rectangle', 1, 0, tdisp+1)]; % 1s after all units are snapped

% Insert the constant time series
TS = [TS, Series('constant', 1)];

% Final time (s)
tfinal = tend + dtSupp;

% Visual check for the time series
plotTimeSeries(TS, 0, tfinal, dt);

% ==================================================
% RESTRAINT ASSIGNMENT
% ==================================================

% Boundary nodes
bnNodes = flip(archSeries.Joints());

% Time independant boundaries

% Fix the first edge of the first sinusoid
rods(1) = Restraint(rods(1), 1:2, 1:3, 1, length(TS)); % Blocks position of node 1 and 2
rods(1) = Restraint(rods(1), 1, 4, 1, length(TS)); % Blocks rotation of edge 1

% Fix Y (out of plane) of the remaining boundary nodes
rods(1) = Restraint(rods(1), bnNodes(1:end-1), 2, 1, length(TS));

% Time dependant boundaries
for i=1:Nunits; rods(1) = Restraint(rods(1), bnNodes(i), [1 3], 1, Nunits+i); end
    
% ==================================================
% LOAD ASSIGNMENT
% ==================================================

% Prescribed displacement (mm)
D = - H * 2.2;

% Get the arch peaks for prescribed displacements
dispNodes = archSeries.Peaks();

% Assign loads or prescribed displacements
for i=1:Nunits; rods(1) = Displacement(rods(1), dispNodes(i), 3, D, i); end

% ==================================================
% ROD PAIRS AND LINKER SPECS
% ==================================================

link = [];

% ==================================================
% MONITORING AND RECORDER SETUP
% ==================================================

% Inspection variables(rod, node, dof)
liveDofs = [ones(Nunits,1) dispNodes' 3*ones(Nunits,1)];
% liveDofs = [1 dispNodes(1) 3];

% Visual
vis = Visual('deformed', true);%, 'dofs', liveDofs);

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
ana = ana.Convergence(1e-5, 50);
ana = ana.Constraint('elimination');
% ana = ana.Constraint('penalty', 1e9);
% ana = ana.Damping('rayleigh', 0.0001, 0.00001);
ana = ana.TimeSeries(TS);

% Equal dof constraint
kp = 1e7;

% Get the node tags for equal dofs by expanding arch joint nodes by 5
% Note: There are 5 nodes on each side of each joint which are same as the base
eqDofs = expandVector(archSeries.Joints(), 5);

% Between rods
for i = 1:length(eqDofs); ana = ana.EqualDof(1, eqDofs(i), 2, eqDofs(i), 1:3, kp, length(TS)); end

% In rods for symmetric snapping
for i = 1:Nunits
    ana = ana.EqualDof(1, dispNodes(i)-1, 1, dispNodes(i), [1 3], kp, length(TS)-1);
    ana = ana.EqualDof(1, dispNodes(i)-1, 1, dispNodes(i)+1, [1 3], kp, length(TS)-1);
end

% ==================================================
% EXECUTION
% ==================================================
tic; S = DER(rods, link, ana, vis, mon, rec); toc

% Geometry plot
%figure; for r=1:length(S.Qs); plotRefAndDefGeom(S.Qs{r}(:,1), S.Qs{r}(:,end), r); end
