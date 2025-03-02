function vec = ndofsPerRod(Rods)
    % Returns a vector containing number of dofs per rod
    
    vec = arrayfun(@(r) r.ndof, Rods);
    
end