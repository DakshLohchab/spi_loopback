`timescale 1ns / 1ps

module tb_loopback();

    reg clk, btn0, btn1;
    reg [7:0] sw;
    wire sclk_wire, mosi_wire, miso_wire, cs_wire;
    wire [7:0] led;

    // Instantiate the top module (connects master and slave)
    top_loopback dut(
        .clk(clk),
        .btn0(btn0),
        .btn1(btn1),
        .sw(sw),
        .led(led),
        .pmodA_miso(miso_wire),
        .pmodA_cs(cs_wire),
        .pmodA_mosi(mosi_wire),
        .pmodA_sclk(sclk_wire),
        .pmodB_cs(cs_wire),
        .pmodB_mosi(mosi_wire),
        .pmodB_miso(miso_wire),
        .pmodB_sclk(sclk_wire)
    );

    // Internal signals for debugging
    wire [1:0] tb_state   = dut.master.state;
    wire [3:0] tb_clk_div = dut.master.clk_div;
    wire [2:0] tb_bit_cnt = dut.master.bit_cnt;

    // Clock generation: 100 MHz -> period = 10 ns
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Initial values
        btn1 = 0;
        btn0 = 1;       // reset active (rst_n = 0)
        sw   = 8'hA5;

        // Wait a bit, then release reset
        #100;
        btn0 = 0;       // rst_n = 1

        // ------------------------------------------------------------
        // FIRST TRANSACTION: send 0xA5 to the slave
        // ------------------------------------------------------------
        #100;
        btn1 = 1;       // start pulse
        #100;
        btn1 = 0;

        // Wait for the transaction to finish (approx 8*50*10ns = 4us, plus margin)
        #50000;         // 50 us

        // At this point, the slave has received 0xA5 into its internal register,
        // but the master has read back the *previous* slave data (initial 0x00).
        // So led is still 0x00.

        // ------------------------------------------------------------
        // SECOND TRANSACTION: send dummy data (0x00) to read back 0xA5
        // ------------------------------------------------------------
        sw = 8'h00;     // dummy byte
        #100;
        btn1 = 1;
        #100;
        btn1 = 0;

        #50000;

        // Now the slave transmits 0xA5, the master receives it, and led becomes 0xA5.
        // Display the result for verification
        $display("LED value after second transaction: %h", led);
        if (led == 8'hA5)
            $display("TEST PASSED: Loopback works correctly");
        else
            $display("TEST FAILED: Expected A5, got %h", led);

        // ------------------------------------------------------------
        // OPTIONAL: third transaction to verify further (send 0x3C)
        // ------------------------------------------------------------
        #5000;
        sw = 8'h3C;
        #100;
        btn1 = 1;
        #100;
        btn1 = 0;
        #50000;

        // Now send dummy again to read back 0x3C
        sw = 8'h00;
        #100;
        btn1 = 1;
        #100;
        btn1 = 0;
        #50000;

        $display("LED value after fourth transaction: %h", led);
        if (led == 8'h3C)
            $display("TEST PASSED: Second data also works");
        else
            $display("TEST FAILED: Expected 3C, got %h", led);

        $finish;
    end

endmodule