function val = node2sysdof(rodTag, nodeTag, localdof, ndofspr)
    % Maps a rod level dof tag to system level (multi rod) dof tag

    % localdof = dof local to a node (1, 2, 3 or 4)
    % ndofspr = vector containing number of dofs in each rod

    % Node per rod list
    npr = (ndofspr + 1) / 4;

    % Check if the rod exists
    assert(rodTag <= length(npr), "Rod %d does not exist.", rodTag);

    % Check if the target node exist in the rod
    assert(nodeTag <= npr(rodTag), "Node %d does not exist in Rod %d.", nodeTag, rodTag);

    % Check for the last node, the target dof isn't 4
    assert(~(nodeTag == npr(rodTag) && any(localdof == 4)), "Last node %d in Rod %d does not have twist.", nodeTag, rodTag);

    % Rod level dof
    roddof = node2dof(nodeTag, localdof);

    % Cumulitive sum of dofs per rod vector
    cum = cumsum(ndofspr);

    % Map and return system level dof
    if rodTag == 1; val = roddof; else; val = cum(rodTag-1) + roddof; end
  
end