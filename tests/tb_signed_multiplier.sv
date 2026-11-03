`timescale 1ns/1ps
module tb_signed_multiplier;
    logic clk = 1'b0;
    logic rst = 1'b1;
    logic start = 1'b0;
    logic signed [15:0] a = '0;
    logic signed [15:0] b = '0;
    logic signed [31:0] product;
    logic done;
    integer tests = 0;

    signed_multiplier dut (
        .clk(clk), .rst(rst), .start(start), .a(a), .b(b),
        .product(product), .done(done)
    );

    always #5 clk = ~clk;

    task automatic check_multiply(
        input logic signed [15:0] test_a,
        input logic signed [15:0] test_b,
        input logic signed [31:0] expected
    );
        @(negedge clk);
        a = test_a;
        b = test_b;
        start = 1'b1;

        @(posedge clk);
        #1; // Allow nonblocking assignments to settle.
        if (done !== 1'b1 || product !== expected) begin
            $display("FAIL: %0d * %0d -> got %0d (done=%b), expected %0d",
                     test_a, test_b, product, done, expected);
            $fatal(1);
        end
        tests = tests + 1;
        $display("PASS: %0d * %0d = %0d", test_a, test_b, product);

        @(negedge clk);
        start = 1'b0;
        @(posedge clk);
        #1;
        if (done !== 1'b0) begin
            $display("FAIL: done should clear when start is low");
            $fatal(1);
        end
    endtask

    initial begin
        repeat (2) @(posedge clk);
        @(negedge clk);
        rst = 1'b0;

        check_multiply(12,      7,            84);
        check_multiply(-12,     7,           -84);
        check_multiply(0,     -271,            0);
        check_multiply(300,   -400,      -120000);
        check_multiply(32767, 32767,   1073676289);
        check_multiply(-32768,-32768,  1073741824);
        check_multiply(-32768, 32767, -1073709056);

        $display("ALL PASS: %0d signed multiplication cases", tests);
        $finish;
    end
endmodule
