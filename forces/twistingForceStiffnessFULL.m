function [Ft, Kt] = twistingForceStiffnessFULL(t, enorm, kapb, m, mbar, ellbar, GJ)
    
    nele = size(t, 1);
    ndof = nele2ndof(nele);

    % Compute first and second derivatives of twist
    twistGrad = twistingGradient(enorm, kapb);
    twistHess = twistingHessian(t, enorm, kapb);

    % Twisting force vector
    Ft = zeros(ndof, 1);

    for i = 2:nele

        ft = GJ(i) / ellbar(i) * ( m(i) - mbar(i)) * twistGrad(i, :)';

        p = 1 + 4*(i-2);
        q = p + 10;

        Ft(p:q) = Ft(p:q) + ft;
        
    end

    % Twisting stiffness matrix
    Kt = zeros(ndof);

    for i = 2:nele

        kt = (GJ(i) / ellbar(i)) * ( (m(i) - mbar(i)) * twistHess(:,:,i) + twistGrad(i, :)' * twistGrad(i, :));

        p = 1 + 4*(i-2);
        q = p + 10;

        Kt(p:q, p:q) = Kt(p:q, p:q) + kt;
        
    end

end