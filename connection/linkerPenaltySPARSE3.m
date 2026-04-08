function [F, K] = linkerPenaltySPARSE3(Rods, conn, sys)
    % Returns the penalty force vector and sparse stiffness matrix for linkers using structured cell storage.
    % Sparse indices for F and K, and K matrix are computed only once during analysis uspsing persistent variables, only value of F changes

	persistent IF_p IK_p JK_p VK_p initialized
	
    % Extract state vectors from each rod
    qs = {Rods.q};

    % Number of connection
    nconn = size(conn, 1);

    % Cell size for preallocation
    sz = nconn * 6; % Total entries (2 nodes + 1 edge) * 2 sides

	% Always preallocate VF (they change every time)
    VF = cell(sz, 1);
    
    % Only preallocate the persistent I-indices if not initialized
    if isempty(initialized); IF_p = cell(sz, 1); IK_p = cell(sz, 1); JK_p = cell(sz, 1); VK_p = cell(sz, 1); end
	
	% Define three combos for each edge pairs
	com = {'M', 'm', 'translation'; 'N', 'n', 'translation'; 'E', 'e', 'torsion' };
	
    k = 1; % Use one consistent counter
    for i = 1:nconn
	for j = 1:2 % Loop over two elements of the liner
	
		c = conn(i, j);
		[mainRod, linkRod] = deal(c.R, c.r);
		
		for p = 1:3
            
            % Extract variables
            row = com(p, :);

			mainNode = c.(row{1});
            linkNode = c.(row{2});
            dofType  =    row{3};

			% Always compute Values
			VF{k} = linkerForce(mainRod, mainNode, linkRod, linkNode, qs, c.p, dofType);
			
			% Only compute Indices once
			if isempty(initialized)
				[IF_p{k}, IK_p{k}, JK_p{k}] = linkerIndices(mainRod, mainNode, linkRod, linkNode, sys.ndofpr, dofType); 
				VK_p{k} = linkerStiffness(c.p, dofType);
			end
			
			k = k + 1; % Increment AFTER filling everything for this iteration
		end
	end
    end

	% Flatten Values (Every time)
    VF = vertcat(VF{:});

	% Flatten and Lock Indices (First time only)
    if isempty(initialized); IF_p = vertcat(IF_p{:}); IK_p = vertcat(IK_p{:}); JK_p = vertcat(JK_p{:}); VK_p = vertcat(VK_p{:}); initialized = true; end

    % Build and return
    F = sparse(IF_p, ones(length(IF_p), 1), VF, sys.ndof, 1);
    K = sparse(IK_p, JK_p, VK_p, sys.ndof, sys.ndof);

    % Ensure matrix size consistency
    assert(isequal(size(K), [sys.ndof, sys.ndof]), 'Stiffness matrix size changed while adding penalty');
end

function [IF, IK, JK] = linkerIndices(R, N, r, n, ndofpr, dofType)
    
	switch dofType
	
	% Process positional constraints for node pairs using cell storage.
	case 'translation'
	
		% Compute system DOF indices
		r1 = node2sysdof(R, N, 1, ndofpr);
		r2 = r1 + 2;
		r3 = node2sysdof(r, n, 1, ndofpr);
		r4 = r3 + 2;
		
		p = r1:r2;
		q = r3:r4;

		% Store stiffness matrix entries
		[IK, JK] = getSparseIndices(p, q);

		% Store force vector entries
		IF = [p, q]';
	
	% Process torsional constraints for edge pairs using cell storage.
	case 'torsion'
		
		% Torsional DOF
		dof = 4;

		% Compute system DOF indices
		r1 = node2sysdof(R, N, dof, ndofpr);
		r2 = node2sysdof(r, n, dof, ndofpr);

		% Store stiffness matrix entries
		IK = [r1 r2 r1 r2]';
		JK = [r1 r2 r2 r1]';
		
		% Store force vector entries
		IF = [r1; r2];
		
	otherwise; error('Undefined dof dofType');
		
	end
	
end

function VK = linkerStiffness(kp, dofType)

	switch dofType
		
	% Process positional constraints for node pairs using cell storage.
	case 'translation'
	
		% Stiffness penalty terms
		pmat = diag([kp kp kp]);

		% Store stiffness matrix entries
		VK = [pmat(:); pmat(:); -pmat(:); -pmat(:)];
		
	% Process torsional constraints for edge pairs using cell storage.
	case 'torsion'
	
		% Store stiffness matrix entries
		VK = [kp kp -kp -kp]';
		
	otherwise; error('Undefined dof dofType');
		
	end
	
end

function VF = linkerForce(R, N, r, n, qs, kp, dofType)

	Rq = qs{R};
	rq = qs{r};
	
	switch dofType
		
	% Process positional constraints for node pairs using cell storage.
	case 'translation'
	
		% DOF indices
		dofs = [1 2 3];
		
		% Compute internal forces
		% node2dof performs slower
		RNq = Rq( 4*(N-1) + dofs); % Rq(node2dof(N, dofs));
		rnq = rq( 4*(n-1) + dofs); % rq(node2dof(n, dofs));
		fvec = kp * (RNq - rnq);

		% Store force vector entries
		VF = [fvec; -fvec];
		
	% Process torsional constraints for edge pairs using cell storage.
	case 'torsion'
		
		% Torsional DOF
		dof = 4;

		% Compute internal forces
		% node2dof performs slower
		RNq = Rq( 4*(N-1) + dof); % Rq(node2dof(N, dof));
		rnq = rq( 4*(n-1) + dof); % rq(node2dof(n, dof));
		f = kp * (RNq - rnq);

		% Store force vector entries
		VF = [f; -f];
		
	otherwise; error('Undefined dof dofType');
		
	end
	
end

function [i, j] = getSparseIndices(p, q)
    % Generates i, j indices for a sparse block.

    % Ensure p and q are column vectors
    p = p(:); q = q(:);

    % Anonymous function generating the indices
    getIds = @(r, c) deal(repelem(r, length(c)), repmat(c, length(r), 1));
 
    % Create cells for the indices
    i = cell(4, 1);
    j = cell(4, 1);

    % Combinations of p and q in a cell array
    com = {[p, p], [q, q], [p, q], [q, p]};
    
    % Get the ids for each combination
    for k = 1:4; [i{k}, j{k}] = getIds(com{k}(:, 1), com{k}(:, 2)); end
    
    % Flatten the cells
    i = vertcat(i{:});
    j = vertcat(j{:});

end