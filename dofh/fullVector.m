function vec = fullVector(reducedVec, freeDofs, totalDofs)
    % Returns full sized vector from reduced size

    assert(length(reducedVec) == length(freeDofs))

    vec = zeros(totalDofs, 1);  % Create full-sized vector inside the function
    vec(freeDofs) = reducedVec; % Assign values to free DOFs
    
end
