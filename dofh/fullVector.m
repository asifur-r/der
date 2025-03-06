function vec = fullVector(reducedVec, freeDofs, totalDofs)
    % Returns full sized vector from reduced size

    vec = zeros(totalDofs, 1);  % Create full-sized vector inside the function
    vec(freeDofs) = reducedVec; % Assign values to free DOFs
    
end
