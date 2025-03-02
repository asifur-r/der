function mat = straightLine(L, n, a, b)

    % L = length
    % n = Number of nodes
    % a = location of the 2nd point from left
    % b = location of the 2nd point from right

    eN = n - 2;
    eL = L - b;
    vec = [0 linspace(a, eL, eN) L];
    mat = [vec' zeros(n,1) zeros(n,1)];
    
end