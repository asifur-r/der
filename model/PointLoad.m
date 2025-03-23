function rod = PointLoad(rod, nodesList, dofsList, valsList, tagsList)
    
    rod = assignLoadResDisp('fext', rod, nodesList, dofsList, valsList, tagsList);

end