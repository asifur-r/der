function vec = ndofsPerRod(Rods)
    % Returns a vector containing number of dofs per rod
    vec = horzcat(Rods.ndof);
end