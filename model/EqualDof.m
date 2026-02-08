classdef EqualDof
    % Container for equal DOF constraints

    properties
        pairs = {};   % Cell array of structs
    end

    methods
        function obj = Insert(obj, masterRod, masterNode, slaveRod, slaveNode, dofs, penalty, tsTag)

            candidateRow = [masterRod, masterNode, slaveRod, slaveNode];

            if ~isempty(obj.pairs)
                % Construct matrix of existing entries
                matrix = cell2mat(cellfun(@(s) [s.masterRod, s.masterNode, s.slaveRod, s.slaveNode], obj.pairs, 'UniformOutput', false)');

                % Subtract the new row from existing rows
                diffMatrix = matrix - candidateRow;

                % Check for rows with all zeros
                matchIndex = find(all(diffMatrix == 0, 2), 1);

                if ~isempty(matchIndex)
                    % Update existing entry
                    obj.pairs{matchIndex}.dofs = dofs;
                    obj.pairs{matchIndex}.penalty = penalty;
                    obj.pairs{matchIndex}.timeSeriesTag = tsTag;
                else
                    % Append new entry
                    obj.pairs{end + 1} = struct('masterRod', masterRod, 'masterNode', masterNode, 'slaveRod', slaveRod, 'slaveNode', slaveNode, 'dofs', dofs, 'penalty', penalty, 'timeSeriesTag', tsTag);
                end
            else
                % First entry
                obj.pairs{1} = struct('masterRod', masterRod, 'masterNode', masterNode, 'slaveRod', slaveRod, 'slaveNode', slaveNode, 'dofs', dofs, 'penalty', penalty, 'timeSeriesTag', tsTag);
            end
        end
    end
end