function pairs = rodPairsNew(rods)
    % Returns a two column matrix defining rod pairs

    % Exit for single rod case
    if isscalar(rods); pairs = []; return; end

    % Number of rods
    nrods = length(rods);

    % Make a cell list of coordinates
    C = cell(nrods, 1); for i = 1:nrods; C{i} = rods(i).points; end

    % Generate all possible combinations
    com = nchoosek(1:nrods, 2);

    % Check for intersections among rods and create a logical indices
    hasIntersection = arrayfun(@(i) ~isempty(intersect(C{com(i, 1)}, C{com(i, 2)}, 'rows')), 1:size(com, 1));

    % Extract only the pairs which has intersection
    pairs = com(hasIntersection, :);

    % Check for unparired rod
    paired = unique(pairs); unpaired = setdiff(1:nrods, paired);
    assert(isempty(unpaired), "Unparied rod/s id: %s", mat2str(unpaired));

end