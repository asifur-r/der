function sol = assignTimeDependants(Rods, ana, sol)
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
        'resTag',   {Rods.resTag}   , ...
        'prmdiag',  {Rods.prmdiag}    , ...
        'prmdiagTag', {Rods.prmdiagTag}   ...
        );

    % Process all sparse vectors in the same way
    sol.Prdisp = processTimeDependent(R, ana, t, 'prdisp', 'prdispTag');
    sol.Fext   = processTimeDependent(R, ana, t, 'fext', 'fextTag');
    sol.Res    = processTimeDependent(R, ana, t, 'res', 'resTag');
    sol.Prmdiag= processTimeDependent(R, ana, t, 'prmdiag', 'prmdiagTag');

    % Add the static mass to the prescribed mass
    sol.Mdiag  = sol.staticMdiag + sol.Prmdiag;
end

function result = processTimeDependent(Rods, ana, t, field, fieldTag)
    % Generic function to process time-dependent sparse vectors

    resultCell = cell(length(Rods), 1);

    for r = 1:length(Rods)
        % Get sparse indices and values
        [ids, ~, vals] = find(Rods(r).(field)); 

        % Get time series tags
        [~, ~, tags] = find(Rods(r).(fieldTag));

        % Pre-allocate tvals
        tvals = zeros(length(tags), 1);
        
        % Time series values using a for loop
        for k = 1:length(tags); tvals(k) = ana.timeSeries(tags(k)).GetValue(t); end
        
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