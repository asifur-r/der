function printTimeStats(currentTime, finalTime, timeStep)
    % Prints the current time, time step, and a text-based progress bar
    % in the console.

    persistent startTime

    if isempty(startTime)
        tic; % Start the timer only on the first call
        startTime = tic; % store the tic
    end

    % elapsedTime = toc(startTime); % Get elapsed time since the first call to tic

    elapsedTime = duration(0,0,toc(startTime), 'Format', 'hh:mm:ss');

    fprintf("Time: %.4f s, Step: %.4f s, Elapsed: %s, ", currentTime, timeStep, elapsedTime);

    barWidth = 50; % Width of the progress bar in characters

    percentComplete = (currentTime / finalTime) * 100;

    fullBlockChar = char(9608);     % Unicode for a full block character
    emptyBlockChar = char(9617);    % Unicode for a light shade block character

    numBlocksFilled = floor((percentComplete / 100) * barWidth);
    numBlocksEmpty = barWidth - numBlocksFilled;

    progressBar = ['[' ...
                   repmat(fullBlockChar, 1, numBlocksFilled) ...
                   repmat(emptyBlockChar, 1, numBlocksEmpty) ...
                   ']'];

    fprintf('Progress: %s %5.2f%%', progressBar, percentComplete);

    fprintf('\n');

end
