function [output_r,output_i] = SDF_IFFT_Mixed(input_r,input_i)

nt = numerictype(input_r);
Word_length = nt.WordLength;
Int_length = nt.WordLength - nt.FractionLength;
Frac_length = nt.FractionLength;
F1 = fimath('SumMode', 'SpecifyPrecision', 'SumWordLength',...
    2*Word_length,'SumFractionLength', 2*Frac_length, 'ProductMode',...
   'SpecifyPrecision', 'ProductWordLength', 2*Word_length,'ProductFractionLength',...
   2*Frac_length,'OverflowAction',"Wrap",'RoundingMethod',"Floor");

F2 = fimath('SumMode', 'SpecifyPrecision', 'SumWordLength',...
    Word_length,'SumFractionLength', Frac_length+4, 'ProductMode',...
   'SpecifyPrecision', 'ProductWordLength', Word_length,'ProductFractionLength',...
   Frac_length+4,'OverflowAction',"Wrap",'RoundingMethod',"Floor");


FFT_point = 64; %%%%%%%%%%64 NFFT
IFFT_input = input_r+1i*input_i;

IFFT_input = fi(IFFT_input,1,Word_length*2,Frac_length*2,F1);
IFFT_input = 1/FFT_point.*IFFT_input;
IFFT_input = fi(IFFT_input,1,Word_length,Frac_length+4,F2);

%=======================================================================================%


twiddleROM = zeros(FFT_point, 1);

% Fill in the twiddle factors for each power of w and corresponding rows
twiddleROM([0, 1, 2, 3, 4, 5, 6, 7, 8, 16, 24, 32, 40, 48, 56] + 1) = fi(exp(1i*2*pi*(0)/FFT_point),1,Word_length,Frac_length+4,F2);
twiddleROM(33 + 1) = fi(exp(1i*2*pi*1/FFT_point),1,Word_length,Frac_length+4,F2);
twiddleROM([17, 34] + 1) = fi(exp(1i*2*pi*(2)/FFT_point),1,Word_length,Frac_length+4,F2);
twiddleROM([35, 49] + 1) = fi(exp(1i*2*pi*(3)/FFT_point),1,Word_length,Frac_length+4,F2);
twiddleROM([9, 18, 36] + 1) = fi(exp(1i*2*pi*4/FFT_point),1,Word_length,Frac_length+4,F2);
twiddleROM([37, 41] + 1) = fi(exp(1i*2*pi*5/FFT_point),1,Word_length,Frac_length+4,F2);
twiddleROM([19, 38, 50, 25] + 1) = fi(exp(1i*2*pi*6/FFT_point),1,Word_length,Frac_length+4,F2);
twiddleROM([39, 57] + 1) = fi(exp(1i*2*pi*7/FFT_point),1,Word_length,Frac_length+4,F2);
twiddleROM([10, 20] + 1) = fi(exp(1i*2*pi*8/FFT_point),1,Word_length,Frac_length+4,F2);
twiddleROM([51] + 1) = fi(exp(1i*2*pi*9/FFT_point),1,Word_length,Frac_length+4,F2);
twiddleROM([21, 42] + 1) = fi(exp(1i*2*pi*10/FFT_point),1,Word_length,Frac_length+4,F2);
twiddleROM([11, 22, 26, 52] + 1) = fi(exp(1i*2*pi*12/FFT_point),1,Word_length,Frac_length+4,F2);
twiddleROM([23, 58] + 1) = fi(exp(1i*2*pi*14/FFT_point),1,Word_length,Frac_length+4,F2);
twiddleROM([43, 53] + 1) = fi(exp(1i*2*pi*15/FFT_point),1,Word_length,Frac_length+4,F2);


%symmetry
twiddleROM(12 + 1) =       (1i *twiddleROM([0] + 1));   %W^(16): +16 
twiddleROM(63 + 1) =        -(1i *twiddleROM([33] + 1));   %W^(49): +16 +16+16
twiddleROM([27,54] + 1) =   (1i *twiddleROM([17] + 1));   %W^(18):  +16
twiddleROM([47,61] + 1) =  -(1 *twiddleROM([35] + 1));    %W^(35):  +16 +16
twiddleROM([13,44] + 1) =  (1i *twiddleROM([9] + 1));   %W^(20): +16
twiddleROM(30 + 1) =       -(1 *twiddleROM([9] + 1));   %W^(36): +16  +16
twiddleROM([55,59] + 1) =  (1i *twiddleROM([37] + 1));  %W^(21): +16
twiddleROM([14,28] + 1) =  (1i *twiddleROM([10] + 1));  %W^(24): +16
twiddleROM(45 + 1) =       (1i *twiddleROM([51] + 1));   %W^(25): +16 
twiddleROM([31,62] + 1) =  -(1 *twiddleROM([21] + 1));    %W^(42):  +16 +16
twiddleROM([15,60] + 1) =  (1i *twiddleROM([11] + 1));  %W^(28): +16
twiddleROM([29,46] + 1) =  (1i *twiddleROM([23] + 1));  %W^(30): +16


%=======================================================================================%



const = fi(0.70710678,1,Word_length,Frac_length+4,F2);
fi_1i = fi(1i,1,Word_length,Frac_length+4,F2);

for k2=1:FFT_point/32:FFT_point
    Stage2_buffered(:,ceil(k2/(FFT_point/32))) = IFFT_input(k2:k2-1+FFT_point/64,1); %64
    Stage2_unbuffered(:,ceil(k2/(FFT_point/32))) = IFFT_input(k2+FFT_point/64:k2-1+FFT_point/32,1); %64

    
    [Stage2_output(1:FFT_point/64,ceil(k2/(FFT_point/32))),Stage2_output(FFT_point/64+1:FFT_point/32,ceil(k2/(FFT_point/32)))] = Butterfly(Stage2_buffered(:,ceil(k2/(FFT_point/32))),Stage2_unbuffered(:,ceil(k2/(FFT_point/32))));
end
%=========stage 3==========%
Stage2_final_output = reshape(Stage2_output,FFT_point,1);
Stage2_output_Mixed = Stage2_final_output;

%*******************************************%
for j = 1:FFT_point/8:FFT_point
    
    Stage2_output_Mixed(j+3) = Stage2_output_Mixed(j+3) * (fi_1i);
    Stage2_output_Mixed(j+5) = Stage2_output_Mixed(j+5) * (const + (const*fi_1i));
    Stage2_output_Mixed(j+7) = Stage2_output_Mixed(j+7) * ((-const) + (const*fi_1i));

end
%*******************************************%

for k2=1:FFT_point/16:FFT_point
    Stage3_buffered(:,ceil(k2/(FFT_point/16))) = Stage2_output_Mixed(k2:k2-1+FFT_point/32,1);
    Stage3_unbuffered(:,ceil(k2/(FFT_point/16))) = Stage2_output_Mixed(k2+FFT_point/32:k2-1+FFT_point/16,1);
    
    [Stage3_output(1:FFT_point/32,ceil(k2/(FFT_point/16))),Stage3_output(FFT_point/32+1:FFT_point/16,ceil(k2/(FFT_point/16)))] = Butterfly(Stage3_buffered(:,ceil(k2/(FFT_point/16))),Stage3_unbuffered(:,ceil(k2/(FFT_point/16))));
end

Stage3_final_output = reshape(Stage3_output,FFT_point,1);

%========stage 4============%
%*******************************************%
Stage3_output_Mixed = Stage3_final_output;

for j = ( FFT_point/8 - 1 ) : FFT_point/8 : FFT_point
    Stage3_output_Mixed(j) = Stage3_output_Mixed(j) * (fi_1i);
    Stage3_output_Mixed(j+1) = Stage3_output_Mixed(j+1) * (fi_1i);
end
%*******************************************%

for k2=1:FFT_point/8:FFT_point
    Stage4_buffered(:,ceil(k2/(FFT_point/8))) = Stage3_output_Mixed(k2:k2-1+FFT_point/16,1);
    Stage4_unbuffered(:,ceil(k2/(FFT_point/8))) = Stage3_output_Mixed(k2+FFT_point/16:k2-1+FFT_point/8,1);
    
    [Stage4_output(1:FFT_point/16,ceil(k2/(FFT_point/8))),Stage4_output(FFT_point/16+1:FFT_point/8,ceil(k2/(FFT_point/8)))] = Butterfly(Stage4_buffered(:,ceil(k2/(FFT_point/8))),Stage4_unbuffered(:,ceil(k2/(FFT_point/8))));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Stage4_final_output = reshape(Stage4_output,FFT_point,1);
%==========stage 5============%
Stage4_final_output = Stage4_final_output.*twiddleROM;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k2=1:FFT_point/4:FFT_point
    Stage5_buffered(:,ceil(k2/(FFT_point/4))) = Stage4_final_output(k2:k2-1+FFT_point/8,1);
    Stage5_unbuffered(:,ceil(k2/(FFT_point/4))) = Stage4_final_output(k2+FFT_point/8:k2-1+FFT_point/4,1);
    
    [Stage5_output(1:FFT_point/8,ceil(k2/(FFT_point/4))),Stage5_output(FFT_point/8+1:FFT_point/4,ceil(k2/(FFT_point/4)))] = Butterfly(Stage5_buffered(:,ceil(k2/(FFT_point/4))),Stage5_unbuffered(:,ceil(k2/(FFT_point/4))));
end

Stage5_final_output = reshape(Stage5_output,FFT_point,1);
%========stage 6========%
%**********************************%
Stage5_output_Mixed = Stage5_final_output;

Stage5_output_Mixed = reshape(Stage5_output_Mixed,FFT_point,1);

Stage5_output_Mixed( ( ( 3*FFT_point/8 ) + 1 ):(FFT_point/2),1) = Stage5_output_Mixed( ( ( 3*FFT_point/8 ) + 1 ):(FFT_point/2),1).*(fi_1i); 

Stage5_output_Mixed( ( ( 5 * FFT_point/8 ) + 1 ):( 3 * FFT_point/4),1) = Stage5_output_Mixed( ( ( 5 * FFT_point/8 ) + 1 ):( 3 * FFT_point/4),1).*( (const + (const*fi_1i)) ); 

Stage5_output_Mixed( ( ( 7 * FFT_point/8 ) + 1 ):(FFT_point),1) = Stage5_output_Mixed( ( ( 7 * FFT_point/8 ) + 1 ):(FFT_point),1).*((-const) + (const*fi_1i)); 

%***********************************%

for k2=1:FFT_point/2:FFT_point
    Stage6_buffered(:,ceil(k2/(FFT_point/2))) = Stage5_output_Mixed(k2:k2-1+FFT_point/4,1);
    Stage6_unbuffered(:,ceil(k2/(FFT_point/2))) = Stage5_output_Mixed(k2+FFT_point/4:k2-1+FFT_point/2,1);
    
    [Stage6_output(1:FFT_point/4,ceil(k2/(FFT_point/2))),Stage6_output(FFT_point/4+1:FFT_point/2,ceil(k2/(FFT_point/2)))] = Butterfly(Stage6_buffered(:,ceil(k2/(FFT_point/2))),Stage6_unbuffered(:,ceil(k2/(FFT_point/2))));
end

Stage6_final_output = reshape(Stage6_output,FFT_point,1);
%==========stage 7 =======%
Stage6_output_Mixed=Stage6_final_output;

Stage6_output_Mixed( ( ( 3*FFT_point/4 ) + 1 ):FFT_point,1) = Stage6_output_Mixed(( ( 3*FFT_point/4 ) + 1 ):FFT_point,1).*(fi_1i); 

%Stage6_final_output = Stage6_final_output.*Stage7_Twiddle_factor;

for k2=1:FFT_point/1:FFT_point
    Stage7_buffered(:,ceil(k2/(FFT_point/1))) = Stage6_output_Mixed(k2:k2-1+FFT_point/2,1);
    Stage7_unbuffered(:,ceil(k2/(FFT_point/1))) = Stage6_output_Mixed(k2+FFT_point/2:k2-1+FFT_point/1,1);
    
    [Stage7_output(1:FFT_point/2,ceil(k2/(FFT_point/1))),Stage7_output(FFT_point/2+1:FFT_point/1,ceil(k2/(FFT_point/1)))] = Butterfly(Stage7_buffered(:,ceil(k2/(FFT_point/1))),Stage7_unbuffered(:,ceil(k2/(FFT_point/1))));
end

Stage7_final_output = reshape(Stage7_output,FFT_point,1);

output_r = real(Stage7_final_output);
output_i = imag(Stage7_final_output);
end

