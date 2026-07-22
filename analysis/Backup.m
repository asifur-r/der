classdef Backup
    % Stores analysis state before attemping to solve
    % Provides Restore if fails

    properties (Access = private)
        sol
        rods
    end

    methods
        function obj = Backup(sol, rods)
            obj.sol = sol;
            obj.rods = rods;
        end

        function [sol, rods] = Restore(obj)
            sol = obj.sol;
            rods = obj.rods;
        end
    end
end