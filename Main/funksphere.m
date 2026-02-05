function y=funksphere(x)

sum = 0;
for i = 1 : 2
    sum = sum + (x(i))^2;
end
% Decision variables are used to form the objective function.
y = sum;


end