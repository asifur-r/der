function mref = referenceTwist(a1, t, mref)

    nele = size(mref, 1);

    for i = 2:nele

        % Tangent pair
        tp = t(i-1, :);
        tq = t(i, :);

        % Material director pair
        a1p = a1(i-1, :);
        a1q = a1(i, :);

        % Space parallel version of a1p from tp to tq tangent space
        Pa = parallelTransport(a1p, tp, tq);

        % The intermediate RPa vector in Fig. 5.4
        RPa = rotateVector(Pa, tq, mref(i) );
        
        % Get signed angle between RPa and the actual a1q
        delmref = signAngle(RPa, a1q, tq);

        % Eq. 5.20
        mref(i) = mref(i) + delmref;

    end
    
end

