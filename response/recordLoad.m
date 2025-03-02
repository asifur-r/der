function recordLoad(file, rods)
    % Writes load values in a file
    
    % Matrix containing all loads in [rod node localdof val] form
    mat = [];
    
    for r=1:length(rods)

        % Find global dofs of nonzero load values
        dofs = find(rods(r).fext ~= 0);

        % Get load values
        loads = rods(r).fext(dofs);

        for i=1:length(loads)

            load = loads(i);

            % Convert global dofs to [node localdof] pair
            [node, locDof] = glo2locDDof(dofs, rods(r).n);

            % Append to the final matrix
            mat = [mat; r node locDof load];

        end

    end

    % Write to file
    writematrix(mat, file);
    
end

function [node, locDof] = glo2locDDof(gloDof, n)
    
    assert(gloDof < 4*n, "Global dof should be less than 4N");

    node = ceil(gloDof / 4);

    locDof = mod(gloDof, 4); if locDof == 0; locDof = 4; end

end