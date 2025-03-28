function [Fi, Kt] = stackForceStiffness(Rods, ana, sys)
    % Returns system internal Fi and Kt just by stacking

    % Filter out some growing fields
    Rods = rmfield(Rods, {'Q', 'U', 'V', 'FI'});

    % Store force vectors and stiffness matrices of all rods
    % [fi, kt] = arrayfun(@(r) allForceStiffness(r), Rods, 'UniformOutput', false);
 
    [fi, kt, tser]  = serialProcess(Rods, sys);
    % [fi, kt, tpar1] = parallelProcess1(Rods, sys);
    % [fi, kt, tpar2] = parallelProcess2(Rods, sys);

    % Vertically stack f vectors
    Fi = vertcat(fi{:});

    % Diagonally stack k matrices using blkdiag
    Kt = blkdiag(kt{:});

    % Write to file
    % filename = 'timing.txt'; fid = fopen(filename, 'a'); fprintf(fid, '%.3f, %.3f, %.3f\n', tser, 10, tpar2); fclose(fid);

end

function [fi, kt, t] = serialProcess(Rods, sys)
    
    numRods = sys.numRods;
    
    % Output storage
    fi = cell(1, numRods);
    kt = cell(1, numRods);

    % Serial process
    tic; for i = 1:numRods; [fi{i}, kt{i}] = allForceStiffness(Rods(i)); end; t = toc;
    
end

function [fi, kt, t] = parallelProcess1(Rods, sys)
    
    numRods = sys.numRods;
    numMain = sys.numMainRods;
    
    % Output storage
    fi = cell(1, numRods);
    kt = cell(1, numRods);
    
    % Serial process of linkers
    tic; for i = numMain+1:numRods; [fi{i}, kt{i}] = allForceStiffness(Rods(i)); end;

    % Parallel process of main rods
    
    parfor i = 1:numMain
        % Open file and start time
        fid = fopen('workload.txt', 'a'); workerid = getCurrentTask().ID; tstart = tic;
        
        % Process rods and assign f and k
        [f, k] = allForceStiffness(Rods(i)); fi{i} = f; kt{i} = k;

        % Stop timer, and write to file
        tworker = toc(tstart); fprintf(fid, '%d, %.3f\n', workerid, tworker); fclose(fid);
    end
    t = toc;

end

function [fi, kt, t] = parallelProcess2(Rods, sys)
    
    numRods = sys.numRods;
    numMain = sys.numMainRods;
    
    % Output storage
    fi = cell(1, numRods);
    kt = cell(1, numRods);
    fevalOut = cell(1, numRods);

    % Serial process of linkers
    tic; for i = numMain+1:numRods; [fi{i}, kt{i}] = allForceStiffness(Rods(i)); end
    
    % Parallel process of main rods
    tic
    for i = 1:numMain
        fevalOut{i} = parfeval(@allForceStiffness, 2, Rods(i));
    end
    
    % Collect results as they finish
    for i = 1:numMain
        [fi{i}, kt{i}] = fetchOutputs(fevalOut{i});
    end
    t = toc;

end
