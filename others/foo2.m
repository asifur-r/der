function foo()

disp = zeros(neq,1);

dispPrev  = disp;
dispPrev2 = disp;

lam
lamPrev2 = 0.0;
lamPrev  = 0.0;

Ds = lam;
DsPrev = Ds;
DsMax = Ds;
DsMin = Ds;

conv = false;
convPrev = false;

for  t=1:tmax

    if(t > 1)
		DsFac1 = Ds/DsPrev;
		disp     = (1.0+DsFac1)*dispPrev - DsFac1*dispPrev2;
		lam = (1.0+DsFac1)*lamPrev - DsFac1*lamPrev2;
    end

    Du = disp - dispPrev;
    Dl = lam - lamPrev;

    convPrev = conv;
    conv = false;

	% Inner loop
    while conv ~= true
        
		% Compute Kglobal and Rglobal

        Rglobal = Rglobal + lam*Fext;
		
        [conv, du, dl] = solve_arclength_split(t, neq, iter, Kglobal, Rglobal, dof_force, Fext, bndofs, Du, Dl, Ds);

        disp(bndofs) = disp(bndofs) + du;
        lam = lam + dl;

        Du(bndofs) = Du(bndofs) + du;
        Dl = Dl + dl;
		
    end

    if ~conv

		if(convPrev); Ds = max(Ds*0.5, DsMin); else; Ds = max(Ds*0.25, DsMin); end

    else
		
		if(t == 1)
			Ds = sqrt(Du'*Du + lam*lam*Fext'*Fext);
			DsMax = Ds;
			DsMin = Ds/1024.0;
		end

		lamPrev2 = lamPrev;
		lamPrev  = lam;
		dispPrev2 = dispPrev;
		dispPrev  = disp;

		DsPrev = Ds;
		if(convPrev); Ds = min(max(2.0*Ds, DsMin), DsMax); end

		% Update converged U, L

    end

end
    
end