`timescale 1ns / 1ps
module spi_master(
    input clk,rst_n,start,
    input [7:0] data_in,
    output reg busy,
    output reg [7:0] data_out,
    output reg sclk,mosi,cs_n,
    input miso
    );
    reg [5:0] clk_div;
    wire sclk_tick = (clk_div == 6'd49);
    reg [2:0] state;
    reg [3:0] bit_cnt;
    reg [7:0] shift_reg_tx,shift_reg_rx;
    localparam IDLE =0,START=1,SHIFT=2,DONE=3;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cs_n <= 1'b1;
            mosi <= 1'b0;   
            sclk <= 1'b0;
            clk_div <= 5'b00000;
            busy <= 1'b0;
            bit_cnt <= 0;
            state <= IDLE;
            data_out<=0;
            end else begin
                case (state) 
                        IDLE: begin
                            cs_n <= 1'b1;
                            sclk <= 1'b0;
                            busy <= 1'b0;
                            if (start) begin
                                shift_reg_tx <=data_in;
                                busy <= 1'b1;
                                state <= START;
                                clk_div <=0;
                                end 
                            end 
                       START: begin
                            cs_n <= 1'b0;
                            if (sclk_tick) begin
                                clk_div<=0;
                                state<=SHIFT;
                                mosi <= shift_reg_tx[7];
                                bit_cnt <=8;
                                end
                            else begin
                                clk_div <= clk_div + 1;
                           end 
                      end
                      SHIFT: begin
                    if (sclk_tick) begin
                            clk_div <= 0;
                            sclk <= ~sclk;
                            if (~sclk) begin                      // falling edge: sample
                                shift_reg_rx <= {shift_reg_rx[6:0], miso};
                                if (bit_cnt == 0) begin
                                    state <= DONE;                    // all 8 bits sampled
                                end
                            end else begin                        // rising edge: drive
                                    mosi <= shift_reg_tx[7];
                                    bit_cnt <= bit_cnt - 1;
                                    shift_reg_tx <= {shift_reg_tx[6:0], 1'b0};
                                    end
                                 end else begin
                                        clk_div <= clk_div + 1;
                                    end
                        end
                     DONE: begin
                        if (sclk_tick) begin
                            cs_n <= 1'b1;
                            clk_div <= 0;
                            data_out <= shift_reg_rx;
                            busy <= 1'b0;
                            state <= IDLE;
                        end
                        else clk_div <= clk_div+1;
                     end
                 endcase
            end 
        end
         
endmodule
