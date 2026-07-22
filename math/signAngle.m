function val = signAngle(A, B, N)
    % return signed angle between two vectors A and B, N dictates positive angle
    
    C = cross(A, B);

    val = atan2( norm(C), dot(A, B) );

    if (dot(N, C) < 0) 
        val = -val;
    end

end