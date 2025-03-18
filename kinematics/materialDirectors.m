function [m1, m2] = materialDirectors(a1, a2, gamma)
	% Returns material directors m1 and a2 by applying rotational transformations on reference directors a1 and a2

	% Number of elements
	nele = size(gamma, 1);
	
	% Initialize material directors
	m1 = zeros(nele, 3);
	m2 = zeros(nele, 3);
	
	for i=1:nele
	
		c = cos(gamma(i));
		s = sin(gamma(i));
		
		% Apply transformations to a1 and a2
		m1(i, :) =   c*a1(i, :) + s*a2(i, :);
		m2(i, :) = - s*a1(i, :) + c*a2(i, :);
		
	end
end