function vec = getRodLevelVector(vec, rodTag, ndofspr)
    % Returns the rod level vector (displacement or velocity) from a full sized system level vector

    % vec = displacement or veloctity vector of the system
    % rodTag = an integer tag of the rod
    % ndofspr = vector containing ndof of every rod

    % Cumulitive sum
    cum = cumsum(ndofspr);

    % Left pointer
    if rodTag == 1
        p = 1;
    else    
        p = cum(rodTag - 1) + 1;
    end

    % Right pointer
    q = cum(rodTag);

    % Pick the sub vector between p and q from vec
    vec = vec(p:q);

end