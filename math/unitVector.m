function vec = unitVector(vec)
% Returns unit vector of a vector

    arguments
        vec (1, 3) {mustBeNumeric}
    end
    
    vec = vec/norm(vec);

end