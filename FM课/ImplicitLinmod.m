function [E,A_P,B_P] = ImplicitLinmod(MY_FUN,XDOT0,X0,U0,DXDOT,DX,DU)

% 获得状态变量和控制变量数目
n = length(XDOT0);
m =length(U0);

%----------------------------计算E矩阵-------------------------------------
E = zeros(n,n);

for i = 1:n
    for j = 1:n
        dxdot = DXDOT(i,j);
        xdot_plus = XDOT0;
        xdot_minus = XDOT0;
        
        xdot_plus(j) = xdot_plus(j) + dxdot;
        xdot_minus(j) = xdot_minus(j) - dxdot;
        
        F = feval(MY_FUN,xdot_plus,X0,U0);
        F_plus_keep = F(i);
        
        F = feval(MY_FUN,xdot_minus,X0,U0);
        F_minus_keep  = F(i);
        
        E(i,j) = (F_plus_keep - F_minus_keep) / (2*dxdot);
    end
end  

%----------------------------计算A_p矩阵------------------------------------
A_P = zeros(n,n);

for i =1:n
    for j =1:n
        
        dx = DX(i,j);
        
        x_plus = X0;
        x_minus = X0;
        
        x_plus(j) = x_plus(j) + dx;
        x_minus(j) = x_minus(j) - dx;
        
        F = feval(MY_FUN,XDOT0,x_plus,U0);
        F_plus_keep = F(i);
        
        F = feval(MY_FUN,XDOT0,x_minus,U0);
        F_minus_keep = F(i);
        
        A_P(i,j) = (F_plus_keep - F_minus_keep) / (2*dx);
    end
end

%----------------------------计算B_P矩阵------------------------------------
B_P = zeros(n,m);

for i = 1:n
    for j =1:m
        
        du = DU(i,j);
        
        u_plus = U0;
        u_minus = U0;
        
        u_plus(j) = u_plus(j) + du;
        u_minus(j) = u_minus(j) - du;
        
        F = feval(MY_FUN,XDOT0,X0,u_plus);
        F_plus_keep = F(i);
        
        F = feval(MY_FUN,XDOT0,X0,u_minus);
        F_minus_keep = F(i);
        
        B_P(i,j) = (F_plus_keep - F_minus_keep) / (2*du);
    end
end
        
        
        
        
        
        
        
        
        
        
        


