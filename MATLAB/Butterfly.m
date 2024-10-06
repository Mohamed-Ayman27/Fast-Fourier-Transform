function [Sum,Diff] = Butterfly(In1,In2)
%     
%     Sum_r = real(In1) + real(In2);
%     Diff_r = real(In1) - real(In2);
%     
%     Sum_i = imag(In1) + imag(In2);
%     Diff_i = imag(In1) - imag(In2);
%     
%     Sum = Sum_r + 1i*Sum_i;
%     Diff = Diff_r + 1i*Diff_i;

Sum = In1+In2;
Diff = In1-In2;
end

