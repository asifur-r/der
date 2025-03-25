function val = node2dof(nodeTag, dofTag)
    % Fast mapping of node DOFs to global indices

    % Validate inputs once (only when necessary)
    % if any(dofTag < 1 | dofTag > 4)
    %     error("Local dof tag must be between 1 and 4");
    % end

    % Direct computation (avoid element-wise operations)
    val = 4 * (nodeTag - 1) + dofTag;
end
