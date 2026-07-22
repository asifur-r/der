function sol = assembleSystem(Rods, conn, ana, sys, sol)
    
    % Get system level internal force and stiffness (only stacks F and K for multi rods)
    [Fi, Kt] = stackForceStiffness(Rods, ana);
    
    % Add penalty contributions from linkers and equal DOFs
    [Fi, Kt] = applyElementPenalty(Fi, Kt, Rods, conn, ana, sol, sys);

    % Store full sized Fi for liveplot and recorder
    sol.FINT = Fi;

    % Handle constraints: elimination or penalty
    [Fcp, Kcp, Fpd] = computeConstraints(ana, sys, sol, Kt);    
    
    % Build reduced vectors
    [R, J, Fe, Fi] = buildReduced(sol, sys, Kt, Kcp, Fi, Fcp, Fpd);

    % Add dynamics terms
    [J, R, Fe] = applyDynamics(J, R, Fe, ana, sol, sys);
    
    % Insert in solver object
    sol = updateSystem(sol, J, R, Fe, Fi);
        
end

function [Fi, Kt] = applyElementPenalty(Fi, Kt, Rods, conn, ana, sol, sys)

    % Linker penalty contributions
    if ~isempty(conn)
        [Fl, Kl] = linkerPenaltySPARSE3(Rods, conn, sys);
        Fi = Fi + Fl;
        Kt = Kt + Kl;
    end

    % Equal DOF penalty contributions
    if ~isempty(ana.equalDof)
        [Feq, Keq] = equalDofPenaltySPARSE(ana, sol, sys);
        Fi = Fi + Feq;
        Kt = Kt + Keq;
    end

end

function [Fcp, Kcp, Fpd] = computeConstraints(ana, sys, sol, Kt)
    
    % Applies constraint handling based on elimination or penalty method
   
    % Number of system free dofs
    nfr = sys.nfrdof;

    % Based on constraint type calculate required things and set the other case things to zero
    switch ana.constraint

        case 'elimination'
            % Compute force vector for prescribed disp (if any), otherwise Fpd = 0
            Fpd = presDispForce(sys, sol, Kt);
            
            % Set the penalty terms zero
            Fcp = sparse(nfr, 1); 
            Kcp = sparse(nfr, nfr);

        case 'penalty'
            % Set the prescribed forces zero
            Fpd = sparse(nfr, 1);
            
            % Compute penalty force and stiffness
            [Fcp, Kcp] = constraintPenaltySPARSE(ana, sol, sys);

    end

end

function [R, J, Fe, Fi] = buildReduced(sol, sys, Kt, Kcp, Fi, Fcp, Fpd)
    % Build residual and Jacobian from system components

    fr = sys.frdof;

    % Reduce to free DOFs
    Kt = Kt(fr, fr);
    Fi = Fi(fr);
    Fext = sparse(sol.Fext(fr));

    % External force vector (with constraints)
    Fe = Fext + Fcp + Fpd;

    % Residual
    R = Fe - Fi;

    % Jacobian
    J = Kt + Kcp;

end

function [J, R, Fe] = applyDynamics(J, R, Fe, ana, sol, sys)
    % Apply all dynamic effects to the system
    
    if ~strcmp(ana.type, 'dynamic'); return; end

    fr = sys.frdof;
    dt = ana.dt;

    % Build mass matrix
    M = massMatrixSPARSE(sol.Mdiag); M = M(fr, fr);

    % Add inertial terms
    % [J, R] = addInertialTerms(J, R, M, ana, sol, fr);
    [J, R] = ana.inertialTerms(J, R, M, ana, sol, fr);

    % Add damping terms if present
    if ~isempty(ana.damping)
        [R, Fe] = addDampingTerms(R, Fe, ana, sol, fr, dt);
    end

end

function [R, Fe] = addDampingTerms(R, Fe, ana, sol, fr, dt)
    % Add damping contributions
    
    % Viscous damping force
    Fd = -ana.eta * sol.vp(fr);  % TODO: Multiply by voronoi length

    % Add damping terms
    R = R + Fd * dt^2;
    Fe = Fe + Fd;

    % Note: J is not modified by viscous damping (requires Rayleigh damping)
    % For Rayleigh damping: J = J + C * dt;
    % where C = rayleighDamping(M, Kt, ana.alpha, ana.beta)
end


function sol = updateSystem(sol, J, R, Fe, Fi)
    
    sol.J = J; 
    sol.R = R; 
    sol.Fe = Fe; 
    sol.Fi = Fi;

end