function sol = jacobianResidual(Rods, conn, ana, sys, sol)
    
    % Locally define variables
    lam = sol.lam; Fext = sol.Fext; fr = sys.frdof; nfr = sys.nfrdof;

    % Get system level internal force and stiffness (only stacks F and K for multi rods)
    [Fi, Kt] = stackForceStiffness(Rods);
    
    % Add linker penalty force and stiffness
    if ~isempty(conn); [Fl, Kl] = linkerPenaltyFULL(Rods, conn, sys); Fi = Fi+Fl; Kt = Kt+Kl; end
    
    % Full sized internal force vector (only required for post processing in driver.m)
    sol.Fi = Fi;

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
    Fe = lam*Fext(fr) + Fcp + Fpd;

    % Internal force vector
    Fi = Fi(fr);

    % Residual
    R = Fe - Fi;

    % Stiffness matrix
    Kt = Kt(fr, fr);

    % Jacobian
    J = Kt + Kcp;

    % Add dynamic terms to J and R if necessary
    if strcmp(ana.type, 'dynamic')

        % Mass matrix
        M = massMatrixFULL(sol.Mdiag); M = M(fr, fr);

        % Damping force
        if ~isempty(ana.damping) 
            switch ana.damping
                
                case 'vertices'
                    % Fd = ana.eta * ones(nfr, 1) .* sol.vp(fr);
                    % C = ana.eta  * eye(nfr) * ones(nfr, 1) * ana.dt;

                case 'rayleigh' 
                    C = rayleighDamping(M, Kt, ana.alpha, ana.beta);
                    Fd = C * sol.vp(fr);
            end
        else
            % No damping
            Fd = 0; C = 0;
        end

        % Jacobian
        J = J + M / ana.dt^2 + C / ana.dt;
        
        % Residual
        R = Fe - Fi - M * (sol.u(fr) - sol.up(fr)) + M * sol.vp(fr) * ana.dt + Fd * ana.dt;


    end

    sol.J = J;
    sol.R = R;

end