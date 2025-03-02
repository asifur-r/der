% get signed angle between two vectors A and B, N dictates positive angle

function val = signAngle(A, B, N)
    
    C = cross(A, B);

    val = atan2( norm(C), dot(A, B) );

    if (dot(N, C) < 0) 
        val = -val;
    end

end