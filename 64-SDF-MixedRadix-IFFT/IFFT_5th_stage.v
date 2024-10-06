
module IFFT_5th_stage #(
    parameter   INTEGER_SIZE = 6,
                FRACT_SIZE = 12,
                STAGE_NO = 1,
                NFFT = 64
) (
    input       wire                                             clk, rst,
    input       wire                                             start_conv,
    input       wire    signed  [INTEGER_SIZE+FRACT_SIZE-1:0]    serial_in_r, serial_in_i,
    output      wire    signed  [INTEGER_SIZE+FRACT_SIZE-1:0]    serial_out_r, serial_out_i
    //output      wire                                end_conv // can be used in future editions
);
localparam DATA_WIDTH = INTEGER_SIZE+FRACT_SIZE ;
//---------defining internal wires------//
//wire signed [DATA_WIDTH-1:0]        BUT_out2_r, BUT_out2_i;
wire signed [DATA_WIDTH-1:0]        BUF_in_r, BUF_in_i;     //buffer input
wire signed [DATA_WIDTH-1:0]        BUF_out_r, BUF_out_i;   //buffer output
wire signed [DATA_WIDTH-1:0]        BFLY_out1_r, BFLY_out1_i;   //butterfly out1
wire signed [DATA_WIDTH-1:0]        BFLY_out2_r, BFLY_out2_i;   //butterfly out2
//wire signed [DATA_WIDTH-1:0]        MUL_r_buf_in, MUL_i_buf_in;
//wire signed [DATA_WIDTH-1:0]        MUL_r_buf_out, MUL_i_buf_out;
//wire signed [DATA_WIDTH-1:0]        TF_r_buf_in, TF_i_buf_in;
wire signed [DATA_WIDTH-1:0]        TF_r_buf_out, TF_i_buf_out;
wire signed [DATA_WIDTH-1:0]        MUX1_in0_r, MUX1_in0_i;
//wire signed [DATA_WIDTH-1:0]        MUX1_in1_r, MUX1_in1_i;
wire signed [DATA_WIDTH-1:0]        MUX2_in0_r, MUX2_in0_i;
wire signed [DATA_WIDTH-1:0]        MUX2_in1_r, MUX2_in1_i;
wire signed [DATA_WIDTH-1:0]        serial_out_r_buf_in, serial_out_i_buf_in;

wire                                sel1, sel2 /*Twiddle_active*/;
wire                                start_delay;
wire        [5:0]    Twiddle_address;

Constant_Multiplier_IFFT #(.INTEGER_SIZE(INTEGER_SIZE), .FRACT_SIZE(FRACT_SIZE)) MUL1 (
    .clk(clk),
    .rst(rst),
    .address(Twiddle_address),
    .in1_r(serial_in_r),
    .in1_i(serial_in_i),
    //.in2_r(TF_r_buf_out),
    //.in2_i(TF_i_buf_out),
    .out_r(MUX1_in0_r),
    .out_i(MUX1_in0_i)
);
/*delay_unit #(.DATA_WIDTH(DATA_WIDTH)) DU_MUL_MUX2_r (
    .clk(clk),
    .reset(rst),
    .in_data(MUL_r_buf_in),
    .out_data(MUX1_in0_r)
);

delay_unit #(.DATA_WIDTH(DATA_WIDTH)) DU_MUL_MUX2_i (
    .clk(clk),
    .reset(rst),
    .in_data(MUL_i_buf_in),
    .out_data(MUX1_in0_i)
);*/

Complex_MUX2x1 #(.DATA_WIDTH(DATA_WIDTH)) MUX1 (
    .sel(sel2),
    .in0_r(MUX1_in0_r), 
    .in0_i(MUX1_in0_i),
    .in1_r(BFLY_out2_r),
    .in1_i(BFLY_out2_i),
    .out_r(BUF_in_r),
    .out_i(BUF_in_i)
    );

Memory_Shifter #(   .DATA_WIDTH(DATA_WIDTH), 
                    .MEMORY_DEPTH(2**(STAGE_NO-1))) MS1 (
    .clk(clk),
    .rst(rst),
    .data_in_r(BUF_in_r),
    .data_in_i(BUF_in_i),
    .data_out_r(BUF_out_r),
    .data_out_i(BUF_out_i)
);

/////////////////////////
/*
delay_unit #(.DATA_WIDTH(DATA_WIDTH)) DU1_MS_r (
    .clk(clk),
    .reset(rst),
    .in_data(BUF_out_r),
    .out_data(MUX2_in0_r)
);

delay_unit #(.DATA_WIDTH(DATA_WIDTH)) DU1_MS_i (
    .clk(clk),
    .reset(rst),
    .in_data(BUF_out_i),
    .out_data(MUX2_in0_i)
);
*/
////////////////////////////

Butterfly #(.DATA_WIDTH(DATA_WIDTH)) BF1 (
    //.clk(clk),
    //.rst(rst),
    .en(sel2),
    .in1_r(BUF_out_r),
    .in1_i(BUF_out_i),
    .in2_r(MUX1_in0_r),
    .in2_i(MUX1_in0_i),
    .sum_out_r(BFLY_out1_r),
    .sum_out_i(BFLY_out1_i),
    .diff_out_r(BFLY_out2_r),
    .diff_out_i(BFLY_out2_i)
);

/////////////////
/*
delay_unit #(.DATA_WIDTH(DATA_WIDTH)) DU1_BF_r (
    .clk(clk),
    .reset(rst),
    .in_data(BFLY_out1_r),
    .out_data(MUX2_in1_r)
);

delay_unit #(.DATA_WIDTH(DATA_WIDTH)) DU1_BF_i (
    .clk(clk),
    .reset(rst),
    .in_data(BFLY_out1_i),
    .out_data(MUX2_in1_i)
);


*/
///////////////////////////////////
delay_unit #(.DATA_WIDTH(1)) DU_SEL1_MUX2 (
    .clk(clk),
    .reset(rst),
    .in_data(sel1),
    .out_data(sel2)
);

Complex_MUX2x1 #(.DATA_WIDTH(DATA_WIDTH)) MUX2 (
    .sel(sel2),
    .in0_r(BUF_out_r),
    .in0_i(BUF_out_i),
    .in1_r(BFLY_out1_r),
    .in1_i(BFLY_out1_i),
    .out_r(serial_out_r_buf_in),
    .out_i(serial_out_i_buf_in)
);

delay_unit #(.DATA_WIDTH(DATA_WIDTH)) DU1_MUX2_r (
    .clk(clk),
    .reset(rst),
    .in_data(serial_out_r_buf_in),
    .out_data(serial_out_r)
);

delay_unit #(.DATA_WIDTH(DATA_WIDTH)) DU1_MUX2_i (
    .clk(clk),
    .reset(rst),
    .in_data(serial_out_i_buf_in),
    .out_data(serial_out_i)
);

delay_unit #(.DATA_WIDTH(1)) D1_start_conv (
    .clk(clk),
    .reset(rst),
    .in_data(start_conv),
    .out_data(start_delay)
); 

/*delay_unit #(.DATA_WIDTH(1)) D2_start_conv (
    .clk(clk),
    .reset(rst),
    .in_data(start_delay[0]),
    .out_data(start_delay[1])
); */

/*delay_unit #(.DATA_WIDTH(1)) D3_start_conv (
    .clk(clk),
    .reset(rst),
    .in_data(start_delay[1]),
    .out_data(start_delay[2])
); 
*/
MUX1_Control_unit_IFFT #(.NFFT(NFFT), .STAGE_NO(STAGE_NO)) CU1 (
    .clk(clk),
    .rst(rst),
    .start_conv(start_delay),
    .sel1(sel1)
);

/*MUX2_Control_unit #(.NFFT(NFFT), .STAGE_NO(STAGE_NO)) CU2 (
    .clk(clk),
    .rst(rst),
    .start_conv(start_conv),
    .sel1(sel2)
);*/

/*TF_Control_unit #(.NFFT(NFFT), .STAGE_NO(STAGE_NO)) CU3 (
    .clk(clk),
    .rst(rst),
    .start_conv(start_conv),
    //.end_conv(end_conv),
    //.sel2(sel2),
    .Twiddle_active(Twiddle_active)
);*/

Address_gen_5th_ifft #(.STAGE_NO(STAGE_NO), .NFFT(NFFT)) CU4 (
    .clk(clk),
    .rst(rst),
    .Twiddle_active(start_conv),
    .Twiddle_address(Twiddle_address)
);
/*
Twiddle_Factor_IFFT #(.NFFT(NFFT), .DATA_WIDTH(DATA_WIDTH)) TF1 (
    .address(Twiddle_address),
    //.data_real(TF_r_buf_in),
    //.data_imag(TF_i_buf_in)
    .data_real(TF_r_buf_out),
    .data_imag(TF_i_buf_out)
);
*/


endmodule
