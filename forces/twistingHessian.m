function mat3d = twistingHessian(t, enorm, kapb)
    
    nele = size(t, 1);
    n = nele + 1;

    mat3d = zeros(11, 11, n);

    for i = 2:nele

        enorm_e = enorm(i - 1);
        enorm_f = enorm(i);
        
        te = t(i-1, :);
        tf = t(i, :);
        
        chi = 1.0 + dot(te, tf);
        ttil = (te + tf) / chi;
        kapb_i = kapb(i, :);
        skewt_te = [0 -te(3) te(2); te(3) 0 -te(1); -te(2) te(1) 0];

        % Compute each second derivatives (3x3 block)
        d2mdede = -0.25 / enorm_e^2 * ( kapb_i' * (te + ttil) + (te + ttil)' * kapb_i);
        d2mdfdf = -0.25 / enorm_f^2 * ( kapb_i' * (tf + ttil) + (tf + ttil)' * kapb_i);
        d2mdedf =  0.50 / (enorm_e * enorm_f) * (2.0 / chi * skewt_te - kapb_i' * ttil);
        d2mdfde = d2mdedf';
        
        % Place as 3x3 block
        mat3d(1:3, 1:3, i) =  d2mdede;
        mat3d(1:3, 9:11,i) = -d2mdedf;
        mat3d(9:11,1:3, i) = -d2mdfde;
        mat3d(9:11,9:11,i) =  d2mdfdf;

        mat3d(1:3, 5:7, i) = -d2mdede + d2mdedf;
        mat3d(5:7, 1:3, i) = -d2mdede + d2mdfde;
        mat3d(5:7, 9:11,i) =  d2mdedf - d2mdfdf;
        mat3d(9:11,5:7, i) =  d2mdfde - d2mdfdf;

        mat3d(5:7, 5:7, i) =  d2mdede - ( d2mdedf + d2mdfde ) + d2mdfdf;
    
    end

end