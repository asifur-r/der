function [vec, val] = presDispDofs(Prdisp)
    % Returns prescribed dofs in the system as a vector and its length

    % Get the stacked prescribed dof vector from rods
    % Prdisp = vertCat(Rods, 'prdisp');

    % Get the prescribed dofs id
    vec = find(Prdisp ~= 0);

    % Number of prescribed dofs
    val = length(vec);
    
end