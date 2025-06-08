function mdiag = massDiagonal(nele, enormbar, h, w, rho)
    % Returns the lumped masses for each dof in a column vector, NOT in a matrix
    % This is the main diagonal of the full sized mass matrix of a single rod, See Eq. 8.10

    % nele = number of elements
    % enormbar = element length vector in reference configuration
    % h = height
    % w = width
    % rho = material denstiy

    % Cross sectional area
    A = ones(nele, 1) * h * w; % m^2

    % Mass associated with edges (Eq. 8.6)
    Msup = rho * A.* enormbar; % M superscript

    % Mass associated with vertice  (Eq. 8.5)
    Msub = 0.5 * [Msup(1); Msup(2:end) + Msup(1:end-1); Msup(end)]; % M subscript

    % Mass moment of inertia of the edges (Eq. 8.9)
    rhoI = Msup * (h^2 / 12 + w^2 / 12);

    % Add an extra last item (will be drop later) to make same size of Msup
    rhoI = [rhoI; NaN];

    % A temporary matrix where row 1,2,3 are Msubs and row 4 is rhoI terms
    temp = [repmat(Msub, 1, 3) rhoI]';

    % Now just flatten the matrix to get the diagonal
    mdiag = temp(:);

    % Drop the last NaN
    mdiag(end) = [];

end