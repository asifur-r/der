function mat = sinusoid(B, H, n, a, b, c)

    % B = Half base length 
    % H = Specimen height
    % a = Initial flat length 1
    % b = Initial flat length 2
    % c = Central flat length (half)

    eB = B - (a + b + c);
    nB = 5;
    n = n-nB-1;

    x = linspace(0, eB, n);
    z = H / 2 * (1 + sin( pi * (x/eB - 1/2) ) );

    x = [0 a+linspace(0, b, 5) a+b+x(2:end) B];
    z = [zeros(1,nB) z H];
    %size(x)
    %size(z)
    %plot(x, z, '-ob')
    mat = [x' zeros(length(x),1) z'];
    
end

% For getting points
%clf;pts=sinusoid(50, 20, 30, 10, 1.59);plot(pts(:,1),pts(:,3),'-ok')

% For the length of the sinusoid
%diffpts = diff(pts); sum((diffpts(:,1).^2+diffpts(:,3).^2).^(0.5))