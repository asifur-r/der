function  [converged, du, dl, du1] = foo(t, iter, K, R, Fext, Du, Dl, ds, du1)

    psi = 1.0;

    if(t > 1)
        A = Du'*Du + psi*Dl*Dl*(Fext)'*Fext - ds*ds;
        a = 2.0*Du';
        b = 2.0*psi*Dl*(Fext)'*Fext;
    else
        A = 0.0;
        a = 0.0*Du';
        b = 1.0;
    end

    rNorm = norm(R,2);
    rNorm = sqrt(rNorm*rNorm + A*A);

    fprintf(' rNorm : %5d ...  %12.6E \n', iter, rNorm);
    du = R*0;
    dl = 0;
    converged = false;

    if(rNorm < 1.0e-6); converged = true; return; end

    [L, U, P] = lu(sparse(K));

    %% solve the matrix system
    duu = L\(P*Fext);
    du1 = U\duu;

    duu = L\(P*R);
    du2 = U\duu;
    du2 = -du2; % this is because the Residual is added to the RHS

    dl = (a*du2 - A)/(b+a*du1);

    du = -du2 + dl*du1;
end