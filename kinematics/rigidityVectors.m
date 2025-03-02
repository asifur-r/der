function [EA, GJ, EIx, EIy] = rigidityVectors(nele, h, w, E, nu)

    % nele = number of elements
    % h = height
    % w = width
    % E = modulus of elasticity
    % nu = Poisson's ratio

    % Height and width vector for each section
    hVec = ones(nele, 1) * h;
    wVec = ones(nele, 1) * w;

    % Voronoization
    hV = 0.5 * [hVec(1); hVec(1:end-1)+hVec(2:end); hVec(end)];
    wV = 0.5 * [wVec(1); wVec(1:end-1)+wVec(2:end); wVec(end)];

    % BENDING

    % Moment of Inertia
    % Ix = wV .* hV.^3 / 12;
    % Iy = hV .* wV.^3 / 12;

    Ix = hV .* wV.^3 / 12;
    Iy = wV .* hV.^3 / 12;

    % Bending rigidity
    EIx = E * Ix;
    EIy = E * Iy;
    
    % TWISTING

    % Shear Modulus
    G = E / (2 * (1 + nu) );

    % Equivalent area at vertices
    AV = hV .* wV;

    % Equivalent moment of inertias at vertices
    J = AV .* (hV.^2 + wV.^2) / 12;

    % Torsional rigidity
    GJ  = G * J;

    % STRETCHING

    % Cross sectional area
    A = ones(nele, 1) * h * w; % m^2

    % Axial rigidity
    EA  = E * A;

    % % Makes rigidity unit
    % EA  = ones(nele, 1);
    % EIx  = ones(nele+1, 1);
    % EIy  = ones(nele+1, 1);
    % GJ  = ones(nele+1, 1);

end