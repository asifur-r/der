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

% function str = Linker(pairs, sec, mat, penalty)
%     % Returns stuct containing linker pair information
%     % For now it assigns the same section, material, penalty to all the linkers

%     % pairs = two column matrix of paired rods
%     % sec = section struct
%     % mat = material struct
%     % penalty = pentaly stiffness for linker

%     % Number of pairs
%     npairs = size(pairs, 1);

%     % Check if there is any pair
%     if npairs == 0; str = []; return; end
    
%     % Proceed if there is pair/s
%     str = arrayfun(@(i) struct('pair', pairs(i, :), 'section', sec, 'material', mat, 'penalty', penalty), 1:npairs);

% end