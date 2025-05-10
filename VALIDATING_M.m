function [number]=VALIDATING_M(Input_Mat,Additive_Targets,net) %,theta,lob,upb
number=1;

Response_Mat=mean(Additive_Targets,1);
cvp = cvpartition(Response_Mat,'LeaveOut');
%r=size(Additive_Targets,1);
validit=cvp.NumTestSets;
% valid=min(validit,1000);
 ts=zeros(1,validit);
        for i=1:validit
            tst=test(cvp,i);
            trn = ~tst;
            inp=Input_Mat;
            inp(:,find(trn==0))=[];
            out=Response_Mat(trn);
            z=net(inp);
             delta=max(abs((mean(Response_Mat)-mean(z))/(sqrt(var(Response_Mat)+var(z)))));
             ts(i)=delta;
             delta=0;
        end
          ts=sum(ts)/length(Response_Mat)
      
      if ts<0.02
          number=0;
      end
end