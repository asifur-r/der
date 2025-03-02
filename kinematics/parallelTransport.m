function vec = parallelTransport(v, tp, tq)

	% tp = k-1 th tangent
	% tq = k th tangent

	dotprod = dot(tp, tq);
	crossprod = cross(tp, tq);

	% Parallel transport tensor
    % Explicit version of Eq. 4.1 (just like Eq. 4.7)
	P = dotprod * eye(3) + skewt(crossprod) + 1 / (1 + dotprod) * kron(crossprod', crossprod);

	% Transport
	vec = (P * v')';

end