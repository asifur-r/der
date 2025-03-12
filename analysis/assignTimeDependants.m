function [Rods, sol] = assignTimeDependants(Rods, ana, sol, nrods)
    % Set time dependant variables (Fext, Res, Prdisp) and returns solver object

    % Add a default constant time series of zero value beforehand
    timeSeries = [Series('constant', 0), ana.timeSeries];

    % Time
    t = sol.t;
    
    % Only need for actual rods
    for i = 1:nrods
        
        Rods(i).fext    = arrayfun(@(i) timeSeries(i).getValue(t), Rods(i).fextTag);
        Rods(i).res     = arrayfun(@(i) timeSeries(i).getValue(t), Rods(i).resTag);
        Rods(i).prdisp  = arrayfun(@(i) timeSeries(i).getValue(t), Rods(i).prdispTag);
        
    end

    % sol.Fext   = vertcat(Rods.fext);
    % sol.Res    = vertcat(Rods.res);
    % sol.Prdisp = vertcat(Rods.prdisp);
    
    sol.Fext   = vertcat(Rods.fext);
    sol.Res    = vertcat(Rods.res);
    sol.Prdisp = vertcat(Rods.prdisp);

end