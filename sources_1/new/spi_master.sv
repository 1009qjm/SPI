`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/01 20:06:02
// Design Name: 
// Module Name: spi_master
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
/*
SPI协议规定一个SPI设备不能在数据通信过程中仅仅充当一个发送者（Transmitter）或者接受者（Receiver）。
在片选信号CS为0的情况下，每个clock周期内，SPI设备都会发送并接收1 bit数据，相当于有1 bit数据被交换了
*/

module spi_master(
input logic clk,
input logic rst,
//
input logic [7:0] wr_data,
input logic start,
output logic [7:0] rd_data,
//
output logic MOSI,
input logic MISO,
output logic SCLK,
output logic CS,
//
output logic done
    );

logic [7:0] send_data;              //待发送的8位数据
logic [7:0] recv_data;              //接收到的8位数据
logic [31:0] send_cnt=32'd0;        //发送比特数
logic [31:0] recv_cnt=32'd0;        //接收比特数
logic recving;                      //正在接收数据
logic recv_done;                    //接收完毕
logic recv_done_ff;
logic [31:0] clk_cnt;
parameter MAX_COUNT = 10;                 
//
always_ff@(posedge clk)
    recv_done_ff<=recv_done;
assign done=~recv_done_ff&&recv_done;
//主机发送数据
//send_data寄存
always_ff@(posedge clk,posedge rst)
if(rst)
    send_data<=0;
else if(start)
    send_data<=wr_data;
//clk_cnt,用于分频产生SCLK的计数器
always_ff@(posedge clk,posedge rst)
if(rst)
    clk_cnt<=0;
else if(~CS)                           //CS为低有效时，开始计数
begin
    if(clk_cnt==MAX_COUNT-1)
        clk_cnt<=0;
    else
        clk_cnt<=clk_cnt+1;
end
else
    clk_cnt<=0;
//SCLK,由clk分频得到
always_ff@(posedge clk,posedge rst)
if(CS)
   SCLK=1'b0;
else if(clk_cnt==MAX_COUNT-1)
   SCLK<=~SCLK;
//CS
always_ff@(posedge clk,posedge rst)
if(rst)
    CS<=1'b1;
else if(start)
    CS<=1'b0;
else if(done)
    CS<=1'b1;
//MOSI
assign MOSI=send_data[7];
//移位
always_ff@(negedge SCLK)
if(~CS)
begin
    send_data[0]<=1'b0;
    for(int i=0;i<7;i++)
        send_data[i+1]<=send_data[i];
end
//send_cnt
always_ff@(negedge SCLK)
if(~CS)
begin
    if(send_cnt==7)
        send_cnt<=0;
    else
        send_cnt<=send_cnt+1;
end
else
begin
    send_cnt<=0;
end
/*******************************************************************/
//接收数据
always_ff@(posedge SCLK)
if(~CS)                               //SCLK上升沿且CS为低时采集数据(移位)
begin    
    recv_data[0]<=MISO;
    for(int i=0;i<7;i++)
        recv_data[i+1]<=recv_data[i];
end
//recv_done
always_ff@(posedge SCLK)
if(~CS)
begin
    if(recv_cnt==7)
        recv_done<=1;
    else
        recv_done<=0;
end
else
   recv_done<=0;
//recv_cnt
always_ff@(posedge SCLK)
if(~CS)
begin
    if(recv_cnt==7)
        recv_cnt<=0;
    else
        recv_cnt<=recv_cnt+1;
end
//recving
always_ff@(posedge clk,posedge rst)
if(rst)
    recving<=0;
else if(start)
    recving<=1;
else if(recv_done)
    recving<=0;
//rd_data
assign rd_data=recv_data;
endmodule
