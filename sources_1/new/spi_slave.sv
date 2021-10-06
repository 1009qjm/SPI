`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/01 20:05:45
// Design Name: 
// Module Name: spi_slave
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

//CPOL=0,CPHA=0,每次传输一个字节
module spi_slave(
input logic SCLK,
input logic MOSI,
output logic MISO,
input logic CS,                     //低有效
//
output logic [7:0]data
    );
//空闲时SCLK为低电平，上升沿进行数据的采样，下降沿进行数据的切换
logic recv_bit;
logic [7:0] recv_data;
logic [7:0] send_data=8'b10100101;
logic [31:0] recv_count=32'd0;
logic [31:0] send_count=32'd0;
//
assign MISO=send_data[7];                         //先发送高位
//从机数据接收
//recv_count,每个上升沿到来且CS为低时，加1(mod 8)
always_ff@(posedge SCLK)
if(CS)
    recv_count<=0;
else if(recv_count==7) 
    recv_count<=0;
else
    recv_count<=recv_count+1;
//串转并,每个上升沿到来且CS为低时,进行移位
always_ff@(posedge SCLK)
if(~CS)
begin
    recv_data[0]<=MOSI;
    for(int i=0;i<7;i++)
        recv_data[i+1]<=recv_data[i];
end
//从机数据发送
//send_count,下降沿来临且CS为低，则加1(mod 8)
always_ff@(negedge SCLK)
if(CS)
    send_count<=0;
else if(send_count==7)
    send_count<=0;
else
    send_count<=send_count+1;
//MISO,下降沿到来且CS为低时，切换数据(移位)
always_ff@(negedge SCLK)
if(~CS)
begin
    send_data[0]<=1'b0;
    for(int i=0;i<7;i++)
        send_data[i+1]<=send_data[i];
end
//
assign data=recv_data;

endmodule
