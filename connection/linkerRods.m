function [linkers, connection] = linkerRods(rods, linkspec)
    % Returns linkers rod struct array and connection matrix (used for inserting penalty terms)
    % Doesn't create linker if edge pairs has negative torsional correlation

    % No linker required for single rod case
    if isempty(linkspec); linkers = []; connection = []; return; end

    % Number of actual rods (used for generating linker tag)
    numMainRods = length(rods);

    % Construct the pairs matrix
    pairs = arrayfun(@(i) i.pair, linkspec, 'UniformOutput', false); pairs = vertcat(pairs{:});

    % Check for duplicate rod pairs
    checkDuplicatePairs(pairs);

    % Linker counter
    countLink = 1;

    % Make a cell list of coordinates
    C = arrayfun(@(r) r.points, rods, 'UniformOutput', false);

    % Loop through pairs of rods
    for i = 1:length(linkspec)
        
        % Get rod tags
        [rodATag, rodBTag] = deal(pairs(i, 1), pairs(i, 2)); fprintf("Rod %d and %d: Linker - ", rodATag, rodBTag);

        % Extract rod points
        [ptsA, ptsB] = deal(C{rodATag}, C{rodBTag});

        % Number of points in rod A and B
        [nptsA, nptsB] = deal(size(ptsA, 1), size(ptsB, 1));

        % Find the intersecting point/s coordinate, and their row ids
        [comPts, idsA, idsB] = intersect(ptsA, ptsB, 'rows');

        % Loop through common points
        for j = 1:size(comPts, 1)

            % -------------------------------------------------------------------------------
            %   Schematic of an intersection of rod A and B
            % -------------------------------------------------------------------------------
            %                     Rod B
            %                     |
            %                     o
            %                   | | q+1
            %         Linker 1  ^ ^
            %             --->--| |p,q      p+1 
            % Rod A --- o --->--- o --->--- o -----
            %          p-1        | |-->---   
            %                     ^ ^  Linker 2
            %                     | |
            %                q-1  o
            %                     |
            %
            % -------------------------------------------------------------------------------
            %   Rod A nodes are p-1, p and p+1, Rod B nodes are q-1, q and q+1
            %   The insersection is at (p,q) node. Linker 1 and 2 are placed to join A and B
            % -------------------------------------------------------------------------------
            %
            %
            %   Table: Node pairing                     %   Table: Edge pairing
            % -----------------------------------       % --------------------------
            %   Linker nodes   1      2       3         %   Linker edge   1      2    
            % -----------------------------------       % --------------------------
            %   Linker 1      p-1   p or q   q+1        %   Linker 1      p-1   q
            %   Linker 2      q-1   p or q   p+1        %   Linker 2      q-1   p
            % -----------------------------------       % --------------------------
            %
            % -------------------------------------------------------------------------------

            % Indices of the intersection point (p-th point in A, q-th point in B)
            [p, q] = deal(idsA(j), idsB(j));

            % Generate the connection matrix and linker rods

            if (p > 1) && (q < nptsB) % Check if (p-1)th point in A and (q+1)th point in B exist

                % Determine linker tag
                linkTag = numMainRods + countLink;

                % connStruct(R, r, M, m, N, n, E, e, p)
                e1 = connStruct(rodATag, linkTag, p-1, 1,   p, 2, p-1, 1, linkspec(i).penalty);
                e2 = connStruct(rodBTag, linkTag,   q, 2, q+1, 3,   q, 2, linkspec(i).penalty);
                
                % Insert the edge pair into connection matrix
                connection(countLink, 1) = e1; connection(countLink, 2) = e2;

                % Get linker rod points
                points = [ptsA(p-1,:); ptsA(p,:); ptsB(q+1,:)];

                % Generate the linker rod and insert into linkers matrix
                linkers(countLink) = InitializeRod(points, linkspec(i).section, linkspec(i).material); fprintf("%d ", linkTag);
                
                % Update linker counter
                countLink = countLink + 1;

            end

            if (q > 1) && (p < nptsA) % Check if (q-1)th point in B and (p+1)th point in A exist
                
                % Determine linker tag
                linkTag = numMainRods + countLink;

                % connStruct(R, r, M, m, N, n, E, e, p)
                e1 = connStruct(rodBTag, linkTag, q-1, 1,   q, 2, q-1, 1, linkspec(i).penalty);
                e2 = connStruct(rodATag, linkTag,   p, 2, p+1, 3,   p, 2, linkspec(i).penalty);
                
                % Insert the edge pair into connection matrix
                connection(countLink, 1) = e1; connection(countLink, 2) = e2;

                % Get linker rod points
                points = [ptsB(q-1,:); ptsB(q,:); ptsA(p+1,:)];

                % Generate the linker rod and insert into linkers matrix
                linkers(countLink) = InitializeRod(points, linkspec(i).section, linkspec(i).material); fprintf("%d ", linkTag);

                % Update linker counter
                countLink = countLink + 1;

            end

        end

        fprintf("\n");
        
    end

end

function checkDuplicatePairs(pairs)

    % Sort each row so that [A B] and [B A] become identical
    sorted = sort(pairs, 2);

    % Find unique rows
    [uniquePairs, ~, ids] = unique(sorted, 'rows');

    % Check if any pair appears more than once
    dupCount = accumarray(ids, 1);

    % Find the duplicate pair id
    duplicateIds = find(dupCount > 1);

    if ~isempty(duplicateIds); error('Duplicate pair found: %s', mat2str(uniquePairs(duplicateIds, :))); end
end

function str = connStruct(R, r, M, m, N, n, E, e, p)

    % Returns a struct that stores information about an edge pair (a regular edge and a linker edge)

    % Schematic for an edge pair
    % --------------------------------------
    %
    %  R:  O ============= O    Regular rod
    %      M       E       N
    %
    %  r:  O ============= O    Linker rod
    %      m       e       n
    %
    % --------------------------------------

    s = torsionalCouplingSign(M, N, m, n);

    str = struct(... 
        'R', R, ... % Tag of regular rod R
        'r', r, ... % Tag of linker rod r
        'M', M, ... % First connected node from R
        'm', m, ... % First connected node from r (paired with M)
        'N', N, ... % Second connected node from R
        'n', n, ... % Second connected node from r (paired with N)
        'E', E, ... % Connected edge from R
        'e', e, ... % Connected edge from r (paired with E)
        's', s, ... % Sign for edge coupling, +1 if their positive torsions are in same direction, -1 otherwise
        'p', p  ... % Penalty
        );

end

function val = torsionalCouplingSign(M, N, m, n)
    % Returns +1 if the edges from the main rod (MN edge) has the same positive direction 
    % as the edge from the linker rod (mn edge), returns -1 otherwise
    
    % M, N = nodes tag from main rod
    % m, n = corrensponding nodes tag from linker rod

    % Cheking if tag pairs are increasing or decreasing together (which makes same positive direction for torsion)
    if (M > N && m > n) || (M < N && m < n); val = 1; else; val = -1; end

end