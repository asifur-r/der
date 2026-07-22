function val = sysDofs(Rods)
    % Returns number of system dofs

    % Total dofs in the system
    val = sum(ndofsPerRod(Rods));
    
end