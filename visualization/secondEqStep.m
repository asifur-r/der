function val = secondEqStep(force)
    % Returns time step of the second equilibrium

    % Initialize a counter to keep track of zero-crossings
    zeroCtr = 0;
    
    % Loop through the force values to find zero-crossings
    for i = 2:length(force)

        % Check if the current force value is positive and the previous was negative
        if force(i) > 0 && force(i-1) <= 0

            % Crossed zero, increse counter
            zeroCtr = zeroCtr + 1;
            
            % If this is the second zero-crossing, return the corresponding displacement
            if zeroCtr == 2; val = i; return; end

        end
    end
    
    % If no second zero-crossing is found, return NaN
    warning('Second zero-crossing not found.'); val = NaN;

end