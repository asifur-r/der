function [J, R] = inertialEuler(J, R, M, ana, sol, fr)
   
    dt = ana.dt;

    J = J * dt^2 + M;
    R = R * dt^2 - M * (sol.u(fr) - sol.up(fr)) + M * sol.vp(fr) * dt;
    
end