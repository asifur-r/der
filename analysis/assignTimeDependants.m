function [Rods, sol] = assignTimeDependants(Rods, ana, sol, nrods)
    % Set time-dependent variables (Fext, Res, Prdisp) and return solver object

    % Time
    t = sol.t;

    % Extracting the only required fields from Rods
    R = struct(...
        'prdisp',   {Rods.prdisp}   , ...
        'prdispTag',{Rods.prdispTag}, ...
        'fext',     {Rods.fext}     , ...
        'fextTag',  {Rods.fextTag}  , ...
        'res',      {Rods.res}      , ...
        'resTag',   {Rods.resTag}   ...
        );

    % Process all sparse vectors in the same way
    sol.Prdisp = processTimeDependent(R, ana, t, nrods, 'prdisp', 'prdispTag');
    sol.Fext   = processTimeDependent(R, ana, t, nrods, 'fext', 'fextTag');
    sol.Res    = processTimeDependent(R, ana, t, nrods, 'res', 'resTag');

end

function result = processTimeDependent(Rods, ana, t, nrods, field, fieldTag)
    % Generic function to process time-dependent sparse vectors

    resultCell = cell(nrods, 1);

    for r = 1:nrods
        % Get sparse indices and values
        [ids, ~, vals] = find(Rods(r).(field)); 

        % Get time series tags
        [~, ~, tags] = find(Rods(r).(fieldTag));

        % Time series values
        tvals = arrayfun(@(i) ana.timeSeries(i).GetValue(t), tags);

        % Construct full sized zero vector
        valsFull = zeros(length(Rods(r).(field)), 1); 

        % Compute new values at time t and insert
        valsFull(ids) = vals .* tvals;

        % Store result into cell
        resultCell{r} = valsFull;
    end

    % Convert cell array to concatenated array
    result = vertcat(resultCell{:});
end


% function [Rods, sol] = assignTimeDependants(Rods, ana, sol, nrods)
%     % Set time-dependent variables (Fext, Res, Prdisp) and return solver object
    
%     % Add a default constant time series of zero value beforehand
%     timeSeries = [Series('constant', 0), ana.timeSeries];

%     % Time
%     t = sol.t;

%     % Preallocate cell arrays
%     Res = cell(nrods, 1);
%     Fext = cell(nrods, 1);
%     Prdisp = cell(nrods, 1);

%     for r = 1:nrods
%         % Precompute time series values for the given tags
%         resVals    = arrayfun(@(i) timeSeries(i).GetValue(t), Rods(r).resTag);
%         fextVals   = arrayfun(@(i) timeSeries(i).GetValue(t), Rods(r).fextTag);
%         prdispVals = arrayfun(@(i) timeSeries(i).GetValue(t), Rods(r).prdispTag);

%         % Element-wise multiplication
%         Res{r} = resVals .* Rods(r).res;
%         Fext{r} = fextVals .* Rods(r).fext;
%         Prdisp{r} = prdispVals .* Rods(r).prdisp;
%     end

%     % Convert cell arrays to concatenated arrays
%     sol.Res = vertcat(Res{:});
%     sol.Fext = vertcat(Fext{:});
%     sol.Prdisp = vertcat(Prdisp{:});
% end


% function [Rods, sol] = assignTimeDependants(Rods, ana, sol, nrods)
%     % Set time dependant variables (Fext, Res, Prdisp) and returns solver object

%     % Add a default constant time series of zero value beforehand
%     timeSeries = [Series('constant', 0), ana.timeSeries];

%     % Time
%     t = sol.t;
    
%     % Only need for the actual rods number (nrods)
%     Res     = arrayfun(@(r) arrayfun(@(i, j) timeSeries(i).GetValue(t) * j, Rods(r).resTag,     Rods(r).res),    1:nrods, 'UniformOutput', false);
%     Fext    = arrayfun(@(r) arrayfun(@(i, j) timeSeries(i).GetValue(t) * j, Rods(r).fextTag,    Rods(r).fext),   1:nrods, 'UniformOutput', false);
%     Prdisp  = arrayfun(@(r) arrayfun(@(i, j) timeSeries(i).GetValue(t) * j, Rods(r).prdispTag,  Rods(r).prdisp), 1:nrods, 'UniformOutput', false);

%     sol.Res    = vertcat(Res{:});
%     sol.Fext   = vertcat(Fext{:});
%     sol.Prdisp = vertcat(Prdisp{:});

% end