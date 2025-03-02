function pairs = rodPairs(rods, roundTol)

    % Exit for single rod case
    if length(rods) == 1; pairs = []; return; end

    % Number of rods
    nrods = length(rods);

    % Make a cell list of coordinates
    C = cell(nrods, 1); for i = 1:nrods; C{i} = round(rods(i).points, roundTol); end
    
    % Two column matrix to store intersecting pairs
    pairs = [];
    
    % Two column matrix to store which node from each rod is the intersection
    comPtsId = [];

    % Loop through all pairs of coordinate matrix
    for i = 1:nrods
        for j = i+1:nrods

            % Find the intersecting (common) point/s coordinate, and row ids of both rods
            [comPts, rowI, rowJ] = intersect(C{i}, C{j}, 'rows');
            
            % Number of common points
            nComPts = size(comPts, 1);
            
            % Check for multi point intersection
            assert(nComPts <= 1, "Rods %d and %d has multiple intersection", i, j);

            % Add the intersecting pair to the list if found
            if nComPts == 1; pairs = [pairs; i, j]; comPtsId = [comPtsId; rowI, rowJ]; end

        end
    end
    
    % By default rod pairs are automatically sorted
    
    % Validate the pairs before returning
    pairs = validatePairs(rods, pairs, comPtsId);

end

function pairs = validatePairs(rods, pairs, comPtsId)

    % Validates the pairs by checking that each pair yields a positive linker
    % Also checks every rod is paired with at least one rod (not a lone wolf)

    % Number of rods
    nrods = length(rods);

    % Check each rod has at least one intersecting pair (not a lone wolf)
    allRodsId = 1:nrods;
    paired = unique(pairs);
    unpaired = setdiff(allRodsId, paired);
    assert(isempty(unpaired), "Unparied rod/s found: %s", mat2str(unpaired));

    % Sorting pairs but should be sorted anyway
    pairs = sortrows(pairs);

    % Number of pairs
    npairs = size(pairs, 1);

    % Logical vector if i-th pair is valid
    isvalid = false(npairs, 1);
    
    for i=1:npairs

        %fprintf("Checking rod %d, %d. ", pairs(i, 1), pairs(i, 2));

        % Get rods struct
        rodA = rods(pairs(i, 1));
        rodB = rods(pairs(i, 2));

        % Extract which point is the intersection point
        rodAPtId = comPtsId(i, 1);
        rodBPtId = comPtsId(i, 2);

        %fprintf("Intersects at %d, %d. ", rodAPtId, rodBPtId);

        % Check intersecting point position
        if rodAPtId == rodA.n && rodBPtId == 1 % if first point of rod A, and last point of rod B
            isvalid(i) = true; %fprintf("GOOD. \n");

        elseif rodAPtId == 1 && rodBPtId == rodB.n % if last point of rod A, and first point of rod B 
            isvalid(i) = true;
            
            % Flip the order
            pairs(i,:) = flip(pairs(i,:)); %fprintf("Flipped rod %d and %d. Now GOOD\n", pairs(i, 1), pairs(i, 2));
        else
            %fprintf("BAD.\n");
        end
        
    end

    validPairs = pairs(isvalid, :); %disp("Valid pairs:"); validPairs
    notValidPairs = pairs(~isvalid, :); %disp("Not valid pairs:"); notValidPairs

    % Return
    pairs = sortrows(validPairs);

end