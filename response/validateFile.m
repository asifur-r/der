function fullFilePath = validateFile(filename, fieldName)
    % Validates filename structure, path, and adds txt extension.
    % Removes any existing extension and adds .txt.

    if ~ischar(filename)
        error(['Invalid ', fieldName, ': Filename must be a string.']);
    end

    % Remove any existing extension
    [pathStr, name, ~] = fileparts(filename);

    % Check for path existence
    if ~isempty(pathStr) && ~exist(pathStr, 'dir')
        error(['Invalid ', fieldName, ': Path "', pathStr, '" does not exist.']);
    end

    % Check for invalid characters in the filename (excluding path)
    if ~isempty(regexpi(name, '[<>:"/\\|?*]'))
        error(['Invalid ', fieldName, ': Filename contains invalid characters.']);
    end

    % Construct the full file path with .txt extension
    fullFilePath = fullfile(pathStr, [name, '.txt']);
    
end