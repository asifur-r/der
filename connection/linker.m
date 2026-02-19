function links = Linker(pairs, sec, mat, penalty)
    % Returns list of LinkSpec objects
    % For now it assigns the same section, material, penalty to all the linkers

    % pairs = two column matrix of paired rods
    % sec = Section object
    % mat = Material object
    % penalty = pentaly stiffness for linker

    % Number of pairs
    npairs = size(pairs, 1);

    % Check if there is any pair
    if npairs == 0; links = []; return; end
    
    % Proceed if there is pair/s

    % Preallocate LinkerSpec objects
    links = LinkerSpec.empty(0, npairs);

    % Build the linker spec list
    for i = 1:npairs; links(i) = LinkerSpec(pairs(i, :), sec, mat, penalty); end

end