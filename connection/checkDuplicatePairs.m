function duplicate = checkDuplicatePairs(pairs)

    % Sort each pair
    sorted = sort(pairs, 2);

    % Sort the entire matrix to group duplicates together
    sorted = sortrows(sorted);

    % Find unique rows and their indices
    [uniqued, ids, ~] = unique(sorted, 'rows');

    % Check for duplicates
    if size(uniqued, 1) ~= size(sorted, 1)
    
        % Has duplicate pair/s
        dupids = setdiff(1:size(sorted, 1), ids);
        duplicate = sorted(dupids, :);
        
        disp(duplicate)
        error("Duplicate pairs found"); 

    end

end