classdef SinusoidSeries
    
    properties
        % A Sinusoid object defining each segment
        sinusoid Sinusoid

        % Number of sinusoids in the series
        count
    end

    methods
        function obj = SinusoidSeries(sinusoid, count)
            % Constructor for SinusoidSeries class

            % Check if the sinusoid is half
            assert(sinusoid.isFull, 'SinusoidSeries only works with a full sinusoid')

            obj.sinusoid = sinusoid;
            obj.count = count;
        end

        function mat = Points(obj)
            % Returns coordinates of the series

            % Generate coordinates
            pts = obj.sinusoid.Points();
            
            % Concatenate segments by copying and translating
            mat = [];
            for i = 1:obj.count

                % Shift X coordinates by using translation vector
                transVec = [(i-1)*obj.sinusoid.L 0 0];
                translated = Geometry.TranslateByVector(pts, transVec);

                % Append
                mat = [mat(1:end-1,:); translated];
            end

        end

        function val = countNodes(obj)
            % Return the number of nodes in the line
            val = obj.count * (obj.sinusoid.N - 1) + 1;
        end

        function vec = Joints(obj)
            % Returns the joint node tags in the series
            % including the first and the last nodes
            vec = 1 : (obj.sinusoid.N-1) : obj.countNodes();
        end

        function vec = Peaks(obj)
            % Returns the peak node tags in the series

            % Get the joints tag
            joints = Joints(obj);

            % Shift the joint tags by the number of nodes in the half sinusoid and drop the last tag
            vec = floor(obj.sinusoid.N / 2) + joints(1:end-1);
        end
    end
end