function Es = stretchingEnergy(EA, enormbar, enorm)

    nele = size(EA, 1);

    % Vector for storing energy of each element
    es = zeros(nele, 1);

    % Energy of each element
    for i = 1:nele
        es(i) = 0.5 * EA(i) * (enorm(i)/enormbar(i) - 1)^2 * enormbar(i);
    end
    
    % Energy of the entire rod
    Es = sum(es);
    
end