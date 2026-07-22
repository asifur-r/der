function [J, R] = inertialNewmark(J, R, M, ana, sol, fr)
    
    dt = ana.dt; 
    b = ana.betaN;

    J = J * dt^2 * b^2 + M;
    R = R * dt^2 * b^2 + (sol.Fep(fr) - sol.Fip(fr)) * dt^2 * b * (1 - b) - M * (sol.u(fr) - sol.up(fr)) + M * sol.vp(fr) * dt;

end