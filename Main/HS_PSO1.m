function [gbest,global_Min_obj,x,V,y,Targets]=HS_PSO1(x,V,y,Input_Mat,gbest,global_Min_obj)
%**************************************************************************
%HOLE SPACES-PARTICLE SWARM OPTIMIZATION METAHUERISTIC 1
%**************************************************************************
%This function executes the HS-PSO algorithm.

%PARAMETERS:
%f: The special code of the nonlinear program NLP
%C1: The cognitive factor
%C2: The social factor
%k: The constriction coefficient factor
%m: The number of particles
%dimension: The number of variables
%x: The matrix of positions
%V: The matrix of velocities
%y: The matrix ofmean of responses
%gbest: The position of the "best evaluated" particle
%Best_obj: The best objective value
%Best_Sol: The best solution
%Best_p_cost: The best fitness value of each particle
%global_Min_obj: The generalized Lagrangian function value of the "best evaluated" particle 
%Index: The index of "best evaluated" particle
%Iter: The number of iterations
%**************************************************************************
global  dimension Upper_Bound Lower_Bound m Num_o_Samples f Num_o_Design_points candidate_point cntr
 %f=@operationfun;
%**************************************************************************
%INITIALIZING
%**************************************************************************
C1=2.05;
C2=2.05;
phi=C1+C2;
k=2/abs(2-phi-sqrt(phi^2-4*phi));
Targets=zeros(Num_o_Samples,m);
weight=zeros(m,1);
X_HS=zeros(dimension,m);
%**************************************************************************
%MAIN STRUCTURE
%**************************************************************************
%%
%MINIMIZING THE LAGRANGIAN FUNCTION WITH RESPECT TO THE DECISION VARIABLES
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
  for j=1:m      %calculating distances of new points from hole spaces
      for i=1:Number_o_HS
          Distance(i)=sqrt((HS(:,i)-x(:,j))'*(HS(:,i)-x(:,j)));
      end
          [~,J]=min(Distance);
           X_HS(:,j)=HS(:,J);
  end
  Iteration_Min_obj=min(y(1,:));
  Iteration_Max_obj=max(y(1,:));
    
   for i=1:m
       weight(i)=(y(:,i)-Iteration_Min_obj/1.1)/(Iteration_Max_obj-Iteration_Min_obj);
       V(:,i)=0.9*(weight(i)*(X_HS(:,i)-x(:,i))+(1-weight(i))*0.5*(gbest-x(:,i))); %Modifying the velocities
       x(:,i)=x(:,i)+V(:,i); %Modifying the positions
                     
       for j=1:dimension
          if x(j,i)>Upper_Bound(j)
             x(j,i)=Upper_Bound(j);  %Scaling the solutions onto the bounds of decision variables 
          elseif x(j,i)<Lower_Bound(j)
             x(j,i)=Lower_Bound(j);
          end   
       end
       
       for j=1:Num_o_Design_points
         if x(:,i)==Input_Mat(:,j)
             x(:,i)=x(:,i)-0.5.*V(:,i);
         end
       end
       
      for r=1:Num_o_Samples
           Targets(r,i)=f(x(:,i));
           cntr=cntr+1;
      end
      y(:,i)=mean(Targets(:,i));
      if y(:,i)<=global_Min_obj
            global_Min_obj=y(:,i);
            gbest=x(:,i);
      end            
   end
   figure (1)
%   subplot(1,2,1);
   hold on
   plot(x(1,:),x(2,:),'r ^');
   drawnow;
end

%CHECKED/CHECKED/CHECKED/CHECKED