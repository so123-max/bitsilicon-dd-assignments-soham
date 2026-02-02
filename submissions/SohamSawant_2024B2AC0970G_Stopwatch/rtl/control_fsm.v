module process_manager (
    input  wire i_clock,
    input  wire i_async_rst_n,
    input  wire i_soft_reset,
    input  wire i_trigger_run,
    input  wire i_trigger_halt,
    output reg  o_enable_sig,
    output reg  [1:0] r_current_state
);

localparam S_READY     = 2'b00;
localparam S_OPERATING = 2'b01;
localparam S_SUSPENDED = 2'b10;

always @(posedge i_clock) begin
    if (!i_async_rst_n) begin
        r_current_state <= S_READY;
    end else if (i_soft_reset) begin
        r_current_state <= S_READY;
    end else begin
        case (r_current_state)
            S_READY: begin
                if (i_trigger_run)
                    r_current_state <= S_OPERATING;
            end

            S_OPERATING: begin
                if (i_trigger_halt)
                    r_current_state <= S_SUSPENDED;
            end

            S_SUSPENDED: begin
                if (i_trigger_run)
                    r_current_state <= S_OPERATING;
            end

            default: r_current_state <= S_READY;
        endcase
    end
end

always @(*) begin
    if (r_current_state == S_OPERATING)
        o_enable_sig = 1'b1;
    else
        o_enable_sig = 1'b0;
end

endmodule
