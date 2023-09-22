function y = Fun_A(A)

global E B K s

y = A - 1/sqrt( (1-s^2+3*E/4*A^2)^2 + (2*s*K)^2 )*B ;

