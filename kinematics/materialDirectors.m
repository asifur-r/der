function [m1, m2] = materialDirectors(a1, a2, gamma)
	
	nele = size(gamma, 1);
	
	m1 = zeros(nele, 3);
	m2 = zeros(nele, 3);
	
	for i=1:nele
	
		c = cos(gamma(i));
		s = sin(gamma(i));
		
		m1(i, :) =   c*a1(i, :) + s*a2(i, :);
		m2(i, :) = - s*a1(i, :) + c*a2(i, :);
		
	end
end