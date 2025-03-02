function [vec, val] = sysDofs(Rods)
    % Returns number of system dofs for multi rod and its length

    % Total dofs in the system
    val = sum(ndofsPerRod(Rods));

    % Dofs id
    vec = 1:val;
    
end