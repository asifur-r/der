function Rods = rodHistory(Rods)

    for r = 1:length(Rods)

        % Assign for each rod
        Rods(r).Q = [Rods(r).Q, Rods(r).q]; 
        Rods(r).U = [Rods(r).U, Rods(r).u]; 
        Rods(r).FI= [Rods(r).FI,Rods(r).Fi];

         % Energies

        [es, et, eb] = allEnergies(Rods(r));
        Rods(r).Es = [Rods(r).Es, es];
        Rods(r).Et = [Rods(r).Et, et];
        Rods(r).Eb = [Rods(r).Eb, eb];
        Rods(r).E = [Rods(r).E es+et+eb];

    end

end