classdef TimeSeries
    properties
        tag     % Integer tag for the time series
        type    % 'linear', 'rectangular', or 'triangular'
        dt      % delta t
        tf      % final time
        params  % Parameters for the time series (struct)
        time    % Store time values for reference
        value   % Precomputed value vector
    end

    methods
        function obj = TimeSeries(tag, type, tf, dt, params)
            % Constructor
            obj.tag = tag;
            obj.type = lower(type);
            obj.params = params;
            obj.time = 0:dt:tf;  % Store the time vector
            obj.tf = tf;
            obj.dt = dt;
            obj.value = obj.generateValue(obj.time);
        end
    end

    methods (Access = private)
        function value = generateValue(obj, time)
            % Generate the value vector based on the time series type
            switch obj.type
                case 'linear'
                    value = arrayfun(@(t) obj.linear(t), time);
                case 'rect'
                    value = arrayfun(@(t) obj.rectangular(t), time);
                case 'tri'
                    value = arrayfun(@(t) obj.triangular(t), time);
                otherwise
                    error('Invalid time series type.');
            end
        end

        function value = linear(obj, t)
            % Linear time series: 0 if t<ta, 1 at t>=tb, ramps in between
            ta = obj.params.ta; % Extract values from params struct
            tb = obj.params.tb;
            if t <= ta
                value = 0;
            elseif t >= tb
                value = 1;
            else
                value = (t-ta) / (tb-ta);
            end
        end

        function value = rectangular(obj, t)
            % Rectangular pulse: 1 between ta and tb, 0 elsewhere
            ta = obj.params.ta;  % Extract values from params struct
            tb = obj.params.tb;
            if t >= ta && t <= tb
                value = 1;
            else
                value = 0;
            end
        end

        function value = triangular(obj, t)
            % Triangular wave: rise at ta, peak at tb, plateau, fall at tc, zero at td
            ta = obj.params.ta;
            tb = obj.params.tb;
            tc = obj.params.tc;
            td = obj.params.td;

            if t < ta
                value = 0;
            elseif t >= ta && t <= tb
                value = (t - ta) / (tb - ta); % Rising
            elseif t > tb && t <= tc
                value = 1; % Plateau
            elseif t > tc && t <= td
                value = (td - t) / (td - tc); % Falling
            else
                value = 0;
            end
        end
    end
end
