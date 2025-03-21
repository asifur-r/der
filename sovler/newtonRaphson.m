function [du, dl] = newtonRaphson(Kt, R)
    
    du = Kt \ R;
    % condest(Kt)

    dl = 0;

end