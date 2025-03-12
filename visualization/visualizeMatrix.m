function visualizeMatrix(A)
    % Visualize matrix with color differentiation and opacity scaling
    % (1,1) is at the top-left, (n,n) at the bottom-right

    % Flip the matrix to match desired orientation
    A = flipud(A); 
    
    % Get matrix size
    [rows, cols] = size(A);
    
    % Compute absolute values for opacity scaling
    maxVal = max(abs(A(:)));
    if maxVal == 0
        maxVal = 1; % Avoid division by zero
    end
    
    % Create figure
    % figure;
    hold on;
    
    % Loop through each matrix entry
    for i = 1:rows
        for j = 1:cols
            value = A(i,j);
            if value ~= 0
                % Determine color: Blue for positive, Red for negative
                if value > 0
                    color = [0, 0, 1]; % Blue (positive)
                else
                    color = [1, 0, 0]; % Red (negative)
                end
                
                % Opacity based on relative magnitude (proper scaling)
                alpha = abs(value) / maxVal;
                
                % Draw a filled square with correct opacity
                x = j - 0.5;
                y = i - 0.5;
                rectangle('Position', [x, y, 1, 1], 'FaceColor', color, 'EdgeColor', 'none', 'FaceAlpha', 1.0);
            end
        end
    end
    
    % Adjust axes and labels
    xlim([0, cols]);
    ylim([0, rows]);
    % set(gca, 'XTick', 1:cols, 'YTick', 1:rows, 'YDir', 'reverse', 'TickLength', [0 0]);
    grid on;
    box on;
    title('Matrix Visualization');
    xlabel('Columns');
    ylabel('Rows');
    hold off;
end
