function m = integratedTwist(q, mref)

    % Eq. 5.19
    % integrated twist, m = gam(i+1) - gamma(i) + mref
    % All quantities are from current time step

    % gam(i+1)
    thq = q(4:4:end);

    % gamma(i)
    thp = [0; thq(1:end-1)];

    m = thq - thp + mref;

end