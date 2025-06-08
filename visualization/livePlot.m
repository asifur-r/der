function livePlot(Rods, sol, visual)
    % Plots the 3d structure and live response plots during each step

    % Check if 3d plot is on, assign two slots for it
    if visual.deformed == true; nSlotForDeformed = 2; else; nSlotForDeformed = 0; end

    % Number of plots
    nResponsePlot = length(visual.dofs);

    % Numbe of total plots
    nplot = nResponsePlot + nSlotForDeformed;

    % Number of rods to plot
    nrod = length(Rods);

    % Counter of the number of plots so far
    % Used to select the correct subplot
    ctr = 0;
 
    % Plots the deformed shape of the system
    if visual.deformed == true
 
        % Select subplot
        subplot(1, nplot, [1 2])

        % for r = 1:nrod; plotRefAndDefGeom(Rods(r).q0, Rods(r).Q(:,end), r); end 
        for r = 1:nrod; plotRefAndDefGeom([], Rods(r).Q(:,end), r); end 

        if visual.triad == true; for r = 1:nrod; plotRotation(Rods(r).Q(:, end)); end; end
        if visual.nodetags == true; for r = 1:nrod; plotNodeTags(Rods(r).q0); end; end
        
        hold off
        drawnow;
        
        ctr = 2; 
    end

    % Deformation response plots
    for i = 1:nResponsePlot
        
        % Select subplot
        subplot(1, nplot, ctr+i)

        % Get the dofs
        d = visual.dofs (i);

        % Define x, y for plot
        rodLevelDof = node2dof(d.node, d.dof);
        
        switch visual.variable

            case 'forcedisp'
                x = Rods(d.rod).U(rodLevelDof,:);
                y = Rods(d.rod).FI(rodLevelDof,:);
                xlabel('Disp.')
                ylabel('Internal Force')

            case 'timehistory'
                x = [0 sol.T];
                y = Rods(d.rod).U(rodLevelDof,:);
                xlabel('Time (s)')
                ylabel('Disp.')

            otherwise; error("Visual property not specified correctly")
                
        end
        
        % Plot
        plot(x, y, '-ob');
        title(strcat('Rod:', num2str(d.rod), ' Node:', num2str(d.node), ' dof:', num2str(d.dof), ' Time:', num2str(sol.t) ))
        hold on
        grid on
        drawnow

    end

end