function [output_r,output_i] = SDF_FFT_Mixed(input_r,input_i)
%SDF_FFT128 Summary of this function goes here
%   this is 128_point FFT accepts real and imaginary values, apply SDF
%   algorithm the outputs reversed order frequency domain values
%   when changing between 128 and 64, see the lines that should be
%   commented and uncommented indicated by %128 or %64



nt = numerictype(input_r);
Word_length = nt.WordLength;
Int_length = nt.WordLength - nt.FractionLength;
Frac_length = nt.FractionLength;

F2 = fimath('SumMode', 'SpecifyPrecision', 'SumWordLength',...
    Word_length,'SumFractionLength', Frac_length, 'ProductMode',...
   'SpecifyPrecision', 'ProductWordLength', Word_length,'ProductFractionLength',...
   Frac_length,'OverflowAction',"Wrap",'RoundingMethod',"Floor");

const = fi(0.70710678,1,Word_length,Frac_length,F2);
fi_1i = fi(1i,1,Word_length,Frac_length,F2);



% FFT_point = 128;  %%%%%%%%128 NFFT
FFT_point = 64;  %%%%%%%%64 NFFT
%Twiddle_factor = exp(-(1i*2*pi*(0:(FFT_point/2)-1))/FFT_point)';


FFT_input  = input_r + 1i*input_i;
no_input_points = size(FFT_input,1);
if(no_input_points ~= FFT_point)
    FFT_input = [FFT_input;zeros(FFT_point-no_input_points,1)];
end
root2_2 = fi(0.70710678, 1, 20, 15);


%=========================================================================================%
twiddleROM = fi(zeros(FFT_point, 1),1,Word_length,Frac_length,F2);

% Fill in the twiddle factors for each power of w and corresponding rows
twiddleROM([0, 1, 2, 3, 4, 5, 6, 7, 8, 16, 24, 32, 40, 48, 56] + 1) = fi(exp(-1i*2*pi*(0)/FFT_point),1,Word_length,Frac_length,F2);
twiddleROM(33 + 1) = fi(exp(-1i*2*pi*1/FFT_point),1,Word_length,Frac_length,F2);
twiddleROM([17, 34] + 1) = fi(exp(-1i*2*pi*(2)/FFT_point),1,Word_length,Frac_length,F2);
twiddleROM([35, 49] + 1) = fi(exp(-1i*2*pi*(3)/FFT_point),1,Word_length,Frac_length,F2);
twiddleROM([9, 18, 36] + 1) = fi(exp(-1i*2*pi*4/FFT_point),1,Word_length,Frac_length,F2);
twiddleROM([37, 41] + 1) = fi(exp(-1i*2*pi*5/FFT_point),1,Word_length,Frac_length,F2);
twiddleROM([19, 38, 50, 25] + 1) = fi(exp(-1i*2*pi*6/FFT_point),1,Word_length,Frac_length,F2);
twiddleROM([39, 57] + 1) = fi(exp(-1i*2*pi*7/FFT_point),1,Word_length,Frac_length,F2);
twiddleROM([10, 20] + 1) = fi(exp(-1i*2*pi*8/FFT_point),1,Word_length,Frac_length,F2);
twiddleROM([51] + 1) = fi(exp(-1i*2*pi*9/FFT_point),1,Word_length,Frac_length,F2);
twiddleROM([21, 42] + 1) = fi(exp(-1i*2*pi*10/FFT_point),1,Word_length,Frac_length,F2);
twiddleROM([11, 22, 26, 52] + 1) = fi(exp(-1i*2*pi*12/FFT_point),1,Word_length,Frac_length,F2);
twiddleROM([23, 58] + 1) = fi(exp(-1i*2*pi*14/FFT_point),1,Word_length,Frac_length,F2);
twiddleROM([43, 53] + 1) = fi(exp(-1i*2*pi*15/FFT_point),1,Word_length,Frac_length,F2);


%symmetry
twiddleROM(12 + 1) =       -(1i *twiddleROM([0] + 1));   %W^(16): +16 
twiddleROM(63 + 1) =        1i *twiddleROM([33] + 1);   %W^(49): +16 +16+16
twiddleROM([27,54] + 1) =   -(1i *twiddleROM([17] + 1));   %W^(18):  +16
twiddleROM([47,61] + 1) =  -(1 *twiddleROM([35] + 1));    %W^(35):  +16 +16
twiddleROM([13,44] + 1) =  -(1i *twiddleROM([9] + 1));   %W^(20): +16
twiddleROM(30 + 1) =       -(1 *twiddleROM([9] + 1));   %W^(36): +16  +16
twiddleROM([55,59] + 1) =  -(1i *twiddleROM([37] + 1));  %W^(21): +16
twiddleROM([14,28] + 1) =  -(1i *twiddleROM([10] + 1));  %W^(24): +16
twiddleROM(45 + 1) =       -(1i *twiddleROM([51] + 1));   %W^(25): +16 
twiddleROM([31,62] + 1) =  -(1 *twiddleROM([21] + 1));    %W^(42):  +16 +16
twiddleROM([15,60] + 1) =  -(1i *twiddleROM([11] + 1));  %W^(28): +16
twiddleROM([29,46] + 1) =  -(1i *twiddleROM([23] + 1));  %W^(30): +16

%=========================================================================================%
%=========first stage=========%
for k2=1:FFT_point/1:FFT_point
    Stage1_buffered(:,ceil(k2/(FFT_point/1))) = FFT_input(k2:k2-1+FFT_point/2,1);
    Stage1_unbuffered(:,ceil(k2/(FFT_point/1))) = FFT_input(k2+FFT_point/2:k2-1+FFT_point/1,1);
    
    [Stage1_output(1:FFT_point/2,ceil(k2/(FFT_point/1))),Stage1_output(FFT_point/2+1:FFT_point/1,ceil(k2/(FFT_point/1)))] = Butterfly(Stage1_buffered(:,ceil(k2/(FFT_point/1))),Stage1_unbuffered(:,ceil(k2/(FFT_point/1))));
end

%**********************************%
Stage1_output_Mixed=Stage1_output;

Stage1_output_Mixed = reshape(Stage1_output_Mixed,FFT_point,1);

Stage1_output_Mixed( ( ( 3*FFT_point/4 ) + 1 ):FFT_point,1) = Stage1_output_Mixed(( ( 3*FFT_point/4 ) + 1 ):FFT_point,1).*(-fi_1i); 

%***********************************%

%=======second stage======%
for k2=1:FFT_point/2:FFT_point
    Stage2_buffered(:,ceil(k2/(FFT_point/2))) = Stage1_output_Mixed(k2:k2-1+FFT_point/4,1);
    Stage2_unbuffered(:,ceil(k2/(FFT_point/2))) = Stage1_output_Mixed(k2+FFT_point/4:k2-1+FFT_point/2,1);
    
    [Stage2_output(1:FFT_point/4,ceil(k2/(FFT_point/2))),Stage2_output(FFT_point/4+1:FFT_point/2,ceil(k2/(FFT_point/2)))] = Butterfly(Stage2_buffered(:,ceil(k2/(FFT_point/2))),Stage2_unbuffered(:,ceil(k2/(FFT_point/2))));
end

%**********************************%
Stage2_output_Test = Stage2_output(:);

Stage2_output_Mixed = Stage2_output_Test;

Stage2_output_Mixed = reshape(Stage2_output_Mixed,FFT_point,1);

Stage2_output_Mixed( ( ( 3*FFT_point/8 ) + 1 ):(FFT_point/2),1) = Stage2_output_Mixed( ( ( 3*FFT_point/8 ) + 1 ):(FFT_point/2),1).*(-fi_1i); 

Stage2_output_Mixed( ( ( 5 * FFT_point/8 ) + 1 ):( 3 * FFT_point/4),1) = Stage2_output_Mixed( ( ( 5 * FFT_point/8 ) + 1 ):( 3 * FFT_point/4),1).*(const - (const*fi_1i)); 

Stage2_output_Mixed( ( ( 7 * FFT_point/8 ) + 1 ):(FFT_point),1) = Stage2_output_Mixed( ( ( 7 * FFT_point/8 ) + 1 ):(FFT_point),1).*((-const) - (const*fi_1i) ); 


%=========third stage==========%
for k2=1:FFT_point/4:FFT_point

    Stage3_buffered(:,ceil(k2/(FFT_point/4))) = Stage2_output_Mixed(k2:k2-1+FFT_point/8,1);
    Stage3_unbuffered(:,ceil(k2/(FFT_point/4))) = Stage2_output_Mixed(k2+FFT_point/8:k2-1+FFT_point/4,1);
    
    [Stage3_output(1:FFT_point/8,ceil(k2/(FFT_point/4))),Stage3_output(FFT_point/8+1:FFT_point/4,ceil(k2/(FFT_point/4)))] = Butterfly(Stage3_buffered(:,ceil(k2/(FFT_point/4))),Stage3_unbuffered(:,ceil(k2/(FFT_point/4))));

end
Stage3_output = Stage3_output(:);
 
 Stage3_final_output = reshape(Stage3_output,FFT_point,1);
 Stage3_final_output = Stage3_final_output.*twiddleROM;
%===========fourth stage========%
for k2=1:FFT_point/8:FFT_point
    Stage4_buffered(:,ceil(k2/(FFT_point/8))) = Stage3_final_output(k2:k2-1+FFT_point/16,1);
    Stage4_unbuffered(:,ceil(k2/(FFT_point/8))) = Stage3_final_output(k2+FFT_point/16:k2-1+FFT_point/8,1);
    
    [Stage4_output(1:FFT_point/16,ceil(k2/(FFT_point/8))),Stage4_output(FFT_point/16+1:FFT_point/8,ceil(k2/(FFT_point/8)))] = Butterfly(Stage4_buffered(:,ceil(k2/(FFT_point/8))),Stage4_unbuffered(:,ceil(k2/(FFT_point/8))));
end
%*******************************************%
Stage4_Test = Stage4_output(:);
Stage4_output_Mixed = Stage4_output(:);
Stage4_output_Mixed = reshape(Stage4_output_Mixed,FFT_point,1);

for j = ( FFT_point/8 - 1 ) : FFT_point/8 : FFT_point
    Stage4_output_Mixed(j) = Stage4_output_Mixed(j) * (-fi_1i);
    Stage4_output_Mixed(j+1) = Stage4_output_Mixed(j+1) * (-fi_1i);
end

%============fifth stage=============%
for k2=1:FFT_point/16:FFT_point
    Stage5_buffered(:,ceil(k2/(FFT_point/16))) = Stage4_output_Mixed(k2:k2-1+FFT_point/32,1);
    Stage5_unbuffered(:,ceil(k2/(FFT_point/16))) = Stage4_output_Mixed(k2+FFT_point/32:k2-1+FFT_point/16,1);
    
    [Stage5_output(1:FFT_point/32,ceil(k2/(FFT_point/16))),Stage5_output(FFT_point/32+1:FFT_point/16,ceil(k2/(FFT_point/16)))] = Butterfly(Stage5_buffered(:,ceil(k2/(FFT_point/16))),Stage5_unbuffered(:,ceil(k2/(FFT_point/16))));
end

%*******************************************%
Stage5_output_Test = Stage5_output(:);
Stage5_output_Mixed = Stage5_output(:);
Stage5_output_Mixed = reshape(Stage5_output_Mixed,FFT_point,1);

for j = 1:FFT_point/8:FFT_point
    
    Stage5_output_Mixed(j+3) = Stage5_output_Mixed(j+3) * (-fi_1i);
    Stage5_output_Mixed(j+5) = Stage5_output_Mixed(j+5) * (const - (const*fi_1i));
    Stage5_output_Mixed(j+7) = Stage5_output_Mixed(j+7) * ((-const) - (const*fi_1i));

end
% %========sixth stage=========%
for k2=1:FFT_point/32:FFT_point
    Stage6_buffered(:,ceil(k2/(FFT_point/32))) = Stage5_output_Mixed(k2:k2-1+FFT_point/64,1);
    Stage6_unbuffered(:,ceil(k2/(FFT_point/32))) = Stage5_output_Mixed(k2+FFT_point/64:k2-1+FFT_point/32,1);
    
    [Stage6_output(1:FFT_point/64,ceil(k2/(FFT_point/32))),Stage6_output(FFT_point/64+1:FFT_point/32,ceil(k2/(FFT_point/32)))] = Butterfly(Stage6_buffered(:,ceil(k2/(FFT_point/32))),Stage6_unbuffered(:,ceil(k2/(FFT_point/32))));

end

Stage6_output = Stage6_output(:);

output_r = real(Stage6_output); %%%%%%%%%%64 NFFT
output_i = imag(Stage6_output); %%%%%%%%%%64 NFFT

end
