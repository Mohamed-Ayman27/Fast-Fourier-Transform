module Top_IFFT #(
    parameter   INTEGER_SIZE = 4,
                FRACT_SIZE = 14,
                NFFT = 64,
                SCALE_SIZE = 4///////////////////////
) (
    input       wire                                             clk, rst,
    input       wire                                             start_FFT,
    input       wire    signed  [INTEGER_SIZE+FRACT_SIZE-1:0]    serial_in_r, serial_in_i,
    output      wire    signed  [INTEGER_SIZE+FRACT_SIZE-1:0]    serial_out_r, serial_out_i,
    output      wire                                             end_FFT, data_valid_IFFT
);
localparam DATA_WIDTH = INTEGER_SIZE+FRACT_SIZE ;

wire    [$clog2(NFFT)-1:0]      start_stages;
wire    [DATA_WIDTH-1:0]        stage_n_in_r      [0:$clog2(NFFT)-1];
wire    [DATA_WIDTH-1:0]        stage_n_in_i      [0:$clog2(NFFT)-1];
wire    signed  [DATA_WIDTH-1:0]        stage1_in_r, stage1_in_i;
wire    signed  [DATA_WIDTH-1:0]        stage2_in_r, stage2_in_i;
wire    signed  [DATA_WIDTH-1:0]        stage3_in_r, stage3_in_i;
wire    signed  [DATA_WIDTH-1:0]        stage4_in_r, stage4_in_i;
wire    signed  [DATA_WIDTH-1:0]        stage5_in_r, stage5_in_i;
wire    signed  [DATA_WIDTH-1:0]        stage6_in_r, stage6_in_i;
wire    signed  [DATA_WIDTH-1:0]        stage7_in_r, stage7_in_i;
//wire    signed  [DATA_WIDTH-1:0]        stage7_out_r, stage7_out_i;
wire    signed  [DATA_WIDTH-1:0]        shift_out_r, shift_out_i;
wire                                    start_FFT_delayed;

wire [$clog2(NFFT ):0] result_shifted;
assign result_shifted = $clog2(NFFT )- SCALE_SIZE;

//genvar i;

//to divide the final result by 1/NFFT
Complex_shift_right #(.DATA_WIDTH(DATA_WIDTH), .NFFT(NFFT)) SHIFT_RIGHT (
    .data_in_r(serial_in_r),
    .data_in_i(serial_in_i),
    .shift_mag((result_shifted)),
    .data_out_r(shift_out_r),
    .data_out_i(shift_out_i)
);

delay_unit #(.DATA_WIDTH(DATA_WIDTH)) D1_SHIFT_r (
    .clk(clk),
    .reset(rst),
    .in_data(shift_out_r),
    .out_data(stage1_in_r)
);

delay_unit #(.DATA_WIDTH(DATA_WIDTH)) D1_SHIFT_i (
    .clk(clk),
    .reset(rst),
    .in_data(shift_out_i),
    .out_data(stage1_in_i)
);

delay_unit #(.DATA_WIDTH(1)) D1_SHIFT_start (
    .clk(clk),
    .reset(rst),
    .in_data(start_FFT),
    .out_data(start_FFT_delayed)
);
/*
generate
    for (i = 0;i< $clog2(NFFT);i=i+1 ) begin
        if (i==$clog2(NFFT)-1) begin //for the last stage
            SDF_Stage_IFFT #(
            .INTEGER_SIZE       (INTEGER_SIZE       ), 
            .FRACT_SIZE         (FRACT_SIZE         ), 
            .STAGE_NO           (i+1                ), 
            .NFFT               (NFFT               )
            ) ST2 (
            .clk                (clk                ),
            .rst                (rst                ),
            .start_conv         (start_stages[i]    ),
            .serial_in_r        (stage_n_in_r[i]    ),
            .serial_in_i        (stage_n_in_i[i]    ),
            .serial_out_r       (serial_out_r       ),
            .serial_out_i       (serial_out_i       )
            );
        end
        else begin //for the rest of the stages
            SDF_Stage_IFFT #(
                .INTEGER_SIZE       (INTEGER_SIZE       ), 
                .FRACT_SIZE         (FRACT_SIZE         ), 
                .STAGE_NO           (i+1                ), 
                .NFFT               (NFFT               )
                ) ST1 (
                .clk                (clk                ),
                .rst                (rst                ),
                .start_conv         (start_stages[i]    ),
                .serial_in_r        (stage_n_in_r[i]    ),
                .serial_in_i        (stage_n_in_i[i]    ),
                .serial_out_r       (stage_n_in_r[i+1]  ),
                .serial_out_i       (stage_n_in_i[i+1]  )
                ); 
        end
    end
endgenerate
*/

IFFT_1st_stage #(.INTEGER_SIZE(INTEGER_SIZE), .FRACT_SIZE(FRACT_SIZE), .STAGE_NO(1), .NFFT(NFFT)) ST1 (
    .clk(clk),
    .rst(rst),
    .start_conv(start_stages[0]),
    .serial_in_r(stage1_in_r),
    .serial_in_i(stage1_in_i),
    .serial_out_r(stage2_in_r),
    .serial_out_i(stage2_in_i)
);

IFFT_2nd_stage #(.INTEGER_SIZE(INTEGER_SIZE), .FRACT_SIZE(FRACT_SIZE), .STAGE_NO(2), .NFFT(NFFT)) ST2 (
    .clk(clk),
    .rst(rst),
    .start_conv(start_stages[1]),
    .serial_in_r(stage2_in_r),
    .serial_in_i(stage2_in_i),
    .serial_out_r(stage3_in_r),
    .serial_out_i(stage3_in_i)
);

IFFT_3rd_stage #(.INTEGER_SIZE(INTEGER_SIZE), .FRACT_SIZE(FRACT_SIZE), .STAGE_NO(3), .NFFT(NFFT)) ST3 (
    .clk(clk),
    .rst(rst),
    .start_conv(start_stages[2]),
    .serial_in_r(stage3_in_r),
    .serial_in_i(stage3_in_i),
    .serial_out_r(stage4_in_r),
    .serial_out_i(stage4_in_i)
);

IFFT_4th_stage #(.INTEGER_SIZE(INTEGER_SIZE), .FRACT_SIZE(FRACT_SIZE), .STAGE_NO(4), .NFFT(NFFT)) ST4 (
    .clk(clk),
    .rst(rst),
    .start_conv(start_stages[3]),
    .serial_in_r(stage4_in_r),
    .serial_in_i(stage4_in_i),
    .serial_out_r(stage5_in_r),
    .serial_out_i(stage5_in_i)
);

IFFT_5th_stage #(.INTEGER_SIZE(INTEGER_SIZE), .FRACT_SIZE(FRACT_SIZE), .STAGE_NO(5), .NFFT(NFFT)) ST5 (
    .clk(clk),
    .rst(rst),
    .start_conv(start_stages[4]),
    .serial_in_r(stage5_in_r),
    .serial_in_i(stage5_in_i),
    .serial_out_r(stage6_in_r),
    .serial_out_i(stage6_in_i)
);

IFFT_6th_stage #(.INTEGER_SIZE(INTEGER_SIZE), .FRACT_SIZE(FRACT_SIZE), .STAGE_NO(6), .NFFT(NFFT)) ST6 (
    .clk(clk),
    .rst(rst),
    .start_conv(start_stages[5]),
    .serial_in_r(stage6_in_r),
    .serial_in_i(stage6_in_i),
    .serial_out_r(serial_out_r),
    .serial_out_i(serial_out_i)
);
/*
SDF_Stage_IFFT #(.INTEGER_SIZE(INTEGER_SIZE), .FRACT_SIZE(FRACT_SIZE), .STAGE_NO(7), .NFFT(NFFT)) ST7 ( //change the stage number here
    .clk(clk),
    .rst(rst),
    .start_conv(start_stages[6]),
    .serial_in_r(stage7_in_r),
    .serial_in_i(stage7_in_i),
    .serial_out_r(serial_out_r),
    .serial_out_i(serial_out_i)
);*/


Top_controller_IFFT #(.NFFT(NFFT)) TOP_CONT1 (
    .clk(clk),
    .rst(rst),
    .start_FFT(start_FFT_delayed),
    .start_stage(start_stages), //-------commented for 16-fft tessting------//
    .end_FFT(end_FFT),
    .data_valid(data_valid_IFFT)
);
endmodule