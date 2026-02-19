function [mat3d1, mat3d2] = bendingHessian(t, enorm, kapb, kap1, kap2, m1, m2)

    nele = size(t, 1);
    n = nele + 1;

    mat3d1 = zeros(11, 11, n); % For kappa 1
    mat3d2 = zeros(11, 11, n); % For kappa 2

    for i = 2:nele

        % Extract varibales for simpler notations
        te = t(i-1, :);
        tf = t(i, :);

        ene = enorm(i-1);
        enf = enorm(i);
        
        en2e = ene^2;
        en2f = enf^2;

        kb = kapb(i, :);

        k1 = kap1(i);
        k2 = kap2(i);
        
        m1e = m1(i-1, :);
        m2e = m2(i-1, :);
        
        m1f = m1(i, :);
        m2f = m2(i, :);
        
        % Some intermediate variables
        I = eye(3);
        chi = 1.0 + dot(te, tf);
        tt = (te + tf) / chi;
        m1t = (m1e + m1f) / chi;
        m2t = (m2e + m2f) / chi;
        ttT = tt' * tt;
        skewt_m2t = [0 -m2t(3) m2t(2); m2t(3) 0 -m2t(1); -m2t(2) m2t(1) 0];
        skewt_m1t = [0 -m1t(3) m1t(2); m1t(3) 0 -m1t(1); -m1t(2) m1t(1) 0];
        
        % Double edge terms (e, f)
        
        % Kappa 1
        A = (cross(tf, m2t))' * tt; B = kb' * m2e; E = 2*k1*ttT; F = I - te'*te; G = I - tf'*tf;
        dk1dede = 1/en2e * (E - A - A') - k1 / (chi*en2e) * F + 1 / (4*en2e) * (B + B');

        C = (cross(te, m2t))' * tt; D = kb' * m2f;
        dk1dfdf = 1/en2f * (E + C + C') - k1 / (chi*en2f) * G + 1 / (4*en2f) * (D + D');

        dk1dedf = -k1/(chi*ene*enf) * (I + te'*tf) + 1 / (ene*enf) * (E - A + C' - skewt_m2t);
        dk1dfde = dk1dedf';

        % Kappa 2
        A = (cross(tf, m1t))' * tt; B = kb' * m1e; E = 2*k2*ttT;
        dk2dede = 1/en2e * (E + A + A') - k2 / (chi*en2e) * F - 1 / (4*en2e) * (B + B');

        C = (cross(te, m1t))' * tt; D = kb' * m1f;
        dk2dfdf = 1/en2f * (E - C - C') - k2 / (chi*en2f) * G - 1 / (4*en2f) * (D + D');
        
        dk2dedf = -k2/(chi*ene*enf) * (I + te'*tf) + 1 / (ene*enf) * (E + A - C' + skewt_m1t);
        dk2dfde = dk2dedf';
        
        % Double angle terms (ge, gf)

        % Storing some dot products
        dot_kb_m1e = dot(kb, m1e); dot_kb_m1f = dot(kb, m1f);
        dot_kb_m2e = dot(kb, m2e); dot_kb_m2f = dot(kb, m2f);

        % Kappa 1
        dk1dgedge = -0.5 * dot_kb_m2e;
        dk1dgfdgf = -0.5 * dot_kb_m2f;

        % Kappa 2
        dk2dgedge =  0.5 * dot_kb_m1e;
        dk2dgfdgf =  0.5 * dot_kb_m1f;
        
        % Cross terms (edge, gamma)

        % Kappa 1
        dk1dedge = 1 / ene * (0.5 * dot_kb_m1e * tt - 1 / chi * cross(tf, m1e));
        dk1dedgf = 1 / ene * (0.5 * dot_kb_m1f * tt - 1 / chi * cross(tf, m1f));
        dk1dfdge = 1 / enf * (0.5 * dot_kb_m1e * tt + 1 / chi * cross(te, m1e));
        dk1dfdgf = 1 / enf * (0.5 * dot_kb_m1f * tt + 1 / chi * cross(te, m1f));
        
        % Kappa 2
        dk2dedge = 1 / ene * (0.5 * dot_kb_m2e * tt - 1 / chi * cross(tf, m2e));
        dk2dedgf = 1 / ene * (0.5 * dot_kb_m2f * tt - 1 / chi * cross(tf, m2f));
        dk2dfdge = 1 / enf * (0.5 * dot_kb_m2e * tt + 1 / chi * cross(te, m2e));
        dk2dfdgf = 1 / enf * (0.5 * dot_kb_m2f * tt + 1 / chi * cross(te, m2f));
                
        mat3d1(:,:,i) = der2mat(dk1dede, dk1dedf, dk1dfde, dk1dfdf, dk1dgedge, dk1dgfdgf, dk1dedge, dk1dfdge, dk1dedgf, dk1dfdgf);
        mat3d2(:,:,i) = der2mat(dk2dede, dk2dedf, dk2dfde, dk2dfdf, dk2dgedge, dk2dgfdgf, dk2dedge, dk2dfdge, dk2dedgf, dk2dfdgf);

    end
    
end

function mat = der2mat(dkdede, dkdedf, dkdfde, dkdfdf, dkdgedge, dkdgfdgf, dkdedge, dkdfdge, dkdedgf, dkdfdgf)
    % This appraoch stores the submatrices from the input, then constructs the final 11x11 matrix by direct assignment

    % Edge only terms
    A =   dkdede;
    B = - dkdede + dkdedf;
    C =          - dkdedf;

    D = - dkdede          + dkdfde;
    E =   dkdede - dkdedf - dkdfde + dkdfdf;
    F =            dkdedf          - dkdfdf;

    G =                   - dkdfde;
    H =                     dkdfde - dkdfdf;
    I =                              dkdfdf;
    
    % Angle only terms
    d1 = dkdgedge;
    d2 = 0;
    d3 = 0;
    d4 = dkdgfdgf;

    % Edge-angle coupled terms
    c1 = - dkdedge';
    c3 =   dkdedge' - dkdfdge';
    c5 =              dkdfdge';
    c2 = - dkdedgf';
    c4 =   dkdedgf' - dkdfdgf';
    c6 =              dkdfdgf';

    r1 = - dkdedge;
    r2 =   dkdedge - dkdfdge;
    r3 =             dkdfdge;
    r4 = - dkdedgf;
    r5 =   dkdedgf - dkdfdgf;
    r6 =             dkdfdgf;

    mat = [
        A   c1  B   c2  C ;
        r1  d1  r2  d2  r3;
        D   c3  E   c4  F ;
        r4  d3  r5  d4  r6;
        G   c5  H   c6  I];

    % Matrix map: 11x11
    % A to F are 3x3, r1 to r6 are 1x3, and c1 to c6 are 3x1
    %
    % ---------------------------
    %  A  | c1  |  B  | c2  | C
    % ---------------------------
    % r1  | d1  | r2  | d2  | r3
    % ---------------------------
    %  D  | c3  |  E  | c4  | F
    % ---------------------------
    % r4  | d3  | r5  | d4  | r6
    % ---------------------------
    %  G  | c5  |  H  | c6  | I
    % ---------------------------

end

% function mat = der2mat(dkdede, dkdedf, dkdfde, dkdfdf, dkdgedge, dkdgfdgf, dkdedge, dkdfdge, dkdedgf, dkdfdgf)
%     % This is the most basic approach where the submatrices are inserted into the zero matrix
%     mat = zeros(11);
 
%     % Edge only terms
%     mat(1:3, 1:3)  =   dkdede;
%     mat(1:3, 5:7)  = - dkdede + dkdedf;
%     mat(1:3, 9:11) =          - dkdedf;
%     mat(5:7, 1:3)  = - dkdede          + dkdfde;
%     mat(5:7, 5:7)  =   dkdede - dkdedf - dkdfde + dkdfdf;
%     mat(5:7, 9:11) =            dkdedf          - dkdfdf;
%     mat(9:11, 1:3) =                   - dkdfde;
%     mat(9:11, 5:7) =                     dkdfde - dkdfdf;
%     mat(9:11, 9:11)=                              dkdfdf;
    
%     % Angle only terms
%     mat(4, 4) = dkdgedge;
%     mat(8, 8) = dkdgfdgf;
    
%     % Edge-angle coupled terms
%     mat(1:3, 4)  = - dkdedge;
%     mat(5:7, 4)  =   dkdedge  - dkdfdge;
%     mat(9:11,4)  =              dkdfdge;
%     mat(4, 1:3)  = - dkdedge';
%     mat(4, 5:7)  =   dkdedge' - dkdfdge';
%     mat(4, 9:11) =              dkdfdge';
    
%     mat(1:3, 8)  = - dkdedgf;
%     mat(5:7, 8)  =   dkdedgf  - dkdfdgf;
%     mat(9:11,8)  =              dkdfdgf;
%     mat(8, 1:3)  = - dkdedgf';
%     mat(8, 5:7)  =   dkdedgf' - dkdfdgf';
%     mat(8, 9:11) =              dkdfdgf';
% end