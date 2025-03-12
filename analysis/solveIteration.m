function [du, dl, err] = solveIteration(ana, sys, sol)
    % Returns the displacement increment, load increment and error term for the current iteration

    % Get jacobian and residual
    J = sol.J; 
    R = sol.R;

    switch ana.solver
        case 'nr'
            [du, dl] = newtonRaphson(J, R);

        case 'mgdm'            
            switch ana.constraint
                case 'elimination'; [du, dl] = modifiedDisplacement(J, R, sol.Fext(sys.frdof), ana.lam0, sol.i);
                case 'penalty';     [du, dl] = modifiedDisplacement(J, R, sol.Fext, ana.lam0, sol.i);
            end

    end

    % Norm of displacement increment
    err = norm(du);

end
