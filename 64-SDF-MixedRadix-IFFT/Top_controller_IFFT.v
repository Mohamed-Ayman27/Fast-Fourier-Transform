// this module can delay its output for 1 clock cycle if needed
module Top_controller_IFFT #(
    parameter   NFFT = 128
    //,BITS_NEEDED_FOR_STAGE_NO = 3  //EX: 7 stages need 3 bits, 3 stages need 2 bits
) (
    input   wire    clk, rst,
    input   wire    start_FFT,
    output  reg  [$clog2(NFFT)-1:0] start_stage,
    /*output  reg     start_stage1, start_stage2, start_stage3, 
                    start_stage4, start_stage5, start_stage6,
                    start_stage7, */
    output  reg     end_FFT, data_valid
);
localparam  IDLE = 0,
            STAGE_OPERATION = 1,
            DATA_VALID = 3;
/*    localparam  IDLE = 0,
                STAGE1_OPERATION = 1,
                STAGE2_OPERATION = 2,
                STAGE3_OPERATION = 3,
                STAGE4_OPERATION = 4,
                STAGE5_OPERATION = 5,
                STAGE6_OPERATION = 6,
                STAGE7_OPERATION = 7;*/

reg [$clog2(NFFT)-1:0] counter1, counter1_seq;  //to count the number of cycles needed for each stage
reg [$clog2(NFFT)-1:0] counter_limit, counter_limit_seq; //to put limit for number of cycles needed for each stage
reg [$clog2(NFFT)-1:0] start_stage_seq;
reg [1:0] current_state, next_state;

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        counter1_seq <= 'b0;
        counter_limit_seq <= 'b0;
        current_state <= 2'b0;
        start_stage_seq <= 'b0;
        
    end
    else begin
        counter1_seq <= counter1;
        counter_limit_seq <= counter_limit;
        current_state <= next_state;
        start_stage_seq <= start_stage;
    end
end

always @(*) begin
    counter1 = 'b0;
    counter_limit = 'b0;
    next_state = IDLE;
    start_stage = 'b0;
    end_FFT = 1'b0;
    data_valid = 1'b0;

    case (current_state)
    //---------------IDLE state---------------//
    IDLE: begin
            if(start_FFT) begin
                next_state = STAGE_OPERATION;
                start_stage = 'b1;
                counter1 = 'b0;
                counter_limit = 'b1; /////////////////
            end
            else begin
                next_state = IDLE;
                start_stage = 'b0;
                counter1 = 'b0;
                counter_limit = 'b0;
            end
        end 
    //-----------start operation state---------//
        STAGE_OPERATION: begin
            counter_limit = counter_limit_seq;
            start_stage = start_stage_seq;
            if(counter1_seq == counter_limit_seq+1) begin
                if(start_stage[$clog2(NFFT)-1] == 1) begin //indicates finishing the last stage
                    //next_state = IDLE;
                    next_state = DATA_VALID;
                    start_stage = 'b0;
                    counter1 = 'b0;
                    counter_limit = NFFT-1;
                    end_FFT = 1'b1;
                    data_valid = 1'b1;
                end
                else begin //indicates starting intermidia
                    next_state = STAGE_OPERATION;
                    start_stage = start_stage_seq<<1;
                    counter1 = 'b0;
                    counter_limit = counter_limit_seq<<1;
                    end_FFT = 1'b0;
                end
            end
            else begin
                next_state = STAGE_OPERATION;
                counter1 = counter1_seq + 1'b1;
            end
        end
    //-------------data valid enable-----------//
        DATA_VALID: begin
            counter_limit = counter_limit_seq;
            data_valid = 1'b1;
            if(counter1_seq == counter_limit_seq) begin //the output finished streaming the reuslts
                next_state = IDLE;
                counter1 = 'b0;
                data_valid = 1'b0;
            end
            else begin // the output is still processing
                next_state = DATA_VALID;
                counter1 = counter1_seq +1'b1;
            end
        end    
    endcase
end

/*always @(*) begin
    counter1 = 'b0;
    //counter2 = 'b0;
    next_state = IDLE;
    start_stage1 = 1'b0; start_stage2 = 1'b0; start_stage3 = 1'b0; 
    start_stage4 = 1'b0; 
    start_stage5 = 1'b0; 
    start_stage6 = 1'b0; start_stage7 = 1'b0;
    end_FFT = 1'b0;
    case (current_state)

        IDLE: begin
            if(start_FFT) begin
                next_state = STAGE1_OPERATION;
                start_stage1 = 1'b1;
                counter1 = 'b0;
            end
            else begin
                next_state = IDLE;
                start_stage1 = 1'b0;
            end
        end 

        STAGE1_OPERATION: begin
            if(counter1_seq == NFFT/128+3) begin
                next_state = STAGE2_OPERATION;
                start_stage2 = 1'b1;
                counter1 = 'b0;
            end
            else begin
                next_state = STAGE1_OPERATION;
                counter1 = counter1_seq + 1'b1;
            end
        end

        STAGE2_OPERATION: begin
            if(counter1_seq == NFFT/64+3) begin
                next_state = STAGE3_OPERATION;
                start_stage3 = 1'b1;
                counter1 = 'b0;
            end
            else begin
                next_state = STAGE2_OPERATION;
                counter1 = counter1_seq + 1'b1;
            end
        end

        STAGE3_OPERATION: begin
            if(counter1_seq == NFFT/32+3) begin
                next_state = STAGE4_OPERATION;
                start_stage4 = 1'b1;
                counter1 = 'b0;
            end
            else begin
                next_state = STAGE3_OPERATION;
                counter1 = counter1_seq + 1'b1;
            end
        end

        STAGE4_OPERATION: begin
            if(counter1_seq == NFFT/16+3) begin
                next_state = STAGE5_OPERATION;
                start_stage5 = 1'b1;
                counter1 = 'b0;
            end
            else begin
                next_state = STAGE4_OPERATION;
                counter1 = counter1_seq + 1'b1;
            end
        end

        STAGE5_OPERATION: begin
            if(counter1_seq == NFFT/8+3) begin
                next_state = STAGE6_OPERATION;
                start_stage6 = 1'b1;
                counter1 = 'b0;
            end
            else begin
                next_state = STAGE5_OPERATION;
                counter1 = counter1_seq + 1'b1;
            end
        end

        STAGE6_OPERATION: begin
            if(counter1_seq == NFFT/4+3) begin
                next_state = STAGE7_OPERATION;
                start_stage7 = 1'b1;
                counter1 = 'b0;
            end
            else begin
                next_state = STAGE6_OPERATION;
                counter1 = counter1_seq + 1'b1;
            end
        end

        STAGE7_OPERATION: begin
            if(counter1_seq == NFFT/2+3) begin
                next_state = IDLE;
                end_FFT = 1'b1;
                counter1 = 'b0;
            end
            else begin
                next_state = STAGE7_OPERATION;
                counter1 = counter1_seq + 1'b1;
            end
        end
    endcase
end*/
endmodule