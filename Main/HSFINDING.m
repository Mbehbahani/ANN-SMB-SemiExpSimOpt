function [X,Number_o_HS,candidate_point]=HSFINDING(Input_Mat)


%%%%Finding the spatial holes
%**************************************************************************
global  Upper_Bound Lower_Bound dimension
%**************************************************************************
%INITIALIZING
%**************************************************************************
paramt=size(Input_Mat,1);
b=Upper_Bound;
a=Lower_Bound;
Number_o_HS=5;
X=lhsdesign(Number_o_HS,dimension,'criterion','maximin').*repmat((Upper_Bound-Lower_Bound),Number_o_HS,1)+repmat(Lower_Bound,Number_o_HS,1);
X=X';
Number_o_HS=5;
 candidate_point=X;
end
% while   Number_o_HS<=5
% % % % % %         for i=1:paramt
% % % % % %         c=(b(i)-a(i))/2;
% % % % % %          if isempty(find((g<0)==1))
% % % % % %           hole= 
% % % % % %     input_mat(i,:)
%         for i=1:paramt
%           area(i)=rand*(b(i)-a(i))+a(i);
%         end
%         HS(:,Number_o_HS)=area;
%         area=[];
%          Number_o_HS=Number_o_HS+1;  
% end
%  Number_o_HS=5;
% candidate_point=HS;
% end
