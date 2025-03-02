function [n, nele, points, gam, h, w, E, nu, res, fext, loadNodes, loadDofs, loads] = problem_kh()

    % ----------------------------------
    % GEOMETRY
    % ----------------------------------

    % Number of vertices
    n = 5;

    % Number of elements
    nele = n - 1;
    
    % Length/Radius
    %L = 0.1;

    % Profile
    %x = generateStraightLine(L, n);

    % Khalid's rod
    points = [...
        [0 0 0];
        [1.0 0 0];
        [2.0 0.2 0];
        [3.0 0.2 0.2]...
    ];

    % Twist angles
    %gam = zeros(n-1, 1);
    gam = [0 pi/4 pi/4]';

    % ----------------------------------
    % SECTIONAL PROPERTIES
    % ----------------------------------

    % Width
    h = 1e0; % m

    % Height/ Thickness
    w = 1e0; % m

    % ----------------------------------
    % MATERIAL PROPERTIES
    % ----------------------------------
        
    % Young's modulus
    E = 1; % Pa

    % Poissons Ratio
    nu = 0.30;

    % ----------------------------------
    % BOUNDARY CONDITION
    % ----------------------------------

    % Assign local restrain matrix
    res = zeros(n, 4);

    % Fix at left
    %res(1:2, 1:4) = 1;

    % Fix out of plane
    %res(1:n, [3 4]) = 1;

    % ----------------------------------
    % EXTERNAL FORCE
    % ----------------------------------

    % Local external force matrix
    fext = zeros(n, 4);

    % Assign forces to local fext
    loadNodes = [];
    loadDofs = [];
    loads = []; % N

    for i=1:size(loadNodes, 1)
        fext(loadNodes(i), loadDofs(i)) = loads(i);
    end
    
end

