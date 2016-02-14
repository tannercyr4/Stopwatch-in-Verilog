`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2015 06:40:51 PM
// Design Name: 
// Module Name: muxer
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


module muxer(
    input clock,
    input reset,
    input [3:0] fourth,
    input [3:0] third,
    input [3:0] second,
    input [3:0] first,
    output a_m,
    output b_m,
    output c_m,
    output d_m,
    output e_m,
    output f_m,
    output g_m,
    output dp_m,
    output [3:0] an_m
    );
 
//The Circuit for 7 Segment Multiplexing -
 
localparam N = 18;
 
reg [N-1:0]count; //the 18 bit counter which allows us to multiplex at 1000Hz
 
always @ (posedge clock or posedge reset)
 begin
  if (reset)
   count <= 0;
  else
   count <= count + 1;
 end
 
reg [3:0]sseg; //the 4 bit register to hold the data that is to be output
reg [3:0]an_temp; //register for the 4 bit enable
reg reg_dp;
always @ (*)
 begin
  case(count[N-1:N-2]) //MSB and MSB-1 for multiplexing
    
   2'b00 :
    begin
     sseg = first;
     an_temp = 4'b1110;
     reg_dp = 1'b1;
    end
    
   2'b01:
    begin
     sseg = second;
     an_temp = 4'b1101;
     reg_dp = 1'b1;
    end
    
   2'b10:
    begin
     sseg = third;
     an_temp = 4'b1011;
     reg_dp = 1'b1;
    end
     
   2'b11:
    begin
     sseg = fourth;
     an_temp = 4'b0111;
     reg_dp = 1'b0;
    end
  endcase
 end
assign an_m = an_temp;
 
reg [6:0] sseg_temp;
always @ (*)
 begin
  case(sseg)
   4'd0 : sseg_temp = 7'b1000000; //display 0
   4'd1 : sseg_temp = 7'b1111001; //display 1
   4'd2 : sseg_temp = 7'b0100100; //display 2
   4'd3 : sseg_temp = 7'b0110000; //display 3
   4'd4 : sseg_temp = 7'b0011001; //display 4
   4'd5 : sseg_temp = 7'b0010010; //display 5
   4'd6 : sseg_temp = 7'b0000010; //display 6
   4'd7 : sseg_temp = 7'b1111000; //display 7
   4'd8 : sseg_temp = 7'b0000000; //display 8
   4'd9 : sseg_temp = 7'b0010000; //display 9
   4'd10 : sseg_temp = 7'b0111111; //to display dash
   4'd11 : sseg_temp = 7'b0111111; //to display dash
   default : sseg_temp = 7'b0111111; //dash
  endcase
 end
assign {g_m, f_m, e_m, d_m, c_m, b_m, a_m} = sseg_temp;
assign dp_m = reg_dp;
 
endmodule

