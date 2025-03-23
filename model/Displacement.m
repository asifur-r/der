function rod = Displacement(rod, nodesList, dofsList, valsList, tagsList)

    rod = assignLoadResDisp('prdisp', rod, nodesList, dofsList, valsList, tagsList);

end