function vec = parallelTransport(v, tp, tq)

	% tp = k-1 th tangent
	% tq = k th tangent

	% Store the dot product and cross product
	dp = dot(tp, tq);
	cp = cross(tp, tq);

	skewtMatrix = [0 -cp(3) cp(2); cp(3) 0 -cp(1); -cp(2) cp(1) 0];

	% Parallel transport tensor
    % Explicit version of Eq. 4.1 (just like Eq. 4.7)
	% P = dp * eye(3) + skewt(cp) + 1 / (1 + dp) * kron(cp', cp);

    % Alternate calculation of P by not using kron and skewt function (faster)
    P = dp * eye(3) + skewtMatrix + 1 / (1 + dp) * (cp' * cp);

	% Transport
	vec = (P * v')';

end