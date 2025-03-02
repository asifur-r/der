function Fpd = presDispForce(sys, sol, Kt)
    % Returns the force vector for prescribed displacement or a zero vector if there isn't any
    
    % Just making short names
    fr = sys.frdof; pr = sys.prddof;
    
    if sys.nprddof ~= 0 % Checkf if there is any prescribed displacement

        % Computue force vector 
        Fpd = -Kt(fr, pr) * (sol.lam*sol.Prdisp(pr) - sol.u(pr));

    else % Return a zero vector

        Fpd = zeros(sys.nfrdof, 1);

    end

end