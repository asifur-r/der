function mat = couplingMatrix(connection, ndofspr)
    % NOT USING. NEEDS CHECKING

    nsdof = sum(ndofspr);

    coupSigns = ones(1, nsdof);

    nconn = size(connection, 1);
    
    for i = 1:nconn
    for j = 1:2 % Two edges per connection

        % Current connection
        c = connection(i, j);

        if c.s == -1
            id = node2sysdof(c.R, c.E, 4, ndofspr); % not sure ?
            coupSigns(id) = -1; 
        end

    end
    end
  
    mat = diag(coupSigns);

end