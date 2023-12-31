function [XDOT] = RCAM_model(X,U)

%---------------------------状态和输入---------------------%
% 状态矢量
x1 = X(1); %u
x2 = X(2); %v
x3 = X(3); %w
x4 = X(4); %p
x5 = X(5); %q
x6 = X(6); %r
x7 = X(7); %phi
x8 = X(8); %theta
x9 = X(9); %psi

u1 = U(1); %d_A (aileron)
u2 = U(2); %d_T (stabilizer)
u3 = U(3); %d_R (rudder)
u4 = U(4); %d_th1 (throttle 1)
u5 = U(5); %d_th2 (throttle 2)

%------------------------常量------------------------------%
m = 120000;  % 总质量

cbar = 6.6; % 平均空气动力弦长(m)
lt = 24.8; %  气动中心到尾部的距离(m)
S = 260; % 机翼面积(m^2)
St = 64; % 尾翼面积(m^2)

Xcg = 0.23*cbar; % 质心位置x(m)
Ycg = 0; % 质心位置y(m)
Zcg = 0.10*cbar; % 质心位置z(m)

Xac = 0.12*cbar; % 气动中心位置x(m)
Yac = 0; % 气动中心位置y(m)
Zac = 0; % 气动中心位置z(m)

%发动机常量
Xapt1 = 0; % 发动机作用力位置x(m)
Yapt1 = -7.94; % 发动机作用力位置y(m)
Zapt1 = -1.9; % 发动机作用力位置z(m)

Xapt2 = 0; % 发动机作用力位置x(m)
Yapt2 = 7.94; % 发动机作用力位置y(m)
Zapt2 = -1.9; % 发动机作用力位置z(m)

%其他常量
rho = 1.225; % 空气密度(kg/m^3)
g = 9.81; % 重力加速度(m/s^2)
depsda = 0.25; % 下洗角随攻角的改变量(rad/rad)
alpha_L0 = -11.5*pi/180; % 零升攻角(rad)
n = 5.5; % 抬升斜率线性区域的斜率
a3 = -768.5; % 升力系数 alpha3
a2 = 609.2; % 升力系数 alpha2
a1 = -155.2; % % 升力系数 alpha1
a0 = 15.212; % % 升力系数 alpha0
alpha_switch = 14.5*(pi/180); % 升力线 线性与非线性的交接点

%------------------------1. 控制限幅------------------------------%
% u1min = -25*pi/180;
% u1max = 25*pi/180;
% 
% u2min = -25*pi/180;
% u2max = 10*pi/180;
% 
% u3min = -30*pi/180;
% u3max = 30*pi/180;
% 
% u4min = 0.5*pi/180;
% u4max = 10*pi/180;
% 
% u5min = 0.5*pi/180;
% u5max = 10*pi/180;
% 
% if(u1>u1max)
%     u1 = u1max;
% elseif(u1<u1min)
%     u1 = u1min;
% end
% 
% if(u2>u2max)
%     u2 = u0max;
% elseif(u2<u1min)
%     u2 = u2min;
% end
% 
% if(u3>u3max)
%     u3 = u3max;
% elseif(u3<u3min)
%     u3 = u3min;
% end
% 
% if(u4>u4max)
%     u4 = u4max;
% elseif(u4<u4min)
%     u4 = u4min;
% end
% 
% if(u5>u5max)
%     u5 = u5max;
% elseif(u5<u5min)
%     u5 = u5min;
% end

%------------------------2. 中间变量------------------------------%
% 计算 空气速度
Va = sqrt(x1^2 + x2^2 + x3^2);

% 计算攻角和侧滑角
alpha = atan2(x3,x1);
beta = asin(x2/Va);

% 计算动压
Q = 0.5*rho*Va^2;

% 定义体系下的速度和角速度
wbe_b = [x4;x5;x6];
V_b = [x1;x2;x3];

%------------------------3. 空气动力系数------------------------------%
%CL_wb
if alpha<=alpha_switch
    CL_wb = n*(alpha-alpha_L0);
else
    CL_wb = a3*alpha^3+a2*alpha^2+a1*alpha+a0;
end

%CL_t
epsilon = depsda*(alpha - alpha_L0);
alpha_t = alpha - epsilon + u2 + 1.3*x5*lt/Va';
CL_t = 3.1*(St/S)*alpha_t;

%总升力系数
CL = CL_wb + CL_t ;

%总阻力系数(不考虑尾翼的阻力)
CD = 0.13 + 0.07 *(5.5*alpha + 0.654)^2;

%侧滑力系数
CY = -1.6*beta + 0.24*u3;

%------------------------4. 空气动力------------------------------%
% 计算在stability axis 上的力
FA_s = [-CD*Q*S;
        CY*Q*S;
        -CL*Q*S;];
% 旋转力到体系
C_bs = [cos(alpha) 0 -sin(alpha);
        0 1 0;
        sin(alpha) 0 cos(alpha);];
    
FA_b = C_bs*FA_s;

%------------------------5. 空气动力力矩系数------------------------------%
% 
eta11 =  -1.4 * beta;
eta22 = -0.59-(3.1*(St*lt)/(S*cbar))*(alpha-epsilon);
eta33 = (1-alpha*(180/(15*pi)))*beta;

eta = [eta11;eta22;eta33];

dCMdx = (cbar/Va) * [-11 0 5;0 (-4.03*(St*lt^2)/(S*cbar^2)) 0;1.7 0 -11.5];
dCMdu = [-0.6 0 0.22;
          0 (-3.1*(St*lt)/(S*cbar)) 0;
          0 0 -0.63];

CMac_b = eta + dCMdx*wbe_b + dCMdu*[u1;u2;u3];

%------------------------6. 空气动力力矩在气动中心上------------------------------%
% 
MAac_b = CMac_b * Q * S * cbar;

%------------------------7. 空气动力力矩在质心上------------------------------%
rcg_b = [Xcg;Ycg;Zcg];
rac_b = [Xac;Yac;Zac];
MAcg_b = MAac_b + cross(FA_b,rcg_b-rac_b);
    
%------------------------8. 发动机力和力矩------------------------------%
% 力
F1 = u4*m*g;
F2 = u5*m*g;
  
% 假设发动机力对其体轴 
FE1_b = [F1;0;0];
FE2_b = [F2;0;0];   
FE_b = FE1_b + FE2_b;

% 力矩
mew1 = [Xcg-Xapt1;
        Yapt1-Ycg;
        Zcg-Zapt1];
mew2 = [Xcg-Xapt2;
        Yapt2-Ycg;
        Zcg-Zapt2];   
    
MEcg1_b = cross(mew1,FE1_b);
MEcg2_b = cross(mew2,FE2_b);
MEcg_b = MEcg1_b + MEcg2_b;   

%------------------------9. 重力效应------------------------------%    
% 将重力 转到体系上
g_b = [-g*sin(x8);
        g*cos(x8)*sin(x7);
        g*cos(x8)*cos(x7);];

Fg_b = m*g_b;

%------------------------10. 状态微分------------------------------%  
Ib = m*[40.07 0 -2.0923;
        0 64 0;
        -2.0923 0 99.92];
invIb = inv(Ib); %这样写会浪费时间
% invIb = (1/m)*[0.0249836 0 0.000523151;
%                 0 0.015625 0;
%                 0.000523151 0 0.010019];


F_b = Fg_b + FE_b + FA_b;
x1to3dot = (1/m)*F_b - cross(wbe_b,V_b);

MCg_b = MAcg_b+MEcg_b;
x4to6dot = invIb*(MCg_b - cross(wbe_b,Ib*wbe_b));

H_phi = [1 sin(x7)*tan(x8) cos(x7)*tan(x8);
         0 cos(x7) -sin(x7);
         0 sin(x7)/cos(x8) cos(x7)/cos(x8)];
     
x7to9dot = H_phi*wbe_b;     

XDOT = [x1to3dot; x4to6dot; x7to9dot;];



    








