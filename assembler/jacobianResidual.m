function sol = jacobianResidual(Rods, conn, ana, sys, sol)
    
    % Extract necessary variables
    fr = sys.frdof; Fext = sol.Fext;
    
    % Get system level internal force and stiffness (only stacks F and K for multi rods)
    [Fi, Kt] = stackForceStiffness(Rods);
    
    % Add linker penalty force and stiffness
    if ~isempty(conn); [Fl, Kl] = linkerPenaltySPARSE(Rods, conn, sys); Fi = Fi + Fl; Kt = Kt + Kl; end
    
    % Add equal dof penalty force and stiffness
    if ~isempty(ana.equalDof); [Feq, Keq] = equalDofPenaltySPARSE(ana, sol, sys); Fi = Fi + Feq; Kt = Kt + Keq; end

    % Store full sized Fi for livplot and recorder
    sol.FINT = Fi;

    % Handle constraints: elimination or penalty
    [Fcp, Kcp, Fpd] = applyConstraints(ana, sys, sol, Kt);    

    % Tangent stiffness matrix
    Kt = Kt(fr, fr);

    % External force vector
    Fe = Fext(fr) + Fcp + Fpd; % The 'fr' indexing works for both 'elimination' and 'penalty' because fr referes to all dofs in 'penalty', which gives the entire vector/matrix

    % Internal force vector
    Fi = Fi(fr); sol.Fi = Fi;

    % Residual
    R = Fe - Fi;

    % Jacobian
    J = Kt + Kcp;
    
    % Add dynamic terms to J and R if necessary
    [J, R, Fe] = applyDynamicTerms(J, R, Kt, Fe, ana, sol, sys);

    % Insert in solver object
    sol.J = sparse(J); sol.R = sparse(R); sol.Fe = Fe;

end


function [Fcp, Kcp, Fpd] = applyConstraints(ana, sys, sol, Kt)
    
    % Applies constraint handling based on elimination or penalty method
   
    % Number of system free dofs
    nfr = sys.nfrdof;

    % Based on constraint type calculate required things and set the other case things to zero
    switch ana.constraint

        case 'elimination'

            % Compute force vector for prescribed disp (if any), otherwise Fpd = 0
            Fpd = presDispForce(sys, sol, Kt);
            
            % Set the penalty terms zero
            Fcp = zeros(nfr, 1); Kcp = sparse(nfr, nfr);

        case 'penalty'

            % Set the prescribed forces zero
            Fpd = zeros(nfr, 1);
            
            % Compute penalty force and stiffness
            [Fcp, Kcp] = constraintPenaltySPARSE(ana, sol, sys);

    end

end

function [J, R, Fe] = applyDynamicTerms(J, R, Kt, Fe, ana, sol, sys)

    fr = sys.frdof; nfr = sys.nfrdof; dt = ana.dt; betaN = ana.betaN;

    if strcmp(ana.type, 'dynamic')

        % Mass matrix
        M = massMatrixSPARSE(sol.Mdiag); M = M(fr, fr);

        % Damping force
        if ~isempty(ana.damping) 
            
            % Should C be computed using Kt or J (=Kt+Kcp)?
            % C = rayleighDamping(M, Kt, ana.alpha, ana.beta);
            C = rayleighDamping(M, J, ana.alpha, ana.beta);
            Fd = C * sol.vp(fr);

            % Add damping to the external force vector
            Fe = Fe + Fd * dt;

        else
            % No damping
            % C = zeros(nfr); %Fd = 0;
            C = sparse(nfr);
        end

        % Update Jacobian and residual
        if strcmp(ana.integration, 'euler')
			
            J = J * dt^2 + M + C * dt;
            R = R * dt^2 - M * (sol.u(fr) - sol.up(fr)) + M * sol.vp(fr) * dt;
        
        elseif strcmp(ana.integration, 'newmark')
            
            J = J * dt^2 * betaN^2 + M + C * dt;    
            R = R * dt^2 * betaN^2 + (sol.Fep(fr) - sol.Fip(fr)) * dt^2 * betaN * (1 - betaN) - M * (sol.u(fr) - sol.up(fr)) + M * sol.vp(fr) * dt;
            
        end   

    end
    
end