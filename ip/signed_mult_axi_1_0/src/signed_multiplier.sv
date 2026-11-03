// 16-bit signed, registered multiplication core.
// This is a standalone RTL datapath, not an AXI4-Lite peripheral yet.
module signed_multiplier (
    input  logic               clk,
    input  logic               rst,
    input  logic               start,
    input  logic signed [15:0] a,
    input  logic signed [15:0] b,
    output logic signed [31:0] product,
    output logic               done
);
    always_ff @(posedge clk) begin
        if (rst) begin
            product <= '0;
            done    <= 1'b0;
        end else begin
            // done is a one-clock pulse for each clock where start was high.
            done <= start;
            if (start)
                product <= a * b;
        end
    end
endmodule
