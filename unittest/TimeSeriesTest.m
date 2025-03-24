clc; clear; close;

% Time step size
dt = 0.1;

% Time range
t = 0:dt:10;

tcurr = 3.5;

% Series(tag, type, value, params);
C = Series('constant', 2) ;
L = Series('linear', 1, 2, 5);
T = Series('trapezoidal', 3, 3, 4, 5, 7);

TS = [C, L, T];

% External force vector
Fext = [1 5 10 2]';

% Time series tags for Fext
FextTag = [1 2 2 3]';

% Compute scaling factors (vectorized)
% Inner arrayfun loops over the time vector, outer one loops over tags, then converts the cells to a matrix
% forceFactors = cell2mat(arrayfun(@(ids) arrayfun(@(tcurr) TS(ids).GetValue(tcurr), t), FextTag, 'UniformOutput', false));
forceFactors = cell2mat(arrayfun(@(ids) TS(ids).GetValue(tcurr), FextTag, 'UniformOutput', false));

% Compute the scaled force (element-wise multiplication)
Fext_scaled = (Fext .* forceFactors)';
hold on
arrayfun(@(i) plot(tcurr, Fext_scaled(:, i), 'o'), 1:length(Fext))

forceFactors = cell2mat(arrayfun(@(ids) arrayfun(@(tcurr) TS(ids).GetValue(tcurr), t), FextTag, 'UniformOutput', false));
Fext_scaled = (Fext .* forceFactors)';

% Plot
hold on
arrayfun(@(i) plot(t, Fext_scaled(:, i)), 1:length(Fext))
legend