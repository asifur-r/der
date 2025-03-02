function [vec, val] = resDofs(Rods)
    % Returns restrained dofs in the system as a vector and its length

    % Get the stacked restrained vector from rods
    Res = vertCat(Rods, 'res');

    % Get the restrained dofs id
    vec = find(Res ~= 0);

    % Number of restrained dofs
    val = length(vec);

    
end