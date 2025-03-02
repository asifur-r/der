function [kap1, kap2] = curvature(m1, m2, kapb)

    n = size(kapb, 1);
    nele = n-1;

    % Curvatures in the material frame
    kap1 = zeros(n, 1);
    kap2 = zeros(n, 1);

    for i=2:nele

        % Eq. 5.6
        kap1(i) =  dot( m2(i-1, :) + m2(i, :), kapb(i, :) ) / 2;
        kap2(i) = -dot( m1(i-1, :) + m1(i, :), kapb(i, :) ) / 2;

    end
    
end