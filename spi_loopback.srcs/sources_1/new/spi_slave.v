`timescale 1ns / 1ps

module spi_slave(
    input clk, rst_n,
    input sclk, mosi, cs_n,
    output reg miso,
    output reg rx_done,
    output reg [7:0] data_out
);

    // Synchronisers for metastability
    reg [2:0] sclk_sync;
    reg [1:0] cs_sync;
    reg [1:0] mosi_sync;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sclk_sync <= 3'b000;
            cs_sync   <= 2'b11;
            mosi_sync <= 2'b00;
        end else begin
            sclk_sync <= {sclk_sync[1:0], sclk};
            cs_sync   <= {cs_sync[0], cs_n};
            mosi_sync <= {mosi_sync[0], mosi};
        end
    end

    // Edge detection (using the synchronised signals)
    wire sclk_rising = (sclk_sync[2:1] == 2'b01);
    wire sclk_falling = (sclk_sync[2:1] == 2'b10);
    wire cs_active = ~cs_sync[1];          // cs_n is low active

    // Internal registers
    reg [2:0] bit_cnt;
    reg [7:0] shift_reg;      // holds the byte to be sent (MSB first)
    reg [7:0] rx_reg;         // holds the received byte

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            miso     <= 1'b0;
            rx_done  <= 1'b0;
            data_out <= 8'b0;
            bit_cnt  <= 3'b0;
            shift_reg <= 8'b0;
            rx_reg    <= 8'b0;
        end else begin
            rx_done <= 1'b0;

            // CS is inactive (high)
            if (!cs_active) begin
                bit_cnt  <= 3'b0;
                // Prepare to send the previously received byte (or initial value)
                shift_reg <= rx_reg;
                // Output the MSB immediately (for the first rising edge)
                miso <= rx_reg[7];
            end else begin
                // CS active (low)
                // On rising edge of sclk: shift out next bit
                if (sclk_rising) begin
                    rx_reg <= {rx_reg[6:0], mosi_sync[1]};
                    bit_cnt <= bit_cnt + 1;
                    if (bit_cnt == 7) begin
                        data_out <= {rx_reg[6:0], mosi_sync[1]};
                        rx_done <= 1'b1;
                    end
                end
                // On falling edge of sclk: shift out next bit (Match Master's Mode)
                else if (sclk_falling) begin
                    miso <= shift_reg[7];
                    shift_reg <= {shift_reg[6:0], 1'b0};
                end
                end
            end
        end
 

endmodule