////////////////////// Index Generation for 3rd stage - IFFT ///////////////////////////
/*
This block generates the index for twiddle factor depending on the row number in the 64 IFFT,then this index
is passed to the multiplier to multiply the twiddle factor by the value exist at this row.
*/
////////////////////////////////////////////////////////////////////////////////////////

module Address_gen_3rd_ifft #( 
    parameter   STAGE_NO = 1,
                NFFT = 64
) (
    input       wire                        clk, rst,
    input       wire                        Twiddle_active,
    output      reg [5:0]      Twiddle_address
);


///////////////////////////////////////States////////////////////////////////////////

localparam  IDLE = 0,
            ADDRESS_GEN = 1;



//////////////////////////////Internal Counters and Registers/////////////////////////
reg [5:0] counter, counter_seq;
reg current_state, next_state;




////////////////////////// State Transition////////////////////////////////////////////
always @(posedge clk or negedge rst) begin
    if(!rst) begin
        counter_seq <= 'b0;
        current_state <= IDLE;
    end
    else begin
        counter_seq <= counter;
        current_state <= next_state;
    end
end




/////////////////////// Next State and Output Logic//////////////////////////////////
        always @(*) begin
            next_state = IDLE;
            Twiddle_address = 'b0;
            counter = 'b0;
            case (current_state)
                IDLE:begin
                    Twiddle_address = 'b0;
                    counter = 'b0;
                    if(Twiddle_active == 1'b1) begin
                        next_state = ADDRESS_GEN;
                    end
                    else begin
                        next_state = IDLE;
                    end
                end

////////////////////////////////////index generation///////////////////////////////////////
                ADDRESS_GEN:begin
                               counter = counter_seq + 1'b1;


                               Twiddle_address=counter_seq[1]*counter_seq[2];

                                if(counter_seq == NFFT-1)
                                    next_state = IDLE;
                                else
                                    next_state = ADDRESS_GEN;
                             end
            endcase
        end
   
endmodule
