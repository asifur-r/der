function vec = vertCat(structArray, fieldName)
    % Takes a stuct array and returns a single vector by stracking the 'field' across array items

    % Check if the field exists in the struct
    if ~isfield(structArray, fieldName); error('Field "%s" does not exist in the struct.', fieldName); end
    
    % Use arrayfun to extract the field values and stack them into a column vector
    vec = arrayfun(@(x) x.(fieldName), structArray, 'UniformOutput', false);
    
    % Convert the cell array to a column vector
    vec = vertcat(vec{:});
    
end
