function [EA, EIx, EIy, GJ] = stiffness_kh(nele, h, w, E, nu)
    
    % Makes stiffness unit for now
    EA  = ones(nele, 1);
    EIx  = ones(nele+1, 1);
    EIy  = ones(nele+1, 1);
    GJ  = ones(nele+1, 1);

end