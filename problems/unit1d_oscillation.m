clc; clear all; close all

% Asifur Rahman
% asifur.rahman@stonybrook.edu

% MODEL:
% A sinusoidal arch rod connected to a straight base rod in XZ plane.
% Harmonic displacement is applied to the arch’s left end along Z.
% Z Displacement at the arch’s right end is recorded over time.

% ==================================================
% SETUP AND PATHS
% ==================================================
derPath = '../'; addpath(genpath(derPath))

% ==================================================    
% MATERIAL AND SECTION PROPERTIES
% ==================================================

% Strip width
w = 5; % mm

% Strip height
h = 0.50; % mm

% Torsional stiffness modifier
Jmod = 1.0;

% sec = Section(width, height, Jmod);
archSec = Section(w, h, Jmod);
baseSec = Section(2*w, h, Jmod); % Wider base rod

% mat = Material(E, nu, rho);
mat = Material(2.2e3, 0.38, 0); % actual rho = 1.2e-6 kg/mm3, mass added later

% ==================================================
% RODS GENERATION
% ==================================================

% Base length
L = 100; % mm

% Sinusoid height
H = 20; % mm

% Number of vertices (must be odd)
N = 35;

% Sinusoid flat lengths
a = 3; % Initial flat zone
b = 7; % Pre-sinusoid flat zone
c = 2; % Flat region at sinusoid apex (half)

% Generate rod coordinates
archPts = Profile.FullSinusoid(L, H, N, a, b, c);
basePts = [archPts(:, 1) zeros(N, 2)]; % Makes base x coordinates same as the arch

% Initialize rods struct
arch = InitializeRod(archPts, archSec, mat);
base = InitializeRod(basePts, baseSec, mat);

% Optional: Check geometry by plotting
plotRefAndDefGeom(arch.q0, [], []); 
plotRefAndDefGeom(base.q0, [], []);

% ==================================================
% TIME PARAMETERS
% ==================================================

% Time increment
dt = 0.05; % s

% Final time
tf = 20; % s

% Time series default value
tsVal = 1;

% Series('constant', val)
tsConst = Series('constant', tsVal); % For boundary and equaldof springs

% Series('sinusoid', val, tstart, tend, period, phaseShift)
tsSin = Series('sinusoid', tsVal, 1, 5, 2, 0); % For prescribed displacement

% Series('rectangle', val, tstart, tend)
tsRect = Series('rectangle', tsVal, 5, tf+1); % For constraining the left end when tsSin ends

% Time series array
ts = [tsConst tsSin tsRect];

% Optional: Check time series by plotting

% plotTimeSeries(timeSeriesArray, tstart, tfinal, dt, tnow)
figure; plotTimeSeries(ts, 0, tf, dt, [])

% ==================================================
% MASS ASSIGNMENT
% ==================================================

% Mass
m = 1e-4; % kg

% Mass(rod, nodes, dofs, vals);
arch = Mass(arch, N, 3, m); % Assigns m to 3rd dof of the N-th node of arch

% ==================================================
% RESTRAINT ASSIGNMENT
% ==================================================
% Restraint(rod, nodes, dofs, vals, timeSeriesTag);

% Fix X and Y of the first two nodes (Y is out of plane)
base = Restraint(base, 1:2, 1:2, 1, 1);

% Fix rotation of the first edge
base = Restraint(base, 1, 4, 1, 1);

% Fix Z of the first node (activates when harmonic osillation stops)
base = Restraint(base, 1, 3, 1, 3);

% ==================================================
% LOAD OR DISPLACEMENT ASSIGNMENT
% ==================================================

% Amplitude for the harmonic osillation
D = 2; % (mm)

% Applies harmonic oscillation to the first node in Z
% Displacement(rod, nodes, dofs, vals, timeseries);
base = Displacement(base, 1, 3, D, 2);

% ==================================================
% ROD PAIRING AND LINKER SPECIFICATION
% ==================================================

% Make an array from arch and base rod
rods = [arch base];

% Linker
link = []; % No linker required

% ==================================================
% LIVE PLOT, MONITORING AND RECORDER SETUP
% ==================================================
% Variables to capture are structured as
% [rod1, node1, dof1; rod2 node2 dof2; ...] format

% Live plot: Plots that are displayed during analysis

% Live plot dofs 
liveDofs = [1 1 3; 1 N 3];

% Live plot variable
% liveVar = 'forcedisp'; % Plots internal force vs disp
liveVar = 'timehistory'; % Plots time vs disp

% Visual
vis = []; % No live plot during analysis (faster execution)
% vis = Visual('dofs', liveDofs, 'deformed', true, 'variable', liveVar); figure

% Monitor: Displays internal variables during analysis
mon = []; % No monitor

% Recorder: Saves output in a file
rec = Record('out'); % Recorder(folderPath);

% Recorder dofs
recDofs = [1 1 3; 1 N 3]; % Z dofs of the first and last node of the arch

% Specify disp and force files
rec = rec.Displacement('disp', recDofs);
% rec = rec.Force('force', recDofs);

% ==================================================
% ANALYSIS
% ==================================================

% Analysis object
% ana = Analysis('static', tf);
ana = Analysis('dynamic', tf);
ana = ana.TimeStep('constant', dt);
% ana = ana.TimeStep('adaptive', dt, dtMin, dtMax);
ana = ana.Integration('euler');
% ana = ana.Integration('newmark', 0.5); % ('newmark', beta)
ana = ana.Solver('nr');
ana = ana.Convergence(1e-5, 1000, 100); % (tol, maxResidual, maxIter)
ana = ana.Constraint('elimination');
% ana = ana.Constraint('penalty', 1e9);
% ana = ana.Damping('viscous', 1e-4);
ana = ana.TimeSeries(ts);
% ana = ana.Parallel(true);

% ==================================================
% EQUAL DOFS SPECIFICATIONS
% ==================================================
% Equal dofs are used to couple two ders with stiff springs

% Equal dof penalty
kp = 5e1;

% Number of spring pairs on each side
nspr = 3;

% Couple left and right end nodes of arch and base rods
for i = 1:nspr
    % EqualDof(masterRod, masterNode, slaveRod, slaveNode, dofs, penalty, timeSeriesTag)
    ana = ana.EqualDof(1, i,     2, i,     1:3, kp, 1); % For left end node pairs
    ana = ana.EqualDof(1, N+1-i, 2, N+1-i, 1:3, kp, 1); % For right end node pairs
end

% ==================================================
% EXECUTION
% ==================================================

tic; S = DER(rods, link, ana, vis, mon, rec); toc

% ==================================================
% POST-PROCESSING (OPTIONAL)
% ==================================================

% FORCE DISPLACEMENT PLOT

% Loads the output files
% disp = load(rec.Path('disp'));
% force = load(rec.Path('force'));

% column 1 = time, column 2 to column N are defined by recDofs
% figure; plot(-disp(:,2), -force(:,2), '-ob'); 
% xlabel('Disp.'); 
% ylabel('Force')

% TIME HISTORY PLOT

% Loads the output file
disp = load(rec.Path('disp'));

% column 1 = time, column 2 to column N are defined by recDofs
figure; hold on;
plot(disp(:,1), -disp(:,2), '-ob');
plot(disp(:,1), -disp(:,3), '-or');

xlabel('Time'); 
ylabel('Disp.');
legend('Node 1', 'Node N')

% GEOMETRY PLOT

% plotRefAndDefGeom(refPts, defPts)
%figure; for r=1:length(S.Qs); plotRefAndDefGeom(S.Qs{r}(:,1), S.Qs{r}(:,end), r); end

% DISPLAY ANIMATION

% makeAnimation(solution, tstepStart, tstepEnd, tstepSkip, saveMovie)
% figure; makeAnimation(S, 1, length(S.T), 5, false)