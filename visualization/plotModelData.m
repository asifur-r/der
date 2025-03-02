function plotModelData(modelDataFile, dispMult, loadMult, overlay)
	
    % Open new figure if not an overlay
    if ~strcmp(overlay, "on"); figure; else; hold on; end

    % Read data
	dt = readmatrix(modelDataFile);

    % Extract lambdas and displacements
    lam = dt(:,1);
    disp = dt(:,2);

    % Plot
    plot(dispMult*disp, loadMult*lam, '--k', 'LineWidth', 2)

end
