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
        dmdede = -0.25 / enorm_e^2 * ( kapb_i' * (te + ttil) + (te + ttil)' * kapb_i);
        dmdfdf = -0.25 / enorm_f^2 * ( kapb_i' * (tf + ttil) + (tf + ttil)' * kapb_i);
        dmdedf =  0.50 / (enorm_e * enorm_f) * (2.0 / chi * skewt_te - kapb_i' * ttil);
        dmdfde = dmdedf';
        
        mat3d(:,:,i) = der2mat(dmdede, dmdedf, dmdfde, dmdfdf);

    end

end

function mat = der2mat(dmdede, dmdedf, dmdfde, dmdfdf)

    mat = zeros(11);

    A =   dmdede;
    B = - dmdede + dmdedf;
    C =          - dmdedf;

    D = - dmdede          + dmdfde;
    E =   dmdede - dmdedf - dmdfde + dmdfdf;
    F =            dmdedf -          dmdfdf;

    G =                   - dmdfde;
    H =                     dmdfde - dmdfdf;
    I =                              dmdfdf;
    
    mat([1:3, 5:7, 9:11], [1:3, 5:7, 9:11]) = [...
        A B C; 
        D E F; 
        G H I
    ];
    
    % Matrix map: 11x11
    % A to F are 3x3, the dots (.) are zero matrices of 3x1 or 1x3
    %
    % ---------------------------
    %  A  | .  |  B  |  .  | C
    % ---------------------------
    %  .  | .  |  .  |  .  | .
    % ---------------------------
    %  D  | .  |  E  |  .  | F
    % ---------------------------
    %  .  | .  |  .  |  .  | .
    % ---------------------------
    %  G  | .  |  H  |  .  | I
    % ---------------------------

end

% function mat = der2mat(dmdede, dmdedf, dmdfde, dmdfdf)

%     mat = zeros(11);

%     mat(1:3, 1:3)   =   dmdede;
%     mat(1:3, 5:7)   = - dmdede + dmdedf;
%     mat(1:3, 9:11)  =          - dmdedf;

%     mat(5:7, 1:3)   = - dmdede          + dmdfde;
%     mat(5:7, 5:7)   =   dmdede - dmdedf - dmdfde + dmdfdf;
%     mat(5:7, 9:11)  =            dmdedf -          dmdfdf;

%     mat(9:11, 1:3)  =                   - dmdfde;
%     mat(9:11, 5:7)  =                     dmdfde - dmdfdf;
%     mat(9:11, 9:11) =                              dmdfdf;

% end