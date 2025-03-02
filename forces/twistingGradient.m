function mat = twistingGradient(enorm, kapb)

    nele = size(enorm, 1);
    n = nele + 1;

    mat = zeros(n, 11);
    vec = zeros(1, 11);

    for i = 2:nele

        % Eq. 6.39
        % ep refers to k-th edge, eq is k-th edge
        
        dmref_ep = -0.5 / enorm(i-1) * kapb(i, :);
        dmref_eq =  0.5 / enorm(i) * kapb(i, :);
        
        vec(1:3)  = dmref_ep;
        vec(5:7)  = -(dmref_ep + dmref_eq);
        vec(9:11) = dmref_eq;

        vec(4) = -1;
        vec(8) =  1;

        mat(i, :) = vec;
        
    end

end