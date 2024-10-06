////////////////////// Constant multiplier ///////////////////////////
/*
This block is called a trivial multiplier because it just swaps the real and the imaginary parts
or switches thei signs.Not an actual Multiplier.
This happens when multiplying b -j
*/
////////////////////////////////////////////////////////////////////////////////////////


module Trivial_multiplier_fft #( parameter INTEGER_SIZE = 6,FRACT_SIZE = 12, NFFT=64 )
(
    input   wire            [5:0]               address,
    input   wire                                             clk, rst,
    input   wire    signed  [INTEGER_SIZE+FRACT_SIZE-1:0]    in1_r,in1_i,
    output  wire    signed  [INTEGER_SIZE+FRACT_SIZE-1:0]    out_r,out_i
);

localparam DATA_WIDTH = INTEGER_SIZE+FRACT_SIZE ;

wire signed [DATA_WIDTH-1:0]   out_r_comb, out_i_comb;

assign out_r_comb = !address ? in1_r : in1_i;
assign out_i_comb = !address ? in1_i : -in1_r;


delay_unit #(.DATA_WIDTH(DATA_WIDTH)) D5_r (.clk(clk), .reset(rst), .in_data(out_r_comb), .out_data(out_r));
delay_unit #(.DATA_WIDTH(DATA_WIDTH)) D5_i (.clk(clk), .reset(rst), .in_data(out_i_comb), .out_data(out_i));

endmodule
