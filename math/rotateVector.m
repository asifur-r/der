function vecRotated = rotateVector(vec, axis, angle)

    c = cos(angle);
    s = sin(angle);

    % Source: https://en.wikipedia.org/wiki/Rodrigues%27_rotation_formula
    vecRotated = vec * c + cross(axis, vec) * s + axis * dot(axis, vec) * (1 - c);

end
    