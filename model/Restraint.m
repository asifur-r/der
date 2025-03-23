function rod = Restraint(rod, nodesList, dofsList, valsList, tagsList)

    % Allow only 1 or 0 for restraint assignment, treating any non-zero values as 1
    % valsList = double(valsList~=0);

    % Need to check for constant or rect time series for support

    rod = assignLoadResDisp('res', rod, nodesList, dofsList, valsList, tagsList);

end