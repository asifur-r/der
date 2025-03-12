function [i, j, v, count] = addSparseBlock(i, j, v, count, rows, cols, vals)
    % Efficiently adds a block to sparse triplet format
    
    % Construt the indices pairs
    %[r, c] = ndgrid(rows, cols);

	% Same thing with repmat
	r = repmat(rows', 1, length(cols));
	c = repmat(cols, length(rows), 1);

    % Number of items to insert
    n = numel(r);

    % Indices range
    p = count + 1;
    q = count + n;
    
    % Assign
    i(p:q) = r(:);
    j(p:q) = c(:);
    v(p:q) = vals(:);

    % Update counter
    count = count + n;

end