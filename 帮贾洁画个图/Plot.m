
global E B K s



%% 硬弹簧

E = 0.04;
B = 1;

for K = 0.05 :0.01:1

Amatrix = [];
for s = 0:0.01:3

% A = fsolve(@Fun_A);
A = fzero(@Fun_A,[0 10]);
% A = slove(@Fun);
Amatrix = [Amatrix,A];


end

%% 画图

%初始化画板
figure(1)
MyPlotStyle
xlabel('s')
ylabel('A')
hold on

% 画一根
s = 0:0.01:3;
plot(s,Amatrix)

% 加K值标注
str = num2str(K);
K_text = [0.05:0.2:1,1]; %加标准的线
if ismember(K,K_text) 
text(s(90),Amatrix(90),str)
end

end


%% 软弹簧
E = -0.04;
B = 1;

for K = 0.05 :0.01:1

Amatrix = [];
for s = 0:0.01:3

A = fzero(@Fun_A,[0,10]);
Amatrix = [Amatrix,A];

end

%% 画图

%初始化画板
figure(2)
MyPlotStyle
xlabel('s')
ylabel('A')
hold on

% 画一根
s = 0:0.01:3;
plot(s,Amatrix)

% 加K值标注
str = num2str(K);
K_text = [0.05:0.2:1,1]; %加标准的线
if ismember(K,K_text) 
text(s(90),Amatrix(90),str)
end

end


