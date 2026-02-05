function [gbest,global_Min_obj,Iteration2]=HS_PSO2(x,V,y,Input_Mat,Response_Mat,gbest,global_Min_obj,net)
%**************************************************************************
%HOLE SPACES-PARTICLE SWARM OPTIMIZATION METAHUERISTIC 1
%**************************************************************************
%This function executes the HS-PSO algorithm.

%PARAMETERS:
%f: The special code of the nonlinear program NLP
%C1: The cognitive factor
%C2: The social factor
%k: The constriction coefficient factor
%c: The step size value
%m: The number of particles
%dimension: The number of variables
%X: The matrix of positions
%lam: The matrix of Lagrange multipliers
%V: The matrix of velocities
%Y: The matrix of violations
%pbest: The best position of particles
%gbest: The position of the "best evaluated" particle
%violation: The degree of violation of each particle 
%Best_obj: The best objective value
%Best_violation: The degree of violation of the "best evaluated" particle
%Best_Sol: The best solution
%Best_p_cost: The best fitness value of each particle
%global_Min_obj: The generalized Lagrangian function value of the "best evaluated" particle 
%Index: The index of "best evaluated" particle
%Iter: The number of iterations
%Status: The status of mathematical model: optimal, locally optimal or
 %locally infeasible

%**************************************************************************
global dimension Upper_Bound Lower_Bound m Num_o_Samples theta lob upb
%**************************************************************************
%INITIALIZING
%**************************************************************************
Iteration2=1;
C1=2.05;
C2=2.05;
phi=C1+C2;
k=2/abs(2-phi-sqrt(phi^2-4*phi));
Targets=zeros(Num_o_Samples,m);
weight=zeros(m,1);
X_HS=zeros(dimension,m);
theta=[10,10];
lob=[1e-1,1e-1];
upb=[50,50];
Q=(Upper_Bound-Lower_Bound)/20;
candidate_point=[];
%**************************************************************************
%MAIN STRUCTURE
%**************************************************************************
%%
%MINIMIZING THE LAGRANGIAN FUNCTION WITH RESPECT TO THE DECISION VARIABLES
%[dmodel,~]=dacefit(Input_Mat',Response_Mat',@regpoly0,@corrgauss,theta,lob,upb);
while Iteration2<=20
  Num_o_Candidate=size(candidate_point,2);
if Num_o_Candidate<=5
   if Num_o_Candidate==0
   [HS,Number_o_HS,candidate_point]=HSFINDING(Input_Mat); %RECOGNIZING HOLE SPACES
   else 
    HS=candidate_point;
    Number_o_HS=Num_o_Candidate;
    candidate_point=[];
   end
else
    for i=1:5
      r=random('Discrete Uniform',Num_o_Candidate,1,1);
      HS(:,i)=candidate_point(:,r);
      candidate_point(:,r)=[];
      Num_o_Candidate=Num_o_Candidate-1;
    end
    Number_o_HS=5;
end
  Distance=zeros(1,Number_o_HS);
  for j=1:m   %calculating distances of new points from hole spaces
      for i=1:Number_o_HS
          Distance(i)=sqrt((HS(:,i)-x(:,j))'*(HS(:,i)-x(:,j)));
      end
          [~,J]=min(Distance);
          X_HS(:,j)=HS(:,J);
  end
  [Iteration_Min_obj]=min(y);
  [Iteration_Max_obj]=max(y);
   for i=1:m
      weight(i)=(y(:,i)-Iteration_Min_obj)/(Iteration_Max_obj-Iteration_Min_obj);
      V(:,i)=k*(V(:,i)+weight(i)*rand*(X_HS(:,i)-x(:,i))+C2*rand*(gbest-x(:,i))); %Modifying the velocities
      %V(:,i)=k*(V(:,i)+C1*rand*(pbest(:,i)-X(:,i))+C2*rand*(gbest-X(:,i))); %Modifying the velocities
      x(:,i)=x(:,i)+V(:,i); %Modifying the positions
      Targets(i)=net(x(:,i));
      y(:,i)=Targets(i);
      t=1;
      while t<=10
          direction=rand(1,dimension,1);
          xx=x(:,i)+(Q.*direction)';
          yy=net(xx);
          if yy<y
             break
          end
          t=t+1;
      end
       
       for j=1:dimension
          if x(j,i)>Upper_Bound(j)
             x(j,i)=Upper_Bound(j);  %Scaling the solutions onto the bounds of decision variables 
          elseif x(j,i)<Lower_Bound(j)
             x(j,i)=Lower_Bound(j);
          end   
       end
       
       if y(:,i)<=global_Min_obj
            global_Min_obj=y(:,i);
            gbest=x(:,i);
            %Index=i;
       end            
    end
     %Input_Mat=[Input_Mat x];
     %Response_Mat=[Response_Mat y];
     Iteration2=Iteration2+1;
     fprintf('\nITERATION=%d  BEST COST=%-2.15f' ,Iteration2,global_Min_obj);
     
     
end
end

%CHECKED/CHECKED/CHECKED/CHECKED