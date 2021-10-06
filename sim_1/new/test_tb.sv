`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/01 21:33:55
// Design Name: 
// Module Name: test_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_tb;
logic clk;
logic rst;
logic [7:0] wr_data;
logic [7:0] rd_data;
logic start;
logic MISO;
logic MOSI;
logic SCLK;
logic CS;
logic done;
logic [7:0] data;
//clk rst
initial begin
    clk=0;
    forever begin
        #5 clk=~clk;
    end
end
initial begin
    rst=1;
    #20
    rst=0;
end
//start,wr_data
initial begin
    start=0;
    wr_data=0;
    #100
    start=1;
    wr_data=8'b11001010;
    #10
    start=0;
    wait(done==1);
    @(posedge clk);
    @(posedge clk); 
    start=1;
    wr_data=8'b11110000;
    #10
    start=0;
end


//SPI MASTER
spi_master U1(
.clk(clk),
.rst(rst),
//
.wr_data(wr_data),
.start(start),
.rd_data(rd_data),
//
.MOSI(MOSI),
.MISO(MISO),
.SCLK(SCLK),
.CS(CS),
//
.done(done)
);

//SPI SLAVE
spi_slave U2(
.SCLK(SCLK),
.MOSI(MOSI),
.MISO(MISO),
.CS(CS),                     //低有效
.data(data)
);
endmodule
