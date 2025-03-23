function [du, dl] = newtonRaphson(Kt, R)
  
    dl = 0;
    du = Kt \ R;

end