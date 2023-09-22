% ��ʼ��
clear
clc
close all
%% ˵���� ���ļ����ص�����ѵ������--������п�лҮά�桤�Ӽ��֣�Yuri Alekseyevich Gagarin��--����ɴ�[0 0 0]��ʼ����ܹ���ɷɵ�ָ���߶�2000m������

%% ����
x0 = [85;  % ��ʼ״̬
    0;     
    0;
    0;
    0;
    0;
    0;
    0;  %
    0];

Pos_G0 = [0,0,0]; % ��ʼλ�� ��γ��
TF = 60; %����ʱ��
%% �޷�
u1min = -25*pi/180;
u1max = 25*pi/180;

u2min = -25*pi/180;
u2max = 10*pi/180;

u3min = -30*pi/180;
u3max = 30*pi/180;

u4min =  0*pi/180;
u4max = 10*pi/180;

u5min = 0*pi/180;
u5max = 10*pi/180;




%% run

%% ��ģ��
mdl = "RCAMSimulation_DDPG";
open_system(mdl);

%% ��������
actInfo = rlNumericSpec([4,1]);
actInfo.LowerLimit = [u1min,u2min,u3min,u4min]';
actInfo.UpperLimit = [u1max,u2max,u3max,u4max]';
actInfo.Name = 'Control';
obsInfo = rlNumericSpec([10,1],...
    'LowerLimit',[0,0,0,-inf,-inf,-inf,-20/57.3,-20/57.3,-180/57.3,0]',...
    'UpperLimit',[300,40,40,inf,inf,inf,20/57.3,20/57.3,180/57.3,4000]');
obsInfo.Name = 'observations';
angentblk = mdl+'/RL Agent';
env = rlSimulinkEnv(mdl,angentblk,obsInfo,actInfo);


%% �������ʱ��
Ts = 0.02;
%% �̶����������
rng(0)

%% ����DDPGAgent
% Define path for the state input
statePath = [
    featureInputLayer(prod(obsInfo.Dimension),Name="NetObsInLayer")
    fullyConnectedLayer(128)
    reluLayer
    fullyConnectedLayer(200,Name="sPathOut")];

% Define path for the action input
actionPath = [
    featureInputLayer(prod(actInfo.Dimension),Name="NetActInLayer")
    fullyConnectedLayer(200,Name="aPathOut",BiasLearnRateFactor=0)];

% Define path for the critic output (value)
commonPath = [
    additionLayer(2,Name="add")
    reluLayer
    fullyConnectedLayer(1,Name="CriticOutput")];

% Create layerGraph object and add layers
criticNetwork = layerGraph(statePath);
criticNetwork = addLayers(criticNetwork,actionPath);
criticNetwork = addLayers(criticNetwork,commonPath);

% Connect paths and convert to dlnetwork object
criticNetwork = connectLayers(criticNetwork,"sPathOut","add/in1");
criticNetwork = connectLayers(criticNetwork,"aPathOut","add/in2");
criticNetwork = dlnetwork(criticNetwork);

% summary(criticNetwork);
% plot(criticNetwork);

critic = rlQValueFunction(criticNetwork, ...
    obsInfo,actInfo,...
    ObservationInputNames="NetObsInLayer", ...
    ActionInputNames="NetActInLayer");

actorNetwork = [
    featureInputLayer(prod(obsInfo.Dimension))
    fullyConnectedLayer(128)
    reluLayer
    fullyConnectedLayer(200)
    reluLayer
    fullyConnectedLayer(prod(actInfo.Dimension))
    tanhLayer
    scalingLayer(Scale=max(actInfo.UpperLimit))];

actorNetwork = dlnetwork(actorNetwork);
summary(actorNetwork)

actor = rlContinuousDeterministicActor(actorNetwork,obsInfo,actInfo);


% ѧϰ���� �Ż���
criticOptions = rlOptimizerOptions(LearnRate=1e-03,GradientThreshold=1);
actorOptions = rlOptimizerOptions(LearnRate=5e-04,GradientThreshold=1);
% GPU or cpu
% useGpu = ture;
% if useGpu
%     criticOptions.UseDevice = "gpu";
%     actorOptions.UseDevice = "gpu";
% end
agentOptions = rlDDPGAgentOptions(...
    SampleTime=Ts,...
    ActorOptimizerOptions=actorOptions,...
    CriticOptimizerOptions=criticOptions,...
    ExperienceBufferLength=1e6,...
    MiniBatchSize=128);

agentOptions.NoiseOptions.Variance = 0.4;
agentOptions.NoiseOptions.VarianceDecayRate = 1e-5;

agent = rlDDPGAgent(actor,critic,agentOptions);

%% ѵ��
maxepisodes = 200000;
maxsteps = ceil(TF/Ts);
trainingOptions = rlTrainingOptions(...
    MaxEpisodes=maxepisodes,...
    MaxStepsPerEpisode=maxsteps,...
    ScoreAveragingWindowLength=5,...
    Verbose=false,...
    Plots="training-progress",...
    StopTrainingCriteria="AverageReward",...
    StopTrainingValue= 3000,...
    SaveAgentCriteria="EpisodeReward",...
    SaveAgentValue= 3000);

doTraining = true;

if doTraining    
    % Train the agent.
    trainingStats = train(agent,env,trainingOptions);
else
    % Load the pretrained agent for the example.
    load("agent_YAG.mat","agent")
end

save("agent_YAG_2309222",'agent');

% simOptions = rlSimulationOptions(MaxSteps=500);
% experience = sim(env,agent,simOptions);











