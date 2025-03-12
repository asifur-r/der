clc; clear all; clf

% Number of nodes
N = 20;

% Length of each leg
L = 10;

% Just some zero vectors
z = zeros(1, N/2);

% Generate points for legs
leg1 = [linspace(1, L, N/2); z; z;];
leg2 = [L*ones(1, N/2); leg1(1,:); leg1(3,:)];

% Insert into struct
rods = struct;
rods(1).points = flip([leg1 leg2]');
rods(2).points = Geometry.TranslateByVector(Geometry.RotateByAngle(rods(1).points, [0 0 1], pi), [1.5*L L/2 0]);
%rods(3).points = [linspace(1, 2*L, N)' 3*ones(N, 1) zeros(N, 1)] ;

% (1) Two lines intersecting at intermediate points ('X' shape)
% N = 11; % Must be odd
% rods(1).points = [linspace(0, 3, N)', linspace(0, 3, N)', zeros(N, 1)];
% rods(2).points = [linspace(0, 3, N)', linspace(3, 0, N)', zeros(N, 1)];

% (2) Two lines intersecting at intermediate point of one and end of another ('T' shape)
% N = 11;
% rods(1).points = [linspace(0, 3, N)', zeros(N, 1), zeros(N, 1)];
% rods(2).points = flip([1.5*ones(N, 1), linspace(-1, 0, N)', zeros(N, 1)]);

% (3) Two lines intersecting at end points ('L' shape)
% N = 20; % Even
% rods(1).points = [linspace(0, 1, N)', zeros(N, 1), zeros(N, 1)];
% rods(2).points = [zeros(N/2, 1), linspace(-1, 0, N/2)', zeros(N/2, 1)];

% (5) Three lines intersecting at multiple points
% rods(1).points = [linspace(0, 4, N)', zeros(N, 2)];
% rods(2).points = flip(Geometry.RotateByAngle(rods(1).points, [0 0 1], pi/3));
% rods(3).points = Geometry.TranslateByVector(Geometry.RotateByAngle(rods(1).points, [0 0 1], 2*pi/3), [4, 0 0]);

% Define parameters
% t = linspace(0, 2*pi, 40)'; % Parameter for wavy lines

% % First wavy line
% x1 = t;
% y1 = sin(t);
% line1 = [x1, y1, 0*t];

% % Second wavy line (shifted and rotated)
% x2 = t - pi/2;  % Shift in x-direction
% y2 = sin(t + pi/3); % Phase shift in y
% line2 = [x2, y2, 0*t];

% % Insert intersection points into both lines
% line2(32, :) = line1(22, :);
% line2(12, :) = line1(3, :);

% rods(1).points = line1;
% rods(2).points = line2;

% Apply rounding to coordinates
C = arrayfun(@(r) round(r.points, 6), rods,'UniformOutput', false);

% Points array
rods = cell2struct(C, 'points');

% Plot
hold on; axis equal; for r=1:length(rods); plotRod(rods(r).points, false, r); end

% Get pairs
pairs = rodPairsNew(rods);

% Define linker
link = linker(pairs, Section(1,1), Material(1,1,1), 1);

[linkers, conn] = linkerRodsNew(rods, link);

m = arrayfun(@(c) [c.R c.r c.M c.m c.N c.n c.E c.e c.s NaN], conn, 'UniformOutput', false);
cell2mat(m)

% Plot linkers
for r=1:length(linkers); plotRod(linkers(r).points, true, r); end


% (1) Two lines intersecting at intermediate points ('X' shape)
line1_X = [linspace(0, 3, 12)', linspace(0, 3, 12)', zeros(12, 1)];
line2_X = [linspace(0, 3, 12)', linspace(3, 0, 12)', zeros(12, 1)];
common_X = [2 1 0]; % Common point (approximate)

% % (2) Two lines intersecting at intermediate point of one and end of another ('T' shape)
% line1_T = [linspace(0, 3, 15)', zeros(15, 1), zeros(15, 1)];
% line2_T = [2 * ones(15, 1), linspace(-1, 1, 15)', zeros(15, 1)];
% common_T = [2 0 0]; % Common point

% % (3) Two lines intersecting at end points ('L' shape)
% line1_L = [linspace(0, 2, 8)', zeros(8, 1), zeros(8, 1); 2 * ones(8, 1), linspace(1, 2, 8)', zeros(8, 1)];
% line2_L = [zeros(8, 1), linspace(0, 2, 8)', zeros(8, 1); linspace(1, 2, 8)', 2 * ones(8, 1), zeros(8, 1)];
% common_L = [2 2 0]; % Common point

% % (4) Two lines intersecting at two points
% line1_2pts = [linspace(0, 4, 20)', linspace(0, 4, 20)', zeros(20, 1)];
% line2_2pts = [linspace(1, 5, 20)', linspace(1, -1, 20)', zeros(20, 1)];
% common_2pts = [1 1 0; 2 2 0]; % Common points

% % (5) Three lines intersecting at multiple points
% line1_3lines = [linspace(0, 4, 18)', linspace(0, 4, 18)', zeros(18, 1)];
% line2_3lines = [linspace(1, 5, 18)', [linspace(1, 3, 9), linspace(3, 1, 9)]', zeros(18, 1)];
% line3_3lines = [2 * ones(18, 1), linspace(0, 4, 18)', zeros(18, 1)];
% common_3lines = [1 1 0; 2 2 0; 3 3 0]; % Common points

% % (6) Open curved lines intersecting (sin curve and bezier curves)
% t = linspace(0, 4*pi, 20); % Parameter for sin curve
% line1_curve = [t', sin(t)', zeros(size(t'))]; % Sin curve

% % Bezier curve 1
% controlPoints1 = [0 0; 2 3; 4 1; 6 4]; % Control points for Bezier curve
% t_bezier1 = linspace(0, 1, 20);
% line2_curve = bezierCurve(controlPoints1, t_bezier1);

% % Bezier curve 2
% controlPoints2 = [1 2; 3 -1; 5 0; 7 -2]; % Control points for Bezier curve
% t_bezier2 = linspace(0, 1, 20);
% line3_curve = bezierCurve(controlPoints2, t_bezier2);

% % Find approximate intersection points for curves (for intersection detection algorithm testing)
% % Approximate based on visual inspection from plotting. Adjust as needed.
% common_curves = [3.1416 0 0; 4.5 1.5 0; 5.5 0 0]; % Approximate common points

% % Bezier curve function
% function curvePoints = bezierCurve(controlPoints, t)
%     n = size(controlPoints, 1) - 1;
%     curvePoints = zeros(length(t), 3);
%     for i = 1:length(t)
%         point = [0 0 0];
%         for j = 0:n
%             bernstein = nchoosek(n, j) * t(i)^j * (1 - t(i))^(n - j);
%             point = point + bernstein * [controlPoints(j + 1, :), 0]; % Add z=0
%         end
%         curvePoints(i, :) = point;
%     end
% end


function plotRod(coordinates, isLinker, tag)
    % Plots a rod defined by a coordinate matrix with arrows in the middle of each edge.
    %
    % Input:
    %   coordinates - Nx3 matrix, where each row is [x, y, z] coordinate of a point.

    persistent nCalls;
    persistent colorList;

    if isempty(coordinates)
        return; % Nothing to plot
    end

    if isempty(nCalls)
        nCalls = 0;
        colorList = ['r', 'g', 'b', 'c', 'm', 'y']; % Define color list
    end

    nCalls = nCalls + 1;
    colorId = mod(nCalls - 1, length(colorList)) + 1; % Cycle through colors
    currentColor = colorList(colorId);

    if isLinker == true; lineWidth = 5; else; lineWidth = 2; currentColor = 'k'; end

    % Plot the points and lines
    plot3(coordinates(:, 1), coordinates(:, 2), coordinates(:, 3), [currentColor, 'o-'], 'MarkerSize', 5, 'LineWidth', lineWidth);
    hold on; % Keep the current plot

    % Add arrows at 30% distance along each edge
    for i = 1:size(coordinates, 1) - 1
        p1 = coordinates(i, :);
        p2 = coordinates(i + 1, :);

        % Calculate edge direction and length
        direction = p2 - p1;
        length_edge = norm(direction);

        % Normalize direction
        if length_edge > 0
            direction = direction / length_edge;
        end

        % Calculate arrow start point (30% along the edge)
        arrow_start = p1 + direction * (0.3 * length_edge);

        % Scale arrow length (adjust as needed)
        arrow_length = length_edge * 0.4; % Make arrow 30% of the segment length

        % Plot the arrow
        quiver3(arrow_start(1), arrow_start(2), arrow_start(3), direction(1), direction(2), direction(3), arrow_length, 'k', 'LineWidth', lineWidth, 'MaxHeadSize', 100);
    end

    if isLinker == true; txt = sprintf('Linker %d', tag); else txt = sprintf('Rod %d', tag); end
    text(coordinates(1,1), coordinates(1,2)-0.2, txt, "FontSize", 8)

    grid on;
    % view(30, 45); % Adjust view angle as needed
    % hold off; % Release hold

    for i=1:size(coordinates, 1); text(coordinates(i,1)+0.1, coordinates(i,2)+0.1, num2str(i), "FontSize", 8); end

end