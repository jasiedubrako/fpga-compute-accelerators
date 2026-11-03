`timescale 1ns / 1ps

// SystemVerilog self-checking AXI4-Lite testbench for Vivado 2023.1.
// The BFM drives AW and W channels together, matching the vendor wizard's
// simple single-outstanding-write AXI4-Lite template.
module tb_signed_mult_axi;
    reg clk = 1'b0;
    always #5 clk = ~clk;

    reg resetn = 1'b0;

    reg  [4:0]  awaddr  = 0;
    reg  [2:0]  awprot  = 0;
    reg         awvalid = 0;
    wire        awready;
    reg  [31:0] wdata   = 0;
    reg  [3:0]  wstrb   = 0;
    reg         wvalid  = 0;
    wire        wready;
    wire [1:0]  bresp;
    wire        bvalid;
    reg         bready  = 0;

    reg  [4:0]  araddr  = 0;
    reg  [2:0]  arprot  = 0;
    reg         arvalid = 0;
    wire        arready;
    wire [31:0] rdata;
    wire [1:0]  rresp;
    wire        rvalid;
    reg         rready  = 0;

    localparam [4:0] REG_A       = 5'h00;
    localparam [4:0] REG_B       = 5'h04;
    localparam [4:0] REG_CONTROL = 5'h08;
    localparam [4:0] REG_STATUS  = 5'h0C;
    localparam [4:0] REG_RESULT  = 5'h10;

    signed_mult_axi_v1_0 dut (
        .s00_axi_aclk(clk), .s00_axi_aresetn(resetn),
        .s00_axi_awaddr(awaddr), .s00_axi_awprot(awprot),
        .s00_axi_awvalid(awvalid), .s00_axi_awready(awready),
        .s00_axi_wdata(wdata), .s00_axi_wstrb(wstrb),
        .s00_axi_wvalid(wvalid), .s00_axi_wready(wready),
        .s00_axi_bresp(bresp), .s00_axi_bvalid(bvalid),
        .s00_axi_bready(bready),
        .s00_axi_araddr(araddr), .s00_axi_arprot(arprot),
        .s00_axi_arvalid(arvalid), .s00_axi_arready(arready),
        .s00_axi_rdata(rdata), .s00_axi_rresp(rresp),
        .s00_axi_rvalid(rvalid), .s00_axi_rready(rready)
    );

    task automatic axi_write(input [4:0] addr,
                             input [31:0] value,
                             input [3:0] strobes);
        integer cycles;
        reg handshake;
        begin
            @(negedge clk);
            awaddr = addr;
            wdata = value;
            wstrb = strobes;
            awvalid = 1'b1;
            wvalid = 1'b1;
            bready = 1'b0;

            handshake = 1'b0;
            for (cycles = 0; cycles < 30 && !handshake; cycles = cycles + 1) begin
                @(posedge clk);
                if (awready && wready) handshake = 1'b1;
            end
            if (!handshake) $fatal(1, "AXI write handshake timeout: %h", addr);

            @(negedge clk);
            awvalid = 1'b0;
            wvalid = 1'b0;
            bready = 1'b1;

            cycles = 0;
            while (!bvalid && cycles < 30) begin
                @(negedge clk);
                cycles = cycles + 1;
            end
            if (!bvalid) $fatal(1, "AXI write response timeout: %h", addr);
            if (bresp !== 2'b00) $fatal(1, "AXI write BRESP not OKAY: %b", bresp);
            @(negedge clk);
            bready = 1'b0;
        end
    endtask

    task automatic axi_read(input [4:0] addr, output [31:0] value);
        integer cycles;
        reg handshake;
        begin
            @(negedge clk);
            araddr = addr;
            arvalid = 1'b1;
            rready = 1'b0;

            handshake = 1'b0;
            for (cycles = 0; cycles < 30 && !handshake; cycles = cycles + 1) begin
                @(posedge clk);
                if (arready) handshake = 1'b1;
            end
            if (!handshake) $fatal(1, "AXI read address timeout: %h", addr);

            @(negedge clk);
            arvalid = 1'b0;

            cycles = 0;
            while (!rvalid && cycles < 30) begin
                @(negedge clk);
                cycles = cycles + 1;
            end
            if (!rvalid) $fatal(1, "AXI read data timeout: %h", addr);
            if (rresp !== 2'b00) $fatal(1, "AXI read RRESP not OKAY: %b", rresp);
            value = rdata;
            rready = 1'b1;
            @(negedge clk);
            rready = 1'b0;
        end
    endtask

    task automatic verify_multiply(input signed [15:0] a,
                                   input signed [15:0] b);
        integer polls;
        reg [31:0] status_value;
        reg [31:0] product_value;
        reg signed [31:0] expected;
        begin
            expected = a * b;
            axi_write(REG_A, {{16{a[15]}}, a}, 4'hF);
            axi_write(REG_B, {{16{b[15]}}, b}, 4'hF);
            axi_write(REG_CONTROL, 32'h0000_0001, 4'h1);

            status_value = 32'd0;
            polls = 0;
            while (!status_value[0] && polls < 20) begin
                axi_read(REG_STATUS, status_value);
                polls = polls + 1;
            end
            if (!status_value[0]) $fatal(1, "Completion timed out for %0d * %0d", a, b);
            axi_read(REG_RESULT, product_value);
            if ($signed(product_value) !== expected)
                $fatal(1, "FAIL: %0d * %0d expected %0d got %0d", a, b, expected, $signed(product_value));
            $display("PASS: AXI %0d * %0d = %0d", a, b, $signed(product_value));
        end
    endtask

    reg [31:0] observed;
    initial begin
        repeat (5) @(negedge clk);
        resetn = 1'b1;
        axi_read(REG_STATUS, observed);
        if (observed !== 32'd0) $fatal(1, "STATUS not reset");
        verify_multiply(16'sd12, 16'sd7);
        verify_multiply(-16'sd12, 16'sd7);
        verify_multiply(16'sd0, -16'sd271);
        verify_multiply(16'sd300, -16'sd400);
        verify_multiply(16'sd32767, 16'sd32767);
        verify_multiply(16'sh8000, 16'sh8000);
        verify_multiply(16'sh8000, 16'sd32767);

        // STATUS and RESULT are read-only, writes should be ignored.
        axi_write(REG_STATUS, 32'hDEAD_BEEF, 4'hF);
        axi_read(REG_STATUS, observed);
        if (observed !== 32'd1) $fatal(1, "STATUS corrupted by write");
        axi_write(REG_RESULT, 32'hDEAD_BEEF, 4'hF);
        axi_read(REG_RESULT, observed);
        if ($signed(observed) !== -32'sd1073709056)
            $fatal(1, "RESULT corrupted by write");
        $display("PASS: STATUS and RESULT ignore software writes");

        // 16-bit operand write via lower two byte lanes only.
        axi_write(REG_A, 32'h0000_0012, 4'b0011);
        axi_read(REG_A, observed);
        if (observed[15:0] !== 16'h0012)
            $fatal(1, "WSTRB lower-two-byte write failed");
        $display("PASS: AXI byte write strobes");

        $display("ALL PASS: AXI-controlled signed multiplier tests");
        $finish;
    end
endmodule
