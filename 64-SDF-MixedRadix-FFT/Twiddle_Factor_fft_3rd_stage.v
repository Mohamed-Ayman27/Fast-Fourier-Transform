///////////////////////////////FFT 3rd stage twiddle factor ///////////////////////
/*
depending on the input address we choose the required twiddle factor from the rom 
and multiply it by -i or i , -1 depending on the quarter
*/
///////////////////////////////////////////////////////////////////////////////////


module Twiddle_Factor_fft_3rd_stage # (parameter NFFT = 64, DATA_WIDTH = 18 )
(
    input   wire            [5:0]        address,
    output  reg    signed   [DATA_WIDTH-1:0  ]        data_real, data_imag 
);


reg signed  [DATA_WIDTH-1:0]    ROM_imag    [(NFFT/4) - 1:0];
reg signed  [DATA_WIDTH-1:0]    ROM_real    [(NFFT/4) - 1:0];

integer i;


/*
initial
begin
    $readmemb("Twiddle_factor_fft_real.txt",ROM_real);
    $readmemb("Twiddle_factor_fft_imag.txt",ROM_imag);
end 
*/




//----------------Choosing & Assigning Twiddle Factors-----//
always @(*) begin
      
///////////////////////////////////Rom intialization//////////////////////////////////
    for ( i = 0 ; i < 16 ; i = i + 1 ) begin
        ROM_real [i] = 'b0;
        ROM_imag [i] = 'b0;
    end

        /*
        //18: 14-4
	    ROM_real[0]  ='b000100000000000000;
        ROM_real[1]  ='b000011111110110001;
        ROM_real[2]  ='b000011111011000101;
        ROM_real[3]  ='b000011110100111110; 
        ROM_real[4]  ='b000011101100100000; 
        ROM_real[5]  ='b000011100001110001;                     
        ROM_real[6]  ='b000011010100110110; 
        ROM_real[7]  ='b000011000101111001; 
        ROM_real[8]  ='b000010110101000001; 
        ROM_real[9]  ='b000010100010011001; 
        ROM_real[10] ='b000010001110001110; 
        ROM_real[11] ='b000001111000101011; 
        ROM_real[12] ='b000001100001111101; 
        ROM_real[13] ='b000001001010010100; 
        ROM_real[14] ='b000000110001111100; 
        ROM_real[15] ='b000000011001000101; 



        ROM_imag[0]  ='b000000000000000000;
        ROM_imag[1]  ='b111111100110111010;
        ROM_imag[2]  ='b111111001110000011;
        ROM_imag[3]  ='b111110110101101011;
        ROM_imag[4]  ='b111110011110000010; 
        ROM_imag[5]  ='b111110000111010100;               
        ROM_imag[6]  ='b111101110001110001; 
        ROM_imag[7]  ='b111101011101100110; 
        ROM_imag[8]  ='b111101001010111110; 
        ROM_imag[9]  ='b111100111010000110; 
        ROM_imag[10] ='b111100101011001001; 
        ROM_imag[11] ='b111100011110001110; 
        ROM_imag[12] ='b111100010011011111; 
        ROM_imag[13] ='b111100001011000001; 
        ROM_imag[14] ='b111100000100111010; 
        ROM_imag[15] ='b111100000001001110;
        */

///////////////////////////////////////////////////////////

        //18:13-5

        // ROM_real[0]  =	 'b000010000000000000; 
		// ROM_real[1]  =	 'b000001111111011000;
		// ROM_real[2]  =	 'b000001111101100010;    
		// ROM_real[3]  =	 'b000001111010011111;    
		// ROM_real[4]  =	 'b000001110110010000;    
		// ROM_real[5]  =	 'b000001110000111000;    
		// ROM_real[6]  =	 'b000001101010011011;    
		// ROM_real[7]  =	 'b000001100010111100;    
		// ROM_real[8]  =	 'b000001011010100000;    
		// ROM_real[9]  =	 'b000001010001001100;    
		// ROM_real[10]  =	 'b000001000111000111;    
		// ROM_real[11]  =	 'b000000111100010101;    
		// ROM_real[12]  =	 'b000000110000111110;    
		// ROM_real[13]  =	 'b000000100101001010;    
		// ROM_real[14]  =	 'b000000011000111110;    
		// ROM_real[15]  =	 'b000000001100100010;    


		// ROM_imag[0]      =  'b000000000000000000;
		// ROM_imag[1]	     =  'b111111110011011101;		
		// ROM_imag[2]	     =  'b111111100111000001; 		
		// ROM_imag[3]	     =  'b111111011010110101; 		
		// ROM_imag[4]      =  'b111111001111000001; 		
		// ROM_imag[5]      =	'b111111000011101010; 		
		// ROM_imag[6]	     =  'b111110111000111000; 		
		// ROM_imag[7]	     =  'b111110101110110011; 		
		// ROM_imag[8]	     =	'b111110100101011111; 		
		// ROM_imag[9]	     =  'b111110011101000011; 		
		// ROM_imag[10]	 =	'b111110010101100100; 		
		// ROM_imag[11]	 =	'b111110001111000111; 		
		// ROM_imag[12]	 =	'b111110001001101111; 		
		// ROM_imag[13]     =  'b111110000101100000; 		
		// ROM_imag[14]	 =	'b111110000010011101; 		
		// ROM_imag[15]	 =	'b111110000000100111; 		

		//////////////////////////////////////

        //15:10-5
		//////////////////////////////////////

		ROM_real[0]  =	 'b000010000000000; // 000010000000000
		ROM_real[1]  =	 'b000001111111011; // 000001111111011
		ROM_real[2]  =	 'b000001111101100;    
		ROM_real[3]  =	 'b000001111010011;    
		ROM_real[4]  =	 'b000001110110010;    
		ROM_real[5]  =	 'b000001110000111;    
		ROM_real[6]  =	 'b000001101010011;    
		ROM_real[7]  =	 'b000001100010111;    
		ROM_real[8]  =	 'b000001011010100;    
		ROM_real[9]  =	 'b000001010001001;    
		ROM_real[10]  =	 'b000001000111000;    
		ROM_real[11]  =	 'b000000111100010;    
		ROM_real[12]  =	 'b000000110000111;    
		ROM_real[13]  =	 'b000000100101001;    
		ROM_real[14]  =	 'b000000011000111;    
		ROM_real[15]  =	 'b000000001100100;    


		ROM_imag[0]      =  'b000000000000000;
		ROM_imag[1]	     =  'b111111110011011;	//111111110011011	
		ROM_imag[2]	     =  'b111111100111000; 		
		ROM_imag[3]	     =  'b111111011010110; 		
		ROM_imag[4]      =  'b111111001111000; 		
		ROM_imag[5]      =	'b111111000011101; 		
		ROM_imag[6]	     =  'b111110111000111; 		
		ROM_imag[7]	     =  'b111110101110110; 		
		ROM_imag[8]	     =	'b111110100101011; 		
		ROM_imag[9]	     =  'b111110011101000; 		
		ROM_imag[10]	 =	'b111110010101100; 		
		ROM_imag[11]	 =	'b111110001111000; 		
		ROM_imag[12]	 =	'b111110001001101; 		
		ROM_imag[13]     =  'b111110000101100; 		
		ROM_imag[14]	 =	'b111110000010011; 		
		ROM_imag[15]	 =	'b111110000000100; 	
		
		//////////////////////////////////////


   //Begin to chosse the correct twiddle factor according to the address
	case(address)
        'd9,'d36,'d18: begin
		data_real = ROM_real[4];
		data_imag = ROM_imag[4];
		end //
        'd10,'d20: begin
		data_real = ROM_real[8];
		data_imag = ROM_imag[8];
		end
        'd11,'d22,'d26,'d52: begin
		data_real = ROM_real[12];
		data_imag = ROM_imag[12];
		end
        'd12: begin
		data_real = ROM_imag[0];
		data_imag = -ROM_real[0]; 
	      end
        'd13,'d44: begin
		data_real = ROM_imag[4];
		data_imag = -ROM_real[4];
		end
        'd14,'d28: begin
		data_real = ROM_imag[8];
		data_imag = -ROM_real[8];
		end
        'd15,'d60: begin
		data_real = ROM_imag[12];
		data_imag = -ROM_real[12];
		end
        'd17 , 'd34 : begin
		data_real = ROM_real[2];
		data_imag = ROM_imag[2];
		end
        'd19,'d38,'d25,'d50: begin
		data_real = ROM_real[6];
		data_imag = ROM_imag[6];
		end
        'd21,'d42: begin
		data_real = ROM_real[10];
		data_imag = ROM_imag[10];
		end
        'd23,'d58: begin
		data_real = ROM_real[14];
		data_imag = ROM_imag[14];
		end
        'd27 ,'d54: begin
		data_real = ROM_imag[2];
		data_imag = -ROM_real[2];
		end
        'd29,'d46: begin
		data_real = ROM_imag[14];
		data_imag = -ROM_real[14];
		end
        'd30: begin
		data_real = -ROM_real[4];   
		data_imag = -ROM_imag[4];
		end
        'd31,'d62: begin
		data_real = -ROM_real[10];  
		data_imag = -ROM_imag[10];
		end
        'd33: begin
		data_real = ROM_real[1];
		data_imag = ROM_imag[1];
		end
        'd35,'d49: begin
		data_real = ROM_real[3];
		data_imag = ROM_imag[3];
		end
        'd37,'d41: begin
		data_real = ROM_real[5];
		data_imag = ROM_imag[5];
		end
        'd39,'d57: begin
		data_real = ROM_real[7];
		data_imag = ROM_imag[7];
		end
        'd43,'d53: begin
		data_real = ROM_real[15];
		data_imag = ROM_imag[15];
		end
        'd45: begin
		data_real = ROM_imag[9];
		data_imag = -ROM_real[9];
		end
        'd47,'d61: begin
		data_real = -ROM_real[3];  
		data_imag = -ROM_imag[3];
		end
        'd51: begin
		data_real = ROM_real[9];
		data_imag = ROM_imag[9];
		end
        'd55,'d59:begin
		data_real =  ROM_imag[5];
		data_imag = -ROM_real[5];
		end
        'd63: begin
		data_real = -ROM_imag[1];
		data_imag =  ROM_real[1];
	      end

        default: begin
		data_real = ROM_real[0];
		data_imag = ROM_imag[0];
		end
      endcase
end
endmodule
