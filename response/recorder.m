function recorder(rec, Rods, ana, sol)
    % Writes displacements of node/s in a file as a column matrix [u1 u2 ...]

    % rec = struct defining recorder specs
    % Rods = struct containing all rods
    % ana = analysis object
    % sol = solver object
  
    % Record responses
    if ~isempty(rec.dispfile); recordResponse('disp', rec, Rods, sol); end
    if ~isempty(rec.forcefile); recordResponse('force', rec, Rods, sol); end
    if ~isempty(rec.energyfile); recordResponse('energy', rec, Rods, sol); end
    
end

function recordResponse(variable, rec, Rods, sol)
    % Generic function to record responses (displacements or forces).
    
    % Check for first time step
    if isscalar(sol.T)
        permission = 'w';  % Create new file if first time step
    else
        permission = 'a';  % Append for other time steps
    end

    % Pick the right file name
    switch variable
        case 'disp'; filename = rec.dispfile; dofStruct = rec.dispdofs;
        case 'force'; filename = rec.forcefile; dofStruct = rec.forcedofs;
        case 'energy'; filename = rec.energyfile;
    end

    % Make path
    path = fullfile(rec.folder, filename);

    % Attempt to open file
    file = fopen(path, permission);
    
    % Display error and return
    if file == -1; error(['Error opening file: ', filename]); end

    % Recorder string
    str = sprintf('%.3f, ', sol.t);

    switch variable
        case 'energy'
        [E, Es, Et, Eb] = getEnergy(Rods);
        str = strcat(str, sprintf('%.4f, %.4f, %.4f, %.4f', E, Es, Et, Eb) );

        % Insert new line and close
        fprintf(file, '%s\n', str); fclose(file);
        return
    end

    % Only gets here if disp or force

    % Number of response to record
    nresponse = length(dofStruct);

    for i = 1:nresponse

        % Extract where to look
        rod = dofStruct(i).rod;
        node= dofStruct(i).node;
        dof = dofStruct(i).dof;
        rodDof = node2dof(node, dof); % Rod level dof

        % Choose the response to record based on the variable (disp or force)
        switch variable
            case 'disp'; response = Rods(rod).u(rodDof);
            case 'force'; response = Rods(rod).Fi(rodDof);
            otherwise; error(['Rod ', num2str(rod), ' does not have the expected response data.']);                
        end

        % Make sparse to full (because u, Fi are defined as sparse)
        response = full(response);

        % Make the string to insert
        str = strcat(str, sprintf('%.4f', response));

    end

    % Insert new line and close
    fprintf(file, '%s\n', str); fclose(file);
 
end

function [E, Es, Et, Eb] = getEnergy(Rods)

    E  = 0;
    Es = 0; 
    Et = 0;
    Eb = 0;

    for r = 1:length(Rods)
        E  = E  + Rods(r).E(end);
        Es = Es + Rods(r).Es(end);
        Et = Et + Rods(r).Et(end);
        Eb = Eb + Rods(r).Eb(end);
    end

end