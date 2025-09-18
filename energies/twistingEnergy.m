function Et = twistingEnergy(GJ, mbar, ellbar, m)

    nele = size(GJ, 1) - 1;

    % Vector for storing energy of each element
    et = zeros(nele, 1);
    
    % Energy for each element
    for i = 2:nele
        et(i) = 0.5 * GJ(i) / ellbar(i) * (m(i) - mbar(i))^2;
    end
    
    % Energy of the entire rod
    Et = sum(et);
    
end