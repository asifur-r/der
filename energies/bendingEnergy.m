function Eb = bendingEnergy(EIx, EIy, kap1bar, kap2bar, ellbar, kap1, kap2)

    nele = size(EIx, 1) - 1;

    % Vector for storing energy of each element
    eb1 = zeros(nele, 1);
    eb2 = zeros(nele, 1);
    
    % Energy for each element
    for i = 1:nele
        eb1(i) = 0.5 * EIx(i) / ellbar(i) * (kap1(i) - kap1bar(i))^2;
        eb2(i) = 0.5 * EIy(i) / ellbar(i) * (kap2(i) - kap2bar(i))^2;
    end
    
    % Energy of the entire rod
    Eb = sum(eb1) + sum(eb2);
    
end