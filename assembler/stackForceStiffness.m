function [Fi, Kt] = stackForceStiffness(Rods, ana)
    % Returns system internal Fi and Kt just by stacking
    
    if ana.isParallel == true
        [fi, kt] = parallelProcess(Rods);
        % [fi, kt] = parallelProcess1(Rods);%, sys);
        % [fi, kt] = parallelProcess2(Rods, sys);
    else
        [fi, kt]  = serialProcess(Rods);
    end

    % Vertically stack f vectors
    Fi = vertcat(fi{:});

    % Diagonally stack k matrices using blkdiag
    Kt = blkdiag(kt{:});

end

function [fi, kt] = serialProcess(Rods)
    
    numRods = numel(Rods);
    
    % Output storage
    fi = cell(1, numRods);
    kt = cell(1, numRods);

    % Serial process
    for i = 1:numRods; [fi{i}, kt{i}] = allForceStiffness(Rods(i)); end

end

function [fi, kt] = parallelProcess(Rods)
  
    % Number of all rods
    numRods = numel(Rods);

    % Get which are linker rods (node = 3)
    isLinker = arrayfun(@(r) r.n == 3, Rods);

    % Find the numebr of main rods
    numMain = find(isLinker, 1) - 1;  % First linker index minus 1
    
    % Output storage
    fi = cell(1, numRods);
    kt = cell(1, numRods);
    
    % Serial process of linkers
    for i = numMain+1:numRods; [fi{i}, kt{i}] = allForceStiffness(Rods(i)); end

    % Parallel process of main rods
    parfor i = 1:numMain
        % Process rods and assign f and k
        [fi{i}, kt{i}] = allForceStiffness(Rods(i));
    end

end

% function [fi, kt] = parallelProcess1(Rods, sys)
    
%     numRods = sys.numRods;
%     numMain = sys.numMainRods;
    
%     % Output storage
%     fi = cell(1, numRods);
%     kt = cell(1, numRods);
    
%     % Serial process of linkers
%     for i = numMain+1:numRods; [fi{i}, kt{i}] = allForceStiffness(Rods(i)); end

%     % Parallel process of main rods
%     parfor i = 1:numMain
%         % Process rods and assign f and k
%         [fi{i}, kt{i}] = allForceStiffness(Rods(i));
%     end

% end

% function [fi, kt] = parallelProcess2(Rods, sys)
    
%     numRods = sys.numRods;
%     numMain = sys.numMainRods;
    
%     % Output storage
%     fi = cell(1, numRods);
%     kt = cell(1, numRods);
%     fevalOut = cell(1, numRods);

%     % Serial process of linkers
%     for i = numMain+1:numRods; [fi{i}, kt{i}] = allForceStiffness(Rods(i)); end
    
%     % Parallel process of main rods
%     for i = 1:numMain; fevalOut{i} = parfeval(@allForceStiffness, 2, Rods(i)); end
    
%     % Collect results as they finish
%     for i = 1:numMain; [fi{i}, kt{i}] = fetchOutputs(fevalOut{i}); end

% end
