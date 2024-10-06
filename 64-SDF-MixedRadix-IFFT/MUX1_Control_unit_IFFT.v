module MUX1_Control_unit_IFFT #(
    parameter   NFFT = 128,
                STAGE_NO = 1
) (
    input   wire    clk, rst,
    input   wire    start_conv,
    output  reg     sel1  //sel1: used for mux selections
);                                      
localparam  IDLE    = 0,
            INACTIVE = 1,
            ACTIVE = 2,
            STAGE_NO_TWAG = $clog2(NFFT)-STAGE_NO+1;

reg [$clog2(NFFT)-STAGE_NO_TWAG:0] counter, counter_seq;     //counter used to determine the number of loops to operate the controller
reg [STAGE_NO_TWAG:0]  end_control_counter;                  //end counter to terminate the controller action
reg [STAGE_NO_TWAG:0]  end_control_counter_seq; 
reg end_control;                                        //used to indicate the end of the unit usage
reg [1:0] current_state, next_state;                    


//=================== FSM of 3 states==============//
//------------sequential part-------------//
always@(posedge clk or negedge rst) begin
    if(!rst) begin
        current_state <= 'b0;
        counter_seq <= 'b0;
        end_control_counter_seq <='b0;
    end
    else begin
        current_state <= next_state;
        counter_seq <= counter;
        end_control_counter_seq <= end_control_counter;
    end
end
//-------------combinational part------------//
always @(*) begin
    sel1         = 1'b0;
    end_control = 1'b1;
    counter     = 'b0;
    end_control_counter = 'b0;
    next_state  = IDLE;

    case (current_state)
        IDLE: begin
            sel1         = 1'b0;
            end_control = 1'b1;
            counter     = 'b0;
            end_control_counter = 'b0;

            if(start_conv) begin
                next_state = INACTIVE;
                end_control_counter = end_control_counter_seq + 1'b1;
                counter     = 'b0;
            end
            else begin
                next_state = IDLE;
                end_control_counter = end_control_counter_seq;
            end
        end
        INACTIVE: begin
            sel1         = 1'b0;
            end_control = 1'b0;
            if(counter_seq == 2**($clog2(NFFT)-STAGE_NO_TWAG)-1) begin
                if(end_control_counter_seq == 2**(STAGE_NO_TWAG-1)+1) begin
                    next_state = IDLE;
                    counter = 'b0;
                    end_control_counter = 'b0;
                end
                else begin
                    next_state  = ACTIVE;
                    sel1         = 1'b1;       //////////
                    counter = 'b0;
                    end_control_counter = end_control_counter_seq;
                end
            end
            else begin
                counter     = counter_seq + 1'b1;
                next_state  = INACTIVE;
                end_control_counter = end_control_counter_seq;
            end
        end
        ACTIVE: begin
            sel1         = 1'b1;
            end_control = 1'b0;
            
            if(counter_seq == 2**($clog2(NFFT)-STAGE_NO_TWAG)-1) begin
                counter = 'b0;
                next_state = INACTIVE;
                sel1         = 1'b0;
                end_control_counter = end_control_counter_seq + 1'b1;
            end
            else begin
                counter     = counter_seq + 1'b1;
                next_state = ACTIVE;
                end_control_counter = end_control_counter_seq;
            end

        end
        default: begin
            sel1         = 1'b0;
            end_control = 1'b1;
            counter     = 'b0;
            end_control_counter = 'b0;
            next_state  = IDLE;
        end
    endcase
end


endmodule