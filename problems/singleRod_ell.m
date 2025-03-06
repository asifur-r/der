clc; clear; clf; %close all

% Single rod of L shaped, left end fixed, one torional moment applied at the first leg or the second leg
% Units: N, mm, kg

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
M = 3000.0; % Torsional moment

% --------------------------------------------------    
% SECTION PROPERTIES
% --------------------------------------------------

% Width
w = 5; % mm

% Height / Thickness
h = 5; % mm

% Rectangular section
sec = Section(w, h);

% --------------------------------------------------
% MATERIAL PROPERTIES
% --------------------------------------------------

% Young's modulus
E = 2.2e3; % N/mm2

% Poissons Ratio
nu = 0.38;

% Density
rho = 1.2e-6; % kg/mm3

% PETG material
mat = Material(E, nu, rho);

% --------------------------------------------------
% RODS GENERATION
% --------------------------------------------------

% Rod length
L = 100; % mm

% Number of vertices
N = 20;

% Generate base rods along X-axis
points = ell(L, N);
rods(1) = InitializeRod(points, sec, mat);

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
%rods(1) = PointLoad(rods(1), 7, 4, M); % At the first leg
rods(1) = PointLoad(rods(1), 15, 4, M/5); % At the second leg

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
penalty = 1e5; EMod = 10.0; mat.E = mat.E*EMod; linkspec = linker(sec, mat, penalty);

% --------------------------------------------------
% MONITORING SETUP
% --------------------------------------------------

% Inspection rods (rod, node, dof)
inspSpecs = [1 N-1 4; 1 10 4];

% Visual
vis= visual(inspSpecs, 'off', 'off', 'off');

% Monitor
perIter = ''; perStep = ''; mon = monitor('iter', perIter, 'step', perStep);

% Recorder
%dispSpecs = [(1:8)' ones(8,1)*Nb-1 ones(8,1)*4];

% Recorder
%dispFile = strcat('out/square_plus_pdelta_h=', num2str(Hs),'_disp'); 

rec = [];%record(dispFile, dispSpecs);

% --------------------------------------------------
% ANALYSIS
% --------------------------------------------------

% Analysis parameters (solver, incr, maxiter, tol)
ana = analysis('nr', 0.01, 100, 1e-4);

% Call driver
tic; S = driver(rods, pairs, linkspec, ana, vis, mon, rec); toc

% Geometry plot
%figure; for r=1:length(S.Qs); plotRefAndDefGeom(S.Qs{r}(:,1), S.Qs{r}(:,end), r); end