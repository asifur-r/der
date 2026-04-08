function plotTimeSeries(timeSeriesArray, tstart, tfinal, dt, tnow)
    % plotSeries Plots an array of Series objects over a given time range
    %
    % Inputs:
    %   timeSeriesArray - Array of Series objects
    %   tstart      - Start time
    %   tfinal      - End time
    %   dt          - Time step for evaluation
    %
    % Example usage:
    %   s1 = Series('linear', 5, 0, 10);
    %   s2 = Series('triangle', 8, 2, 5, 8);
    %   plotSeries([s1, s2], 0, 10, 0.1);

    % Initialize figure
    %figure; 
   
    trange = tstart:dt:tfinal;

    colors = lines(numel(timeSeriesArray)); % Generate distinct colors
    
    % Number of time series
    numSeries = numel(timeSeriesArray);

    % Plot counter
    count = 1;

    % Plot each series
    for i = 1:numSeries
        subplot(numSeries+1, 1, count)
        y = timeSeriesArray(i).GetRangeValues(trange); % Evaluate series at each time point
        plot(trange, y, 'Color', colors(i, :), 'LineWidth', 1.5, 'DisplayName', sprintf('Series %d', i));
        % legend('show');
        title(sprintf('Series %d', i))
        grid on;
        count = count + 1;
    end
    
    % Labels and legend
    xlabel('Time (s)');
    % ylabel('Value');
    % title('Time Series Plot');
    grid on;
    drawnow
end
