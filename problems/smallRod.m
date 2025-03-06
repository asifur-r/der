clc; clear all; close all
%C:\Users\asifu\Dropbox\sbu\research\phd\discrete-elastic-rod\revised_der\problems

% --------------------------------------------------
% SETUP, PATHS
% --------------------------------------------------

% Path to DER folder
derPath = '../'; addpath(genpath(derPath))

% --------------------------------------------------
% RODS GENERATION
% --------------------------------------------------

%sec = Section(width, height);
sec = Section(5, 5);

%mat = Material(E, nu, rho);
mat = Material(2.2e3, 0.38, 1.2e-6);

% Rod length
L = 100; % mm

% Number of vertices
N = 10;

% Generate base rods along X-axis
points = [linspace(0, L, N)' zeros(N, 2)];
rods(1) = InitializeRod(points, sec, mat);

% Optional: Check geometry by plotting
%for r=1:length(rods); plotRefAndDefGeom(rods(r).q0, [], r); end

% --------------------------------------------------
% LOAD, RESTRAINTS
% --------------------------------------------------

% Load (N or Nmm)
P = 50;

% Displacement (mm)
D = 50;

% Assign restraints
% rods(id) = Restraint(rods(id), node, dof, val, tstag);
rods(1) = Restraint(rods(1), 1:2, 1:3, 1, 1);
rods(1) = Restraint(rods(1), 1, 4, 1, 1);

% Assign loads
% rods(id) = PointLoad(rods(id), node, dof, val, tstag);
rods(1) = PointLoad(rods(1), N, 3, P, 2);
% rods(1) = Displacement(rods(1), N, 3, D, 3);
% rods(1) = Displacement(rods(1), N,   2, D/2);
% rods(1) = Displacement(rods(1), N,   3, D  );
% rods(1) = Displacement(rods(1), N-1, 4, D/30);

% Define linker specifications
linkspec = [];

% --------------------------------------------------
% MONITOR
% --------------------------------------------------

% Inspection variables(rod, node, dof)
liveDofs = [1 N 3];

% Visual
vis = Visual('dofs', liveDofs, 'deformed', true);

% Monitor
mon = [];%Monitor('iter', 'sol.t', 'step', 'sol.lam');

% Recorder
rec = [];%Record('dispfile', 'disp.txt', 'dispdofs', [1 N 3]);
% rec = Record('forcefile', 'force.txt', 'forcedofs', [1 N 3]);

% --------------------------------------------------
% ANALYSIS
% --------------------------------------------------

% Analysis object
% ana = Analysis('static', 10, 0.1);
ana = Analysis('dynamic', 10, 1);

% Integration
ana = ana.Integration('euler');
% ana = ana.Integration('newmark', 0.75);

% Solver
ana = ana.Solver('nr');
% ana = ana.Solver('mgdm');

% Convergence
ana = ana.Convergence(1e-4, 100);

% Constraint
ana = ana.Constraint('elimination');
% ana = ana.Constraint('penalty', 1e8);

% Damping
ana = ana.Damping('rayleigh', 0.01, 0.001);

% Time series
ana = ana.TimeSeries([Series('constant', 1), Series('linear', 1, 0, 4), Series('linear', 1, 5, 10)]);
% ana = ana.TimeSeries([Series('constant', 1), Series('triangular', 1, 1, 4, 8)]);

% --------------------------------------------------

% Call DER
tic; S = DER(rods, linkspec, ana, vis, mon, rec); toc
