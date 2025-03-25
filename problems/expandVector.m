function expanded_v = expandVectorElements(v, n)
    % expandVector Expands each element in v by n on each side
    %
    % Inputs:
    %   v - Input vector
    %   n - Number of elements to expand on each side
    %
    % Output:
    %   expanded_v - Expanded vector
    %
    % Example:
    % expandVectorElements([1 35 69 103], 2) would return
    % expanded_v = [(1) 2 3, 33 34 (35) 36 37, 67 68 (69) 70 71, 101 102 (103)]
    % The key values are shown in parenthesis, and the expanded group is separated by comma

    expanded_v = []; % Initialize empty array
    
    for i = 1:numel(v)
        if i == 1
            range = v(i) : v(i) + n; % Expand only on the increasing side
        elseif i == numel(v)
            range = v(i) - n : v(i); % Expand only on the decreasing side
        else
            range = v(i) - n : v(i) + n; % Expand on both sides
        end
        expanded_v = [expanded_v, range]; % Append to the result
    end

    expanded_v = unique(expanded_v); % Ensure unique elements (optional)
end