function recorder(rec, Rods, ana, sol)
    % Writes displacements of node/s in a file as a column matrix [u1 u2 ...]

    % rec = struct defining recorder specs
    % Rods = struct containing all rods
    % ana = analysis object
    % sol = solver object
  
    % Record responses
    if ~isempty(rec.dispfile); recordResponse('disp', rec, Rods, ana, sol); end
    if ~isempty(rec.forcefile); recordResponse('force', rec, Rods, ana, sol); end
    
end

function recordResponse(variable, rec, Rods, ana, sol)
    % Generic function to record responses (displacements or forces).

    % Check for first time step
    if sol.t ~= ana.dt
        permission = 'a';  % Append for other time steps
    else
        permission = 'w';  % Create new file if first time step
    end

    % Pick the right file name
    switch variable
        case 'disp'; filename = rec.dispfile; dofStruct = rec.dispdofs;
        case 'force'; filename = rec.forcefile; dofStruct = rec.forcedofs;
    end

    % Make path
    path = fullfile(rec.folder, filename);

    % Attempt to open file
    file = fopen(path, permission);
    
    % Display error and return
    if file == -1; error(['Error opening file: ', filename]); end

    % Number of response to record
    nresponse = length(dofStruct);

    % Recorder string
    str = sprintf('%.3f', sol.t);

    for i = 1:nresponse

        % Extract where to look
        rod = dofStruct(i).rod;
        node= dofStruct(i).node;
        dof = dofStruct(i).dof;

        % Choose the response to record based on the variable (disp or force)
        switch variable
            case 'disp'; response = Rods(rod).u(node2dof(node, dof));
            case 'force'; response = Rods(rod).Fi(node2dof(node, dof));
            otherwise; error(['Rod ', num2str(rod), ' does not have the expected response data.']);                
        end

        % Make the string to insert
        str = strcat(str, ', ', sprintf('%.4f', full(response))); % sparse to full matrix conversion
    end

    % Insert new line and close
    fprintf(file, '%s\n', str); 
    fclose(file);
 
end