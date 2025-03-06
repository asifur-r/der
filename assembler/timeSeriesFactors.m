function sol = timeSeriesFactors(sys, sol)

    % Compute scaling factors (vectorized)
    sol.FextFactor   = cell2mat(arrayfun(@(idx) sys.timeSeries(idx).getValue(sol.t), sol.FextTag,   'UniformOutput', false));
    sol.PrdispFactor = cell2mat(arrayfun(@(idx) sys.timeSeries(idx).getValue(sol.t), sol.PrdispTag, 'UniformOutput', false));
    sol.ResFactor    = cell2mat(arrayfun(@(idx) sys.timeSeries(idx).getValue(sol.t), sol.ResTag,    'UniformOutput', false));
    
end