function plotMeanStdDev(folderPath, n, cutoff)
    % Function to plot the mean data with standard deviation shading
    %
    % Inputs:
    % folderPath = path to the folder containing the CSV files
    % n = vector of indices for the data set files (e.g., [1, 2, 3])

    % Initialize arrays to store all x and y data
    allX = [];
    allY = [];

    % Plot the mean with standard deviation as shaded area
    figure;
    hold on;
    
    colors = ["r", "g", "b"];

    % Loop through each file specified by the indices in n
    for i = 1:length(n)
        % Construct file name based on index
        fileName = fullfile(folderPath, sprintf('*_%d.csv', n(i)));
        fileInfo = dir(fileName);
        
        % Check if the file exists
        if isempty(fileInfo)
            error('File %s does not exist.', fileName);
        end
        
        % Load the data from the file
        data = readmatrix(fullfile(folderPath, fileInfo.name));
        
		% Extract x and y columns
        x = data(:, 2);
        y = data(:, 3);
        
		% Refine data based on cutoff point
		if ~exist("cutoffIndex", "var")
			cutoffIndex = find(x>cutoff, 1);
		    if isempty(cutoffIndex) || cutoffIndex > length(x); cutoffIndex = length(x); end
		end
        
		x = x(1:cutoffIndex);
		y = y(1:cutoffIndex);
        plot(x, y, colors(i));

        % Store x and y values
        allX = [allX, x];
        allY = [allY, y];
    end

    % Calculate mean and standard deviation
    meanX = mean(allX, 2);
    meanY = mean(allY, 2);
    stdY = std(allY, 0, 2);
    
    % Plot the filled region for standard deviation
    fill([meanX; flipud(meanX)], [meanY - stdY; flipud(meanY + stdY)], [0.8, 0.8, 1], 'FaceAlpha', 0.5, 'EdgeColor', 'none');
    
    % Plot the mean line
    plot(meanX, meanY, 'b-', 'LineWidth', 1.5);

    hold off;
end
