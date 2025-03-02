function val = node2dof(nodeTag, dofTag)
    % Maps local dof (dofTag=1, 2, 3 or 4) of a node to rod level dof
    % nodeTag and dofTag can be vectors (multi nodes and dofs)

    if ~all(dofTag > 0 & dofTag < 5); error("Local dof tag must be between 1 and 4"); end
    %if dofTag > 4 || dofTag < 1; error("Local dof tag must be between 1 and 4"); end

    val = 4*(nodeTag - 1) + dofTag;

end