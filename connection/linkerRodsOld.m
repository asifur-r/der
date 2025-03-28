function [linkers, connection] = linkerRodsOld(rods, linkspec)
    % Returns linkers rod struct array and connection matrix 
    % Doesn't create linker if edge pairs has negative torsional correlation

    % rods = rods sturct
    % linkspec = linker specification struct

    % No linker required for single rod case
    if isempty(linkspec); linkers = []; connection = []; return; end

    % Construct the pairs matrix
    pairs = arrayfun(@(i) i.pair, linkspec, 'UniformOutput', false); pairs = vertcat(pairs{:});
        
    % Check for duplicate rod pairs
    checkDuplicatePairs(pairs);
    
    % Number of actual rods
    numMainRods = length(rods);

    % Number of pairs
    npairs = length(linkspec);

    % Logical vector containing if linker is created (inside loop) between pairs
    hasLinker = false(npairs, 1);

    % Linker counter
    linkerCtr = 1;

    % Use the connection struct to define two edges of the linker
    conn1 = connStruct(); % Holds info on the first edge pair (main rod and a linker)
    conn2 = connStruct(); % Holds info on the second edge pair (the other main rod and the same linker)

    % Schematic for two rods and a linker
    % --------------------------------
    %  Rod A
    %      |
    %      |
    %      O
    %      ||
    %      || conn1
    %      || 
    %      O ======== O ----  Rod B
    %          conn2            
    % --------------------------------

    for i = 1:npairs

        % pqr are the three points of the linker
        % PQR are their counterparts in the regular rods A, B

        % Get tags and struct of the main rods (A, B) associated with current linker
        rodATag = linkspec(i).pair(1); rodA = rods(rodATag);
        rodBTag = linkspec(i).pair(2); rodB = rods(rodBTag);

        % Linker tag (updated inside loop)
        linkTag = numMainRods + linkerCtr;

        % Find the intersection (common) point Q of main rod A and B
        % Q would be either the first or the last node of rod A and B
        [nodeQA, nodeQB] = commonNode(rodATag, rodA.points, rodBTag, rodB.points);
    
        % Get the other connected node and edge for the main rods A, B
        [nodeP, conn1E] = getOtherNodeAndEdge(nodeQA, rodA.n);
        [nodeR, conn2E] = getOtherNodeAndEdge(nodeQB, rodB.n);
  
        % Define the first connection (Rr-Ee-Mm-Nn pairs)

        conn1.R = rodATag;
        conn1.r = linkTag;
        conn1.E = conn1E;
        conn1.e = 1;
        conn1.M = nodeP;
        conn1.m = 1;
        conn1.N = nodeQA;
        conn1.n = 2;
        conn1.s = torsionalCouplingSign(conn1.M, conn1.N, conn1.m, conn1.n);
        conn1.p = linkspec(i).penalty;

        % Define the second connection (Rr-Ee-Mm-Nn pairs)

        conn2.R = rodBTag;
        conn2.r = linkTag;
        conn2.E = conn2E;
        conn2.e = 2;
        conn2.M = nodeQB;
        conn2.m = 2;
        conn2.N = nodeR;
        conn2.n = 3;
        conn2.s = torsionalCouplingSign(conn2.M, conn2.N, conn2.m, conn2.n);
        conn2.p = linkspec(i).penalty;

        % Skip processing the linker if either edge pair has a negative torisional correlation
        assert(conn1.s == 1, "Negative edge pair occured between rod %d and linker %d", conn1.R, conn1.r);
        assert(conn2.s == 1, "Negative edge pair occured between rod %d and linker %d", conn2.R, conn2.r);

        % Insert the connections into connection matrix
        connection(linkerCtr, 1) = conn1; connection(linkerCtr, 2) = conn2;

        % Get coordinates for points p, q, r
        p = rodA.points(nodeP, :); % Point p From rod A
        q = rodA.points(nodeQA, :);% The common point q (either from rod A or B)
        r = rodB.points(nodeR, :); % Point r From rod A

        % Generate the linker coordinates
        points = [p; q; r];

        % Generate the linker rod and insert into linkers matrix
        linkers(linkerCtr) = InitializeRod(points, linkspec(i).section, linkspec(i).material);

        % Update linker tag
        linkerCtr = linkerCtr + 1;
        
        % Update
        hasLinker(i) = true;

    end

    %disp("Linkers created between:"); pairs(hasLinker, :)
    %disp("Linkers NOT created between:"); pairs(~hasLinker, :)

end

function str = connStruct()

    % Returns the struct that stores information of which regular rod is connected to which linker,
    % regular rod node to linker node connectivity and rod edge to linker edge connectivity

    str = struct(... 
        'R', [], ... % Tag of regular rod R
        'M', [], ... % First connected node from R
        'N', [], ... % Second connected node from R
        'E', [], ... % Connected edge from R
        ...
        'r', [], ... % Tag of linker rod r
        'm', [], ... % First connected node from r (paired with M)
        'n', [], ... % Second connected node from r (paired with N)
        'e', [], ... % Connected edge from r (paired with E)
        ...
        'p', [], ... % Penalty
        's', []  ... % Sign for edge coupling, +1 if their positive torsions are in same direction, -1 otherwise
        );

    % Schematic for one edge pair
    % --------------------------------
    %
    %  R:  O ============= O
    %      M       E       N
    %
    %  r:  O ============= O
    %      m       e       n
    %
    % --------------------------------

end

function [node, edge] = getOtherNodeAndEdge(nodeQ, rod_n)
    % Returns the other connected node and the connected edge

    % nodeQ = the common node between the main rod and the linker (should be either 1 or N)
    % rod_n = number of nodes in the rod (the usual N)
    
    % If nodeQ is the first node of rod
    if nodeQ == 1

        node = 2; % Then node 2 is the other connected node
        edge = 1; % First edge is the connected edge
        
    % If nodeQA is the last node of rod
    elseif nodeQ == rod_n

        node = rod_n-1; % The node before the last node is the other connected node
        edge = rod_n-1; % Last edge is the connected edge

    end

end

function val = torsionalCouplingSign(M, N, m, n)
    % Returns +1 if the edges from the main rod (MN edge) has the same positive direction 
    % as the edge from the linker rod (mn edge), returns -1 otherwise
    
    % M, N = nodes tag from main rod
    % m, n = corrensponding nodes tag from linker rod

    % Cheking if tag pairs are increasing or decreasing together (which makes same positive direction for torsion)
    if (M > N && m > n) || (M < N && m < n); val = 1; else; val = -1; end

end