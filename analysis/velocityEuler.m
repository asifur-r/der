function sol = velocityEuler(sol, ana)

    sol.v = (sol.u - sol.up) / ana.dt;
    
end