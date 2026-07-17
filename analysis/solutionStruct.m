function S = solutionStruct(Rods, sys, sol)

    % Prepare solution struct
    S = struct();
    S.ndofspr = sys.ndofpr;
    S.T   = sol.T;
    S.Qs  = {Rods.Q};
    S.Us  = {Rods.U};
    S.FIs = {Rods.FI};
    
    S.ESs = {Rods.Es};
    S.ETs = {Rods.Et};
    S.EBs = {Rods.Eb};
    S.Es  = {Rods.E};

end
