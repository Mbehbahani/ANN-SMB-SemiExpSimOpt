%**************************************************************************
%THE CENTRAL PART OF THE META-MODEL BASED SIMULATION OPTIMIZATION ALGORITHM
%**************************************************************************
%PARAMETERS:
%Lower_Bound: The lower bounds of decision variables
%Upper_Bound: The upper bounds of decision variables
%dimension: The number of decision variables
%Num_o_Samples: The initial size of replicates at each design point
%Num_o_Design_points: The number of design points
%Max_Acceptance_error: The desirable threshold of mean squared error
%Input_Mat: The array of experimental design points
%Response_Mat: The array of simulation responses
%Mean_Response_Mat: The average of Response_Mat
%VAR_Response_Mat:The Variance of Response_Mat
%Optim_Sol: The output of optimization solver
%Num_o_Candidate: The number of Candidate design points
%B: The maximum number of bootstrap replicates
%None_Improving: The maximum number of non-improving iterations
function [gbest,SolutionEvaluation,gbest2]=main_core_ANN()
%*************************************************************************
clear all;
global  plot_handle dimension Num_o_Samples Num_o_Design_points Max_Acceptance_error Lower_Bound Upper_Bound m B Alpha_1 candidate_point f cntr
%**************************************************************************

f=@griewank;
Lower_Bound=[-8,-8];
Upper_Bound=[8,8];
%INITIALIZING
% f=@griewank;
% Lower_Bound=[-8,-8];
% Upper_Bound=[8,8];
% f=@operationfun;
%  Lower_Bound=[450,750];
%  Upper_Bound=[750,1050];
dimension=length(Lower_Bound);
Num_o_Samples=1; %simulation replication
Num_o_Design_points=50; %first points
Max_Acceptance_error=0.0001;
B=10;
Alpha_1=1;

Input_Mat=[];
Response_Mat=[];
Global_Optimum_Val=inf;
Global_Optimum_Sol=zeros(1,dimension);
Optim_Val=zeros(1,1);
Num_o_Candidate=0;
Iter=1;
Iteration1=1;
m=10;%30 new points in each iteration
candidate_point=[];
V=zeros(dimension,m);
Number=1;
cntr=0; %the counter of solution evaluation
clf; %Clear the plot
%**************************************************************************
%MAIN STRUCTURE
%**************************************************************************
%%
%GENERATING THE INITIAL EXPERIMENTAL DESIGN
tic
fprintf('\nTHE STOCHASTIC OPTIMIZATION ENVIRONMENT\n\n\n');
%[x,y]=SIMULATOR(f,Lower_Bound,Upper_Bound);
X1=[Lower_Bound(1) Lower_Bound(2);Lower_Bound(1) Upper_Bound(2);Upper_Bound(1) Lower_Bound(2);Upper_Bound(1) Upper_Bound(2)];
%X2=[(Lower_Bound(1)+Upper_Bound(1))/2 Lower_Bound(2);(Lower_Bound(1)+Upper_Bound(1))/2 Upper_Bound(2);(Lower_Bound(1)+Upper_Bound(1))/2 Lower_Bound(2);(Lower_Bound(1)+Upper_Bound(1))/2 Upper_Bound(2)];
Num_o_Design_points1=Num_o_Design_points-2^dimension;
X=lhsdesign(Num_o_Design_points1,dimension,'criterion','maximin').*repmat((Upper_Bound-Lower_Bound),Num_o_Design_points1,1)+repmat(Lower_Bound,Num_o_Design_points1,1); %Generating the pilot design
X=[X1;X];
figure (1)
%subplot(1,2,1)
plot(X(:,1),X(:,2),'b ^');
drawnow;
for i=1:Num_o_Design_points %Simulating the design points
    for r=1:Num_o_Samples, Additive_Targets(i,r)=f(X(i,:));cntr=cntr+1 ;end
    Response(i)=mean(Additive_Targets(i,:));
end
Additive_Targets=Additive_Targets';
x=X';
y=Response;
Input_Mat=[Input_Mat x];
Response_Mat=[Response_Mat y];
[global_Min_obj,Z]=min(Response_Mat);
Best_obj=global_Min_obj;
gbest=x(:,Z);
Best_sol=gbest;
Index=Z;
while Iter<=1
    fprintf('\n***********************************************************');
    fprintf('\nITERATION %d',Iter);
    fprintf('\n***********************************************************');
    for j=1:dimension
        V(j,:)=random('uniform',0,.2*(Upper_Bound(j)-Lower_Bound(j)),m,1);      %Initializing the velocities of particles
    end
    
    while (Number>=1) && Iteration1<4
        
        %     Input_Mat;
        %     Response_Mat;
                     
        net = feedforwardnet(15);
        net = configure(net,Input_Mat,Response_Mat);
        net = train(net,Input_Mat, Response_Mat);
        perf = perform(net,Input_Mat, Response_Mat)
        
        
        fprintf('\n\n THE BEST ANN META-MODEL WAS CONSTRUCTED');
        Number=VALIDATING_M(Input_Mat,Additive_Targets,net);
        
        [gbest,global_Min_obj,x,V,y,Targets]=HS_PSO1(x,V,y,Input_Mat,gbest,global_Min_obj);
        Num_o_Design_points=Num_o_Design_points+m;
        Input_Mat=[Input_Mat x];
        Response_Mat=[Response_Mat y];
        Additive_Targets=[Additive_Targets Targets];
        fprintf('\nITERATION1=%d ' ,Iteration1);
        Iteration1=Iteration1+1;
        
    end
    fprintf('\n\n THE ANN META-MODEL WAS VALIDATED...');
    fprintf('\nITERATION1=%d  BEST COST1=%-2.15f' ,Iteration1,global_Min_obj);
    BEST=gbest
    [gbest2,global_Min_obj,Iteration2]=HS_PSO2(x,V,y,Input_Mat,Response_Mat,gbest,global_Min_obj,net);
    Iteration1=Iteration1+Iteration2;
    fprintf('\n\n THE OPTIMAL SOLUTION IS FOUND...');
    fprintf('\nITERATION1=%d Iter=%d BEST COST=%-2.15f' ,Iteration1,Iter,global_Min_obj);
    fprintf('\noptimal solution\n');
    disp(gbest2)
    Iter=Iter+1;
    
    validation=f(gbest2)-global_Min_obj
    frealbest=f(gbest2)
    
  
    SolutionEvaluation=cntr
    toc
end
end