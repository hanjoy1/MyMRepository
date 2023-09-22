function [XDOT] = RCAM_model(X,U)

%---------------------------״̬������---------------------%
% ״̬ʸ��
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

%------------------------����------------------------------%
m = 120000;  % ������

cbar = 6.6; % ƽ�����������ҳ�(m)
lt = 24.8; %  �������ĵ�β���ľ���(m)
S = 260; % �������(m^2)
St = 64; % β�����(m^2)

Xcg = 0.23*cbar; % ����λ��x(m)
Ycg = 0; % ����λ��y(m)
Zcg = 0.10*cbar; % ����λ��z(m)

Xac = 0.12*cbar; % ��������λ��x(m)
Yac = 0; % ��������λ��y(m)
Zac = 0; % ��������λ��z(m)

%����������
Xapt1 = 0; % ������������λ��x(m)
Yapt1 = -7.94; % ������������λ��y(m)
Zapt1 = -1.9; % ������������λ��z(m)

Xapt2 = 0; % ������������λ��x(m)
Yapt2 = 7.94; % ������������λ��y(m)
Zapt2 = -1.9; % ������������λ��z(m)

%��������
rho = 1.225; % �����ܶ�(kg/m^3)
g = 9.81; % �������ٶ�(m/s^2)
depsda = 0.25; % ��ϴ���湥�ǵĸı���(rad/rad)
alpha_L0 = -11.5*pi/180; % ��������(rad)
n = 5.5; % ̧��б�����������б��
a3 = -768.5; % ����ϵ�� alpha3
a2 = 609.2; % ����ϵ�� alpha2
a1 = -155.2; % % ����ϵ�� alpha1
a0 = 15.212; % % ����ϵ�� alpha0
alpha_switch = 14.5*(pi/180); % ������ ����������ԵĽ��ӵ�

%------------------------1. �����޷�------------------------------%
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

%------------------------2. �м����------------------------------%
% ���� �����ٶ�
Va = sqrt(x1^2 + x2^2 + x3^2);

% ���㹥�ǺͲ໬��
alpha = atan2(x3,x1);
beta = asin(x2/Va);

% ���㶯ѹ
Q = 0.5*rho*Va^2;

% ������ϵ�µ��ٶȺͽ��ٶ�
wbe_b = [x4;x5;x6];
V_b = [x1;x2;x3];

%------------------------3. ��������ϵ��------------------------------%
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

%������ϵ��
CL = CL_wb + CL_t ;

%������ϵ��(������β�������)
CD = 0.13 + 0.07 *(5.5*alpha + 0.654)^2;

%�໬��ϵ��
CY = -1.6*beta + 0.24*u3;

%------------------------4. ��������------------------------------%
% ������stability axis �ϵ���
FA_s = [-CD*Q*S;
        CY*Q*S;
        -CL*Q*S;];
% ��ת������ϵ
C_bs = [cos(alpha) 0 -sin(alpha);
        0 1 0;
        sin(alpha) 0 cos(alpha);];
    
FA_b = C_bs*FA_s;

%------------------------5. ������������ϵ��------------------------------%
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

%------------------------6. ������������������������------------------------------%
% 
MAac_b = CMac_b * Q * S * cbar;

%------------------------7. ��������������������------------------------------%
rcg_b = [Xcg;Ycg;Zcg];
rac_b = [Xac;Yac;Zac];
MAcg_b = MAac_b + cross(FA_b,rcg_b-rac_b);
    
%------------------------8. ��������������------------------------------%
% ��
F1 = u4*m*g;
F2 = u5*m*g;
  
% ���跢�������������� 
FE1_b = [F1;0;0];
FE2_b = [F2;0;0];   
FE_b = FE1_b + FE2_b;

% ����
mew1 = [Xcg-Xapt1;
        Yapt1-Ycg;
        Zcg-Zapt1];
mew2 = [Xcg-Xapt2;
        Yapt2-Ycg;
        Zcg-Zapt2];   
    
MEcg1_b = cross(mew1,FE1_b);
MEcg2_b = cross(mew2,FE2_b);
MEcg_b = MEcg1_b + MEcg2_b;   

%------------------------9. ����ЧӦ------------------------------%    
% ������ ת����ϵ��
g_b = [-g*sin(x8);
        g*cos(x8)*sin(x7);
        g*cos(x8)*cos(x7);];

Fg_b = m*g_b;

%------------------------10. ״̬΢��------------------------------%  
Ib = m*[40.07 0 -2.0923;
        0 64 0;
        -2.0923 0 99.92];
invIb = inv(Ib); %����д���˷�ʱ��
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



    








