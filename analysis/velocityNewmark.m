function sol = velocityNewmark(sol, ana)

    sol.v = (sol.u - sol.up) / (ana.dt * ana.betaN) - (1 - ana.betaN) / ana.betaN * sol.vp;
    
end