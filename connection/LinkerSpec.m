classdef LinkerSpec
    properties
        pair
        section
        material
        penalty
    end

    methods
        function obj = LinkerSpec(pair, section, material, penalty)

            arguments
                pair     (1, 2) double {mustBeInteger, mustBePositive}
                section  (1, 1) Section
                material (1, 1) Material
                penalty  (1, 1) double {mustBePositive}
            end

            obj.pair     = pair;
            obj.section  = section;
            obj.material = material;
            obj.penalty  = penalty;
            
        end
    end
end