function [du, dl] = newtonRaphson(Kt, R)
    
    du = Kt \ R;
    dl = 0;

end