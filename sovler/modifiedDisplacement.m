function [du, dl] = modifiedDisplacement(Kt, R, WpFext, lam0, i)

    persistent firstcall sinal numgsp dutp1 dutc1
    
    dut = Kt\WpFext; % WpFext is W'*Fext

    if i == 1
        dub = 0*R; % A zero vector of same size as R
    else
        dub = Kt\R;
    end
    
    if i == 1
	
        if isempty(firstcall)
            sinal = sign(dut'*dut);
            numgsp = dut'*dut;   
            dl = lam0;
        else
            sinal = sinal*sign(dutp1'*dut);
            gsp = numgsp/(dut'*dut);
            dl = sinal*lam0*sqrt(gsp);
        end 
		
        dutp1 = dut;
        dutc1 = dut;
		
    else
        dl = -(dutc1'*dub)/(dutc1'*dut);
    end

    du = dub + dl*dut;
	
	firstcall = false;
    
end