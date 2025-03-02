function recorder(rec, Rods, t, lam)
    % Writes displacements of node/s in a file as a column matrix [u1 u2 ...]

    % t = current pseudo time step
    % rec = struct defining recorder specs
    % lam = current load factor
    % Rods = struct containing all rods

    % Permission to open new file for first step, otherwise append
    if t == 1; permission = 'w'; else; permission = 'a'; end
      
    % Record responses
    if ~isempty(rec.dispfile); recordResponse('disp', rec.dispfile, rec.dispdofs, Rods, lam, permission); end
    if ~isempty(rec.forcefile); recordResponse('force', rec.forcefile, rec.forcedofs, Rods, lam, permission); end
    

end

function recordResponse(variable, filename, dofstr, Rods, lam, permission)
    % Generic function to record responses (displacements or forces).

    file = fopen(filename, permission); if file == -1; error(['Could not open file: ', filename]); end

    % Number of response to record
    nresponse = length(dofstr);

    % Recorder string
    str = sprintf('%.3f', lam);

    for i = 1:nresponse

        % Extract where to look
        rod = dofstr(i).rod;
        node = dofstr(i).node;
        dof = dofstr(i).dof;

        % Choose the response to record based on the variable (disp or force)
        switch variable
            case 'disp'; response = Rods(rod).u(node2dof(node, dof));
            case 'force'; response = Rods(rod).Fi(node2dof(node, dof));
            otherwise; error(['Rod ', num2str(rod), ' does not have the expected response data.']);                
        end
        
        % Make the string to insert
        str = strcat(str, ', ', sprintf('%.3f', response));
    end

    % Insert new line and close
    fprintf(file, '%s\n', str); fclose(file);

end