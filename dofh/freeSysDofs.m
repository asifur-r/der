function [vec, val] = freeSysDofs(Rods, ana)
    % Returns number of system dofs for multi rod and its length
    
    % System dofs
    [sysdofs, nsysdofs] = sysDofs(Rods);

    % For penalty approach, all dofs are free
    if strcmp(ana.constraint, 'penalty'); vec = sysdofs; val = nsysdofs; return; end

    % For elimination approach, the number is found by 
    % subtracting the restrained dofs and prescribed dofs from the total
    
    if strcmp(ana.constraint, 'elimination')

        % Restrained dofs
        [resdofs, nresdofs] = resDofs(Rods);

        % Prescribed dofs
        [prddofs, nprddofs] = presDispDofs(Rods);

        % Number of free dofs
        nfreedofs = nsysdofs - nresdofs - nprddofs;

        % Free dofs ids by set difference setdiff(setdiff(A,B),C) = A-B-C
        freedofs = setdiff(setdiff(sysdofs, resdofs), prddofs);

        % Return
        val = nfreedofs;
        vec = freedofs;
        
    end

end