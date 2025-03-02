function livePlot(Rods, L, visual)
    % Plots the 3d structure and live response plots during each step

    % Check if 3d plot is on, assign two slots for it
    if visual.deformed == true; nSlotForDeformed = 2; else; nSlotForDeformed = 0; end

    % Number of response plots
    nDispPlot = length(visual.dispdofs);

    % Number of force plots
    nForcePlot = length(visual.forcedofs);

    % Numbe of total plots
    nplot = nDispPlot + nForcePlot + nSlotForDeformed;

    % Number of rods to plot
    nrod = length(Rods);

    % Counter of the number of plots so far
    % Used to select the correct subplot
    ctr = 0;

    % Plots the deformed shape of the system
    if visual.deformed == true

        % Select subplot
        subplot(1, nplot, [1 2])

        for r = 1:nrod; plotRefAndDefGeom(Rods(r).q0, Rods(r).Q(:,end), r); end; 

        if visual.triad == true; for r = 1:nrod; plotRotation(Rods(r).Q(:, end)); end; end
        if visual.nodetags == true; for r = 1:nrod; plotNodeTags(Rods(r).q0); end; end
        
        hold off
        drawnow;
        
        ctr = 2; 
    end
     

    % Deformation response plots
    for i = 1:nDispPlot
        
        % Select subplot
        subplot(1, nplot, ctr+i)

        % Get the dofs
        d = visual.dispdofs (i);

        % Define x, y for plot
        x = Rods(d.rod).U(node2dof(d.node, d.dof),:);
        y = L;

        % Plot
        plot(x, y, '-ob');
        title(strcat('Rod:', num2str(d.rod), ' Node:', num2str(d.node), ' dof:', num2str(d.dof) ))
        xlabel('Disp.')
        ylabel('Lamda')
        hold on
        grid on
        drawnow

    end

    % Update counter
    if nDispPlot ~= 0; ctr = ctr + i; end;
    

    % Force response plots
    for i = 1:nForcePlot
        
        % Select subplot
        subplot(1, nplot, ctr+i)

        % Get the dofs
        d = visual.forcedofs (i);

        % Define x, y for plot
        x = Rods(d.rod).U(node2dof(d.node, d.dof),:);
        y = Rods(d.rod).FI(node2dof(d.node, d.dof),:);

        % Plot
        plot(x, y, '-ob');
        title(strcat('Rod:', num2str(d.rod), ' Node:', num2str(d.node), ' dof:', num2str(d.dof) ))
        xlabel('Disp.')
        ylabel('Internal Force')
        hold on
        grid on
        drawnow
    end

end