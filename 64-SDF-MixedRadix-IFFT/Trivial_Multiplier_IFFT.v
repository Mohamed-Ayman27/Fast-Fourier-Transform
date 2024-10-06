module Trivial_Multiplier_IFFT #(
    parameter INTEGER_SIZE = 6,
                FRACT_SIZE = 12,
                NFFT=64
) (
    input   wire            [5:0]               address,
    input   wire                                             clk, rst,
    input   wire    signed  [INTEGER_SIZE+FRACT_SIZE-1:0]    in1_r,in1_i,
    output  wire    signed  [INTEGER_SIZE+FRACT_SIZE-1:0]    out_r,out_i
);


localparam DATA_WIDTH = INTEGER_SIZE+FRACT_SIZE ;

wire signed [DATA_WIDTH-1:0]   out_r_comb, out_i_comb;

assign out_r_comb = !address ? in1_r : -in1_i;
assign out_i_comb = !address ? in1_i : in1_r;


/*
delay_unit #(.DATA_WIDTH(2*DATA_WIDTH)) D1 (.clk(clk), .reset(rst), .in_data(prod1), .out_data(prod1_seq));
delay_unit #(.DATA_WIDTH(2*DATA_WIDTH)) D2 (.clk(clk), .reset(rst), .in_data(prod2), .out_data(prod2_seq));
delay_unit #(.DATA_WIDTH(2*DATA_WIDTH)) D3 (.clk(clk), .reset(rst), .in_data(prod3), .out_data(prod3_seq));
delay_unit #(.DATA_WIDTH(2*DATA_WIDTH)) D4 (.clk(clk), .reset(rst), .in_data(prod4), .out_data(prod4_seq));
*/

delay_unit #(.DATA_WIDTH(DATA_WIDTH)) D5_r (.clk(clk), .reset(rst), .in_data(out_r_comb), .out_data(out_r));
delay_unit #(.DATA_WIDTH(DATA_WIDTH)) D5_i (.clk(clk), .reset(rst), .in_data(out_i_comb), .out_data(out_i));

endmodule
