%% plot
t = simX.Time;
u1 = simU.Data(:,1)*57.3;
u2 = simU.Data(:,2)*57.3;
u3 = simU.Data(:,3)*57.3;
u4 = simU.Data(:,4)*57.3;
u5 = simU.Data(:,4)*57.3;

x1 = simX.Data(:,1);
x2 = simX.Data(:,2);
x3 = simX.Data(:,3);
x4 = simX.Data(:,4)*57.3;
x5 = simX.Data(:,5)*57.3;
x6 = simX.Data(:,6)*57.3;
x7 = simX.Data(:,7)*57.3;
x8 = simX.Data(:,8)*57.3;
x9 = simX.Data(:,9)*57.3;

Ne = simPos_e.Data(:,1);
Ee = simPos_e.Data(:,2);
De = simPos_e.Data(:,3);

Phi = simPos_G.Data(:,1)*57.3;
Lam = simPos_G.Data(:,2)*57.3;
H = simPos_G.Data(:,3);

% 输入
figure(1)
subplot(5,1,1)
plot(t,u1)
legend('u_1')
grid on

subplot(5,1,2)
plot(t,u2)
legend('u_2')
grid on

subplot(5,1,3)
plot(t,u3)
legend('u_3')
grid on

subplot(5,1,4)
plot(t,u4)
legend('u_4')
grid on

subplot(5,1,5)
plot(t,u5)
legend('u_5')
grid on

% 状态
%
figure(2)
subplot(3,3,1)
plot(t,x1)
legend('x_1')
grid on

subplot(3,3,4)
plot(t,x2)
legend('x_2')
grid on

subplot(3,3,7)
plot(t,x3)
legend('x_3')
grid on

%
subplot(3,3,2)
plot(t,x4)
legend('x_4')
grid on

subplot(3,3,5)
plot(t,x5)
legend('x_5')
grid on

subplot(3,3,8)
plot(t,x6)
legend('x_6')
grid on

%
subplot(3,3,3)
plot(t,x7)
legend('x_7')
grid on

subplot(3,3,6)
plot(t,x8)
legend('x_8')
grid on

subplot(3,3,9)
plot(t,x9)
legend('x_9')  
grid on

%轨迹
figure(3)
axis equal
plot3(Ne,Ee,-De)
xlabel('N')
ylabel('E')
zlabel('H')

figure(4)
subplot(1,2,1)
plot(Phi,Lam);
subplot(1,2,2)
plot(t,H);