`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/07/2015 07:30:20 PM
// Design Name: 
// Module Name: wrapper
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


module wrapper(
    input clock,
    input En,
    input reset,
    input start,
    input stop,
    input inc,
    output a, b, c, d, e, f, g, dp,
    output [3:0] an,
    output [3:0] anode
    );
 
reg [3:0] reg_d0, reg_d1, reg_d2, reg_d3; //registers that will hold the individual counts
reg [22:0] ticker; //23 bits needed to count up to 5M bits
wire click;
wire run;
wire incr;

controller uut(
    .clk(clock),
	.rst(reset),
	.start(start),
	.stop(stop),
	.inc(inc),
	.run(run),
	.Incr(incr)
);
always @ (posedge clock or posedge reset)
begin
 if(reset)
 
  ticker <= 0;
 
 else if(ticker == 100000) //if it reaches the desired max value reset it
  ticker <= 0;
 else if(run & En) //only start if the input is set high
  ticker <= ticker + 1;
end
 
assign click = ((ticker == 100000)?1'b1:1'b0); //click to be assigned high every 0.001 second
 
always @ (posedge clock or posedge reset)
begin
 if (reset)
  begin
   reg_d0 <= 0;
   reg_d1 <= 0;
   reg_d2 <= 0;
   reg_d3 <= 0;
  end
 else if (inc)
 begin
 reg_d3 <= reg_d3 + 1; 
 if (reg_d3 >= 9)
 begin
 reg_d3 = 0;
 end  
 end
 else if (click) //increment at every click
  begin
   if(reg_d0 == 9) //x.xx9 - the 0.001 second digit
   begin  //if_1
    reg_d0 <= 0;
     
    if (reg_d1 == 9) //x.x99
    begin  // if_2
     reg_d1 <= 0;
     if (reg_d2 == 9) //x.999 - the tens digit
     begin //if_3
      reg_d2 <= 0;
      if(reg_d3 == 9) //9.999 - The seconds digit
       reg_d3 <= 0;
      else
       reg_d3 <= reg_d3 + 1;
     end
     else //else_3
      reg_d2 <= reg_d2 + 1;
    end
     
    else //else_2
     reg_d1 <= reg_d1 + 1;
   end
    
   else //else_1
    reg_d0 <= reg_d0 + 1;
  end
end
 
localparam N = 18;
 
reg [N-1:0]count;
 
always @ (posedge clock or posedge reset)
 begin
  if (reset)
   count <= 0;
  else
   count <= count + 1;
 end
 
reg [6:0]sseg;
reg [3:0]an_temp;
reg reg_dp;
always @ (*)
 begin
  case(count[N-1:N-2])
    
   2'b00:
    begin
     sseg = reg_d0;
     an_temp = 4'b1110;
     reg_dp = 1'b1;
    end
    
   2'b01:
    begin
     sseg = reg_d1;
     an_temp = 4'b1101;
     reg_dp = 1'b1;
    end
    
   2'b10:
    begin
     sseg = reg_d2;
     an_temp = 4'b1011;
     reg_dp = 1'b1;
    end
     
   2'b11:
    begin
     sseg = reg_d3;
     an_temp = 4'b0111;
     reg_dp = 1'b0;
    end
  endcase
 end
assign an = an_temp;
 
reg [6:0] sseg_temp;
always @ (*)
 begin
  case(sseg)
   4'd0 : sseg_temp = 7'b1000000;
   4'd1 : sseg_temp = 7'b1111001;
   4'd2 : sseg_temp = 7'b0100100;
   4'd3 : sseg_temp = 7'b0110000;
   4'd4 : sseg_temp = 7'b0011001;
   4'd5 : sseg_temp = 7'b0010010;
   4'd6 : sseg_temp = 7'b0000010;
   4'd7 : sseg_temp = 7'b1111000;
   4'd8 : sseg_temp = 7'b0000000;
   4'd9 : sseg_temp = 7'b0010000;
   default : sseg_temp = 7'b0111111; //dash
  endcase
 end
assign {g, f, e, d, c, b, a} = sseg_temp;
assign dp = reg_dp;
 
 
endmodule
