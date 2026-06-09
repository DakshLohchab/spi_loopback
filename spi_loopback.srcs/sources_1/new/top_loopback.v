`timescale 1ns / 1ps
module top_loopback(
    input clk,
    input btn0,//reset
    input btn1, //start
    input [7:0] sw ,//incoming switches data
    output [7:0] led,//output led data
    // pmodA
    output pmodA_cs,
    output pmodA_sclk,
    output pmodA_mosi,
    input pmodA_miso,
    //pmodB
    input pmodB_cs,
    input pmodB_sclk,
    input pmodB_mosi,
    output pmodB_miso    
    );
    wire rst_n = ~btn0;
    wire [7:0] master_rx_data;
    assign led = master_rx_data;
    spi_master master(
    .clk(clk),
    .rst_n(rst_n),
    .start(btn1),
    .data_in(sw),
    .busy(),
    .data_out(master_rx_data),
    .sclk(pmodA_sclk),
    .cs_n(pmodA_cs),
    .miso(pmodA_miso),
    .mosi(pmodA_mosi)
    );
    spi_slave slave(
    .clk(clk),
    .rst_n(rst_n),
    .sclk(pmodB_sclk),
    .mosi(pmodB_mosi),
    .miso(pmodB_miso),
    .cs_n(pmodB_cs),
    .data_out(),
    .rx_done()
    );
    
endmodule
