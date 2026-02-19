function [mat1, mat2] = bendingGradient(t, enorm, kapb, kap1, kap2, m1, m2)

    nele = size(t, 1);
    n = nele + 1;

    mat1 = zeros(n, 11); % For kappa 1
    mat2 = zeros(n, 11); % For kappa 2

    for i = 2:nele

        % Extract varibales for simpler notations
        te = t(i-1, :);
        tf = t(i, :);

        ene = enorm(i-1);
        enf = enorm(i);
        
        kb = kapb(i, :);

        k1 = kap1(i);
        k2 = kap2(i);
        
        m1e = m1(i-1, :);
        m2e = m2(i-1, :);
        
        m1f = m1(i, :);
        m2f = m2(i, :);
        
        % Some intermediate variables
        chi = 1.0 + dot(te, tf);
        tt = (te + tf) / chi;
        m1t = (m1e + m1f) / chi;
        m2t = (m2e + m2f) / chi;

        % Compute the unique derivatives for kappa 1
        dk1de  =  1.0 / ene * (-k1 * tt + cross(tf, m2t));
        dk1df  =  1.0 / enf * (-k1 * tt - cross(te, m2t));
        dk1dte = -0.5 * dot(kb, m1e);
        dk1dtf = -0.5 * dot(kb, m1f);

        % Compute the unique derivatives for kappa 2
        dk2de  =  1.0 / ene * (-k2 * tt - cross(tf, m1t));
        dk2df  =  1.0 / enf * (-k2 * tt + cross(te, m1t));
        dk2dte = -0.5 * dot(kb, m2e);
        dk2dtf = -0.5 * dot(kb, m2f);

        % Construct the 11-element derivative vector for kappa 1 and 2
        % mat1(i, :) = dkvec(dk1de, dk1df, dk1dte, dk1dtf);
        % mat2(i, :) = dkvec(dk2de, dk2df, dk2dte, dk2dtf);

        % By direct assignment (without using dkvec)
        mat1(i, :) = [-dk1de, dk1dte, dk1de - dk1df, dk1dtf, dk1df];
        mat2(i, :) = [-dk2de, dk2dte, dk2de - dk2df, dk2dtf, dk2df];

    end
    
end

% function vec = dkvec(dkde, dkdf, dkdte, dkdtf)

%     vec = zeros(1, 11);

%     vec(1:3)  = -dkde;
%     vec(5:7)  =  dkde - dkdf;
%     vec(9:11) =         dkdf;
%     vec(4)    =  dkdte;
%     vec(8)    =  dkdtf;

%     % Alternate construction
%     % vec = [-dkde, dkdte, dkde - dkdf, dkdtf, dkdf];
    
% end
