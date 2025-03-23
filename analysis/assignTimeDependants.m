function [Rods, sol] = assignTimeDependants(Rods, ana, sol, nrods)
    % Set time dependant variables (Fext, Res, Prdisp) and returns solver object

    % Add a default constant time series of zero value beforehand
    timeSeries = [Series('constant', 0), ana.timeSeries];

    % Time
    t = sol.t;
    
    % Only need for the actual rods number (nrods)
    Res     = arrayfun(@(r) arrayfun(@(i, j) timeSeries(i).getValue(t) * j, Rods(r).resTag,     Rods(r).res),    1:nrods, 'UniformOutput', false);
    Fext    = arrayfun(@(r) arrayfun(@(i, j) timeSeries(i).getValue(t) * j, Rods(r).fextTag,    Rods(r).fext),   1:nrods, 'UniformOutput', false);
    Prdisp  = arrayfun(@(r) arrayfun(@(i, j) timeSeries(i).getValue(t) * j, Rods(r).prdispTag,  Rods(r).prdisp), 1:nrods, 'UniformOutput', false);

    sol.Res    = vertcat(Res{:});
    sol.Fext   = vertcat(Fext{:});
    sol.Prdisp = vertcat(Prdisp{:});

end