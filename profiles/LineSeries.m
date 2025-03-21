classdef LineSeries
    
    properties
        % A Line object defining each segment
        line Line
        
        % Number of lines in the series
        count
    end

    methods
        function obj = LineSeries(line, count)
            % Constructor for LineSeries class
            obj.line = line;
            obj.count = count;
        end

        function mat = Points(obj)
            % Returns coordinates of the series

            % Generate coordinates for a segment
            pts = obj.line.Points();
            
            % Concatenate segments by copying and translating
            mat = [];
            for i = 1:obj.count

                % Shift X coordinates by using translation vector
                transVec = [(i-1)*obj.line.L 0 0];
                translated = Geometry.TranslateByVector(pts, transVec);

                % Append
                mat = [mat(1:end-1,:); translated];
            end

        end

        function val = countNodes(obj)
            % Return the number of nodes in the line
            val = obj.count * (obj.line.N - 1) + 1;
        end

        function vec = Joints(obj)
            % Returns the joint node tags in the series
            % including the first and the last nodes
            vec = 1 : (obj.line.N-1) : obj.countNodes();
        end
    end
end