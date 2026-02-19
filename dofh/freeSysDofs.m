function [vec, val] = freeSysDofs(Res, Prdisp, ana, dofs, ndofs)
    % Returns number of system dofs for multi rod and its length

    % For penalty approach, all dofs are free
    if strcmp(ana.constraint, 'penalty'); vec = dofs; val = ndofs; return; end

    % For elimination approach, the number is found by 
    % subtracting the restrained dofs and prescribed dofs from the total
    
    if strcmp(ana.constraint, 'elimination')

        % Restrained dofs
        [resdofs, nresdofs] = resDofs(Res);

        % Prescribed dofs
        [prddofs, nprddofs] = presDispDofs(Prdisp);

        % Number of free dofs
        nfreedofs = ndofs - nresdofs - nprddofs;

        % Free dofs ids by set difference setdiff(setdiff(A,B),C) = A-B-C
        freedofs = setdiff(setdiff(dofs, resdofs), prddofs);

        % Return
        val = nfreedofs;
        vec = freedofs;
        
    end

end