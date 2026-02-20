function [Fb, Kb] = bendingForceStiffnessFULL(t, enorm, kapb, kap1, kap2, kap1bar, kap2bar, m1, m2, ellbar, EIx, EIy)
    
    nele = size(t, 1);
    ndof = nele2ndof(nele);

    % Compute first and second derivatives of curvature
    [bendGrad1, bendGrad2] = bendingGradient(t, enorm, kapb, kap1, kap2, m1, m2);
    [bendHess1, bendHess2] = bendingHessian(t, enorm, kapb, kap1, kap2, m1, m2);

    % Bending force vector
    Fb = zeros(ndof, 1);

    for i = 2:nele

        fb1 = EIx(i) / ellbar(i) * (kap1(i) - kap1bar(i)) * bendGrad1(i, :)';
        fb2 = EIy(i) / ellbar(i) * (kap2(i) - kap2bar(i)) * bendGrad2(i, :)';

        p = 1 + 4*(i-2);
        q = p + 10;

        Fb(p:q) = Fb(p:q) + fb1 + fb2;
        
    end

    % Bending stiffness matrix
    Kb = zeros(ndof);

    for i = 2:nele
        
        A = EIx(i) / ellbar(i) * bendGrad1(i, :)' * bendGrad1(i, :);
        B = EIy(i) / ellbar(i) * bendGrad2(i, :)' * bendGrad2(i, :);
        
        C = EIx(i) / ellbar(i) * (kap1(i) - kap1bar(i)) * bendHess1(:,:,i);
        D = EIy(i) / ellbar(i) * (kap2(i) - kap2bar(i)) * bendHess2(:,:,i);
        
        kb = A + B + C + D;

        p = 1 + 4*(i-2);
        q = p + 10;
        
        Kb(p:q, p:q) = Kb(p:q, p:q) + kb;
        
    end

    Fb = sparse(Fb);
    Kb = sparse(Kb);
end