function sol = jacobianResidual(Rods, conn, ana, sys, sol)
    
    % Locally define variables
    fr = sys.frdof; nfr = sys.nfrdof; Fext = sol.Fext; dt = ana.dt; betaN = ana.betaN;

    % Get system level internal force and stiffness (only stacks F and K for multi rods)
    [Fi, Kt] = stackForceStiffness(Rods);
    
    % Add linker penalty force and stiffness
    if ~isempty(conn); [Fl, Kl] = linkerPenaltyFULL(Rods, conn, sys); Fi = Fi+Fl; Kt = Kt+Kl; end

    % Store full sized Fi, used in livplot, recorder
    sol.FINT = Fi;

    % Based on constraint type calculate required things and set the other case things to zero
    switch ana.constraint

        case 'elimination'
            % Compute force vector for prescribed disp (if any), otherwise Fpd = 0
            Fpd = presDispForce(sys, sol, Kt);
            
            % Make the penalty terms zero
            Fcp = zeros(nfr, 1); Kcp = zeros(nfr);

        case 'penalty'
            [Fcp, Kcp] = constraintPenaltyFULL(ana, sol, sys);

            % Make prescribed forces zero
            Fpd = zeros(nfr, 1);
            
    end

    % The 'fr' indexing works for both elimination and penalty because 
    % for penalty, fr referes to all dofs, which gives the entire vector/matrix

    % External force vector
    Fe = sol.FextFactor(fr).*Fext(fr) + Fcp + Fpd;

    % Internal force vector
    Fi = Fi(fr);

    % Residual
    R = Fe - Fi;

    % Stiffness matrix
    Kt = Kt(fr, fr) + Kcp;

    % Jacobian
    J = Kt + Kcp;

    % Add dynamic terms to J and R if necessary
    if strcmp(ana.type, 'dynamic')

        % Mass matrix
        M = massMatrixFULL(sol.Mdiag); M = M(fr, fr);

        % Damping force
        if ~isempty(ana.damping) 
            
            C = rayleighDamping(M, Kt, ana.alpha, ana.beta);
            Fd = C * sol.vp(fr);

            % Add damping to the external force vector
            Fe = Fe + Fd * dt;

        else
            % No damping
            C = 0; %Fd = 0;
        end

        % Update Jacobian and residual
        if strcmp(ana.integration, 'euler')
            
            % J = J + M / dt^2 + C / dt;
            J = J * dt^2 + M + C * dt;

            % R = R - M * (sol.u(fr) - sol.up(fr)) / dt^2 + M * sol.vp(fr) / dt;
            R = R * dt^2 - M * (sol.u(fr) - sol.up(fr)) + M * sol.vp(fr) * dt;
        
        elseif strcmp(ana.integration, 'newmark')
            
            J = J * dt^2 * betaN^2 + M + C * dt;    
            R = R * dt^2 * betaN^2 + (sol.Fep(fr) - sol.Fip(fr)) * dt^2 * betaN * (1 - betaN) - M * (sol.u(fr) - sol.up(fr)) + M * sol.vp(fr) * dt;
            
        end
        

    end

    sol.J = J;
    sol.R = R;

    sol.Fe = Fe;
    sol.Fi = Fi;

end