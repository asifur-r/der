classdef Series
    properties
        type    % 'constant', 'linear', 'rectangle', 'sawtooth', 'triangle', 'trapezoid'
        value   % Peak value
        params  % Structure to hold ta, tb, tc, td
    end

    methods
        function obj = Series(type, value, varargin)
            % Constructor with input validation

            obj.type = lower(type);
            obj.value = value;

            switch obj.type
                case 'constant'
                    assert(obj.value >= 0, "Value must be positive.");
                    assert(numel(varargin) == 0, "Constant time series takes no time parameter.");

                case 'linear'
                    assert(numel(varargin) == 2, 'Linear time series requires ta and tb.');
                    [obj.params.ta, obj.params.tb] = deal(varargin{:});

                case 'rectangle'
                    assert(numel(varargin) == 2, 'Rectangle time series requires ta and tb.');
                    [obj.params.ta, obj.params.tb] = deal(varargin{:});

                case 'sawtooth'
                    assert(numel(varargin) == 2, 'Sawtooth time series requires ta and tb.');
                    [obj.params.ta, obj.params.tb] = deal(varargin{:});
                
                case 'triangle'
                    assert(numel(varargin) == 3, 'Triangle time series requires ta, tb, and tc.');
                    [obj.params.ta, obj.params.tb, obj.params.tc] = deal(varargin{:});

                case 'trapezoid'
                    assert(numel(varargin) == 4, 'Trapezoid time series requires ta, tb, tc, and td.');
                    [obj.params.ta, obj.params.tb, obj.params.tc, obj.params.td] = deal(varargin{:});

                otherwise
                    error('Invalid time series type.');
            end
        end
    end

    methods
        function value = getValue(obj, t)
            % Get value based on time series type
            switch obj.type
                case 'constant'
                    value = obj.constant(t);
                case 'linear'
                    value = obj.linear(t);
                case 'rectangle'
                    value = obj.Rectangle(t);
                case 'sawtooth'
                    value = obj.sawtooth(t);
                case 'triangle'
                    value = obj.triangle(t);
                case 'trapezoid'
                    value = obj.trapezoid(t);
                otherwise
                    error('Invalid time series type.');
            end
            value = obj.value * value; % Scale by peak value
        end

        function value = constant(obj, t)
            value = 1;
        end

        function value = linear(obj, t)
            ta = obj.params.ta; 
            tb = obj.params.tb;
            if t <= ta
                value = 0;
            elseif t >= tb
                value = 1;
            else
                value = (t - ta) / (tb - ta);
            end
        end

        function value = Rectangle(obj, t)
            ta = obj.params.ta;  
            tb = obj.params.tb;
            value = (t >= ta && t < tb);
        end

        function value = sawtooth(obj, t)
            ta = obj.params.ta;
            tb = obj.params.tb;
            if t < ta
                value = 0;
            elseif t < tb
                value = (t - ta) / (tb - ta);
            else
                value = 0;
            end
        end

        function value = triangle(obj, t)
            ta = obj.params.ta;
            tb = obj.params.tb;
            tc = obj.params.tc;
            if t < ta
                value = 0;
            elseif t <= tb
                value = (t - ta) / (tb - ta);
            elseif t <= tc
                value = (tc - t) / (tc - tb);
            else
                value = 0;
            end
        end

        function value = trapezoid(obj, t)
            ta = obj.params.ta;
            tb = obj.params.tb;
            tc = obj.params.tc;
            td = obj.params.td;
            if t < ta
                value = 0;
            elseif t <= tb
                value = (t - ta) / (tb - ta);
            elseif t <= tc
                value = 1;
            elseif t <= td
                value = (td - t) / (td - tc);
            else
                value = 0;
            end
        end
    end
end
