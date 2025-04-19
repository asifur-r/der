classdef Series
    properties
        type    % 'constant', 'linear', 'rectangle', 'sawtooth', 'triangle', 'trapezoid'
        value   % Peak value
        params  % Structure to hold ta, tb, tc, td
    end

    properties (Access = private)
        getValFunc    % Function handle for time-dependent evaluation
    end

    methods
        function obj = Series(type, value, varargin)
            % Constructor with function handle assignment
            obj.type = lower(type);
            obj.value = value;

            switch obj.type
                case 'constant'
                    assert(obj.value >= 0, "Value must be positive.");
                    obj.getValFunc = @obj.constant;
                case 'linear'
                    assert(numel(varargin) == 2, 'Linear requires ta and tb.');
                    [obj.params.ta, obj.params.tb] = deal(varargin{:});
                    obj.getValFunc = @obj.linear;
                case 'rectangle'
                    assert(numel(varargin) == 2, 'Rectangle requires ta and tb.');
                    [obj.params.ta, obj.params.tb] = deal(varargin{:});
                    obj.getValFunc = @obj.rectangle;
                case 'sawtooth'
                    assert(numel(varargin) == 2, 'Sawtooth requires ta and tb.');
                    [obj.params.ta, obj.params.tb] = deal(varargin{:});
                    obj.getValFunc = @obj.sawtooth;
                case 'triangle'
                    assert(numel(varargin) == 3, 'Triangle requires ta, tb, tc.');
                    [obj.params.ta, obj.params.tb, obj.params.tc] = deal(varargin{:});
                    obj.getValFunc = @obj.triangle;
                case 'trapezoid'
                    assert(numel(varargin) == 4, 'Trapezoid requires ta, tb, tc, td.');
                    [obj.params.ta, obj.params.tb, obj.params.tc, obj.params.td] = deal(varargin{:});
                    obj.getValFunc = @obj.trapezoid;
                case 'smooth-reverse'
                    assert(numel(varargin) == 2, 'Smooth-reverse requires ta and tb.');
                    [obj.params.ta, obj.params.tb] = deal(varargin{:});
                    obj.getValFunc = @obj.smoothReverse;
                otherwise
                    error('Invalid time series type.');
            end
        end
    end

    methods
        function value = GetValue(obj, t)
            % Direct function handle call, avoiding switch-case overhead
            value = obj.value * obj.getValFunc(t);
        end

        function values = GetRangeValues(obj, tRange)
            % Efficiently computes values for a range of time points
            values = obj.value * arrayfun(@(t) obj.getValFunc(t), tRange);
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

        function value = rectangle(obj, t)
            ta = obj.params.ta;  
            tb = obj.params.tb;
            value = double(t >= ta && t < tb);
        end

        function value = sawtooth(obj, t)
            ta = obj.params.ta;
            tb = obj.params.tb;
            if t < ta || t >= tb
                value = 0;
            else
                value = (t - ta) / (tb - ta);
            end
        end

        function value = triangle(obj, t)
            ta = obj.params.ta;
            tb = obj.params.tb;
            tc = obj.params.tc;
            if t < ta || t > tc
                value = 0;
            elseif t <= tb
                value = (t - ta) / (tb - ta);
            else
                value = (tc - t) / (tc - tb);
            end
        end

        function value = trapezoid(obj, t)
            ta = obj.params.ta;
            tb = obj.params.tb;
            tc = obj.params.tc;
            td = obj.params.td;
            if t < ta || t > td
                value = 0;
            elseif t <= tb
                value = (t - ta) / (tb - ta);
            elseif t <= tc
                value = 1;
            else
                value = (td - t) / (td - tc);
            end
        end

        function value = smoothReverse(obj, t)
            ta = obj.params.ta;
            tb = obj.params.tb;
            if t <= ta
                value = 1;
            elseif t >= tb
                value = 0;
            else
                x = (t - ta) / (tb - ta);
                value = 1 - x^2 * (3 - 2*x);  % Reverse smoothstep
            end
        end

    end
end
