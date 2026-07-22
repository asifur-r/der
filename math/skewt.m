function mat = skewt(r)
    % DEPRECATED
    % Returns 3x3 skew-symmetric matrix of a vector of length 3
    % Calling skewt repeatedly causes performance issue
    % Therefore it is directly implemented inside calling functions
    
    mat = [0 -r(3) r(2); r(3) 0 -r(1); -r(2) r(1) 0];
    
end