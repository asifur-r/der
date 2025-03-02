function compactMatrix(M, tol)
    % Gemini
    
    [rows, cols] = size(M);

    for i = 1:rows
        for j = 1:cols
            if abs(M(i,j)) < tol
                fprintf('%6s ', '.');  % Print 6 spaces for alignment
            else
                fprintf('%6.2f ', M(i,j));  % Print element with 2 decimal places
            end
        end
        fprintf('\n');  % Newline after each row
    end
        
end