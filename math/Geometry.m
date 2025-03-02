classdef (Abstract) Geometry 

    properties (Constant)

        ORIGIN = [0 0 0];
        X_AXIS = [1 0 0];
        Y_AXIS = [0 1 0];
        Z_AXIS = [0 0 1];

    end

    methods (Static)

        function vec = UnitVector(vec)
        % Returns unit vector of a vector

            arguments
                vec (1, 3) {mustBeNumeric}
            end
            
            vec = vec/norm(vec);

        end
        
        function mat = RotationMatrix(rotationAxis, rotationAngle)
        % Returns rotation matrix about an axis [u v w] by an angle in radian

            arguments
                rotationAxis (1, 3) {mustBeNumeric}
                rotationAngle (1, 1) {mustBeNumeric}
            end
            
            % Get unit axis vector and decompose components
            unit = Geometry.UnitVector(rotationAxis);
            u = unit(1);
            v = unit(2);
            w = unit(3);

            % Compute trigonometric functions
            c = cos(rotationAngle);
            s = sin(rotationAngle);

            % Compute rotation matrix
            % Source: https://en.wikipedia.org/wiki/Transformation_matrix
            R = [
                    c+u^2*(1-c),    u*v*(1-c)-w*s,  u*w*(1-c)+v*s;
                    v*u*(1-c)+w*s,  c+v^2*(1-c),    v*w*(1-c)-u*s;
                    w*u*(1-c)-v*s,  w*v*(1-c)+u*s,  c+w^2*(1-c)
                ];

            mat = R;
        end

        function mat = RotateByAngle(points, rotationAxis, rotationAngle)
        % Returns points after rotating about an axis by an angle

            arguments
                points(:, 3) {mustBeNumeric}
                rotationAxis (1, 3) {mustBeNumeric}
                rotationAngle (1, 1) {mustBeNumeric}
            end
            
            % Compute rotation matrix
            rotationMatrix = Geometry.RotationMatrix(rotationAxis, rotationAngle);

            % Apply rotation to points
            rotatedPoints = (rotationMatrix * points')';

            mat = rotatedPoints;

        end

        function mat = RotateToVector(points, currentAxis, direction)
        % Returns points after orienting its reference axis to the target dircetion
    
                arguments
                    points(:, 3) {mustBeNumeric}
                    currentAxis (1, 3) {mustBeNumeric}
                    direction (1, 3) {mustBeNumeric}
                end
                
                % Get unit vectors of axis and direction
                unitAxis = Geometry.UnitVector(currentAxis);
                unitDirection = Geometry.UnitVector(direction);
                
                % Compute rotation axis and angle
                rotationAxis = cross(unitAxis, unitDirection);
                rotationAngle = acos(dot(unitAxis, unitDirection));
                
                % Returns without any rotation if the current axis and the direction the are same
                if norm(rotationAxis) < eps; mat = points; return; end

                % Compute rotation matrix
                rotationMatrix = Geometry.RotationMatrix(rotationAxis, rotationAngle);

                % Apply rotation to points
                rotatedPoints = (rotationMatrix * points')';

                mat = rotatedPoints;
    
            end

        function mat = TranslationMatrix(vec)
        % Returns trnaslation matrix for a vector [u v w]
            
            arguments
                vec (1, 3) {mustBeNumeric}
            end

            % Decompose components
            u = vec(1);
            v = vec(2);
            w = vec(3);

            % Compute translation matrix
            % Source: https://en.wikipedia.org/wiki/Translation_(geometry)
            R = [
                    1   0   0   u;
                    0   1   0   v;
                    0   0   1   w
                    0   0   0   1
                ];

            mat = R;
        end

        function mat = TranslateByVector(points, vec)
        % Returns points after translating by a vector

            arguments
                points(:, 3) {mustBeNumeric}
                vec (1, 3) {mustBeNumeric}
            end
            
            % Convert points to homogeneous points by adding a 4th column filled with 1s
            homogeneous = [points ones(size(points,1), 1)];

            % Translate points
            translated = (Geometry.TranslationMatrix(vec) * homogeneous')';

            % Return first three columns [X Y Z], 4th column is filled with 1s
            mat = translated(:, 1:3);

        end

    end

end

