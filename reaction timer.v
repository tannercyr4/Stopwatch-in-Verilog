`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2015 05:26:26 PM
// Design Name: 
// Module Name: reaction timer
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


module reaction_timer(
  input clock, reset, start, stop,
  output led,
  output [3:0] an,
  output a, b, c, d, e, f, g, dp,
  output [3:0] anode
  );
reg [3:0] regd3, regd2, regd1, regd0; //the main output registers
 
wire db_start, db_stop;
reg dffstr1, dffstr2, dffstp1, dffstp2;
  
always @ (posedge clock) dffstr1 <= start;
always @ (posedge clock) dffstr2 <= dffstr1;
  
assign db_start = ~dffstr1 & dffstr2; //monostable multivibrator to detect only one pulse of the button
  
always @ (posedge clock) dffstp1 <= stop;
always @ (posedge clock) dffstp2 <= dffstp1;
  
assign db_stop = ~dffstp1 & dffstp2; //monostable multivibrator to detect only one pulse of the button
 
 
// Instantiate the 7 segment multiplexing module
muxer display (
    .clock(clock),
    .reset(reset),
    .fourth(regd3),
    .third(regd2),
    .second(regd1),
    .first(regd0),
    .a_m(a),
    .b_m(b),
    .c_m(c),
    .d_m(d),
    .e_m(e),
    .f_m(f),
    .g_m(g),
    .dp_m(dp),
    .an_m(an)
    );
 
//Block for LFSR random number generator 
 
reg [28:0] random, random_next, random_done; //**29 bit register to keep track upto 10 seconds.
 
 
reg [4:0] count_r, count_next_r; //to keep track of the shifts. 5 bit register to count up to 30
 
wire feedback = random[28] ^ random[26];
 
always @ (posedge clock or posedge reset)
begin
 if (reset)
 begin
  random <= 29'hF; //An LFSR cannot have an all 0 state, thus reset to FF.
  count_r <= 0;
 end
  
 else
 begin
  random <= random_next;
  count_r <= count_next_r;
 end
end
 
always @ (*)
begin
 random_next = random; //default state stays the same
 count_next_r = count_r;
   
  random_next = {random[27:0], feedback}; //shift left the xor'd every posedge clock
            
 
 if (count_r == 29)
 begin
  count_next_r = 0;
  random_done = random; //assign the random number to output after 30 shifts
 end
 else
 begin
  count_next_r = count_r + 1;
  random_done = random; //keep previous value of random
 end
  
end
//random number block ends
 
 
reg [3:0] reg_d0, reg_d1, reg_d2, reg_d3; //registers that will hold the individual counts
(* KEEP = "TRUE" *)reg [1:0] sel, sel_next; //for KEEP attribute see note below
localparam [1:0]
      idle = 2'b00,
      starting = 2'b01,
      time_it = 2'b10,
      done = 2'b11;
       
reg [1:0] state_reg, state_next;
reg [28:0] count_reg, count_next;
 
always @ (posedge clock or posedge reset)
begin
 if(reset)
  begin
   state_reg <= idle;
   count_reg <= 0;
   sel <=0;
  end
 else
  begin
   state_reg <= state_next;
   count_reg <= count_next;
   sel <= sel_next;
  end
end
 
reg go_start;
always @ (*)
begin
 state_next = state_reg; //default state stays the same
 count_next = count_reg;
 sel_next = sel;
 case(state_reg)
  idle:
   begin
    //DISPLAY HI HERE
    sel_next = 2'b00;
    if(db_start)
    begin
     count_next = random_done; //get the random number from LFSR module
     state_next = starting; //go to next state
    end
   end
  starting:
   begin
    if(count_next == 500000000) // **500M equals a delay of 10 seconds. and starting from 'rand' ensures a random delay
    begin 
     state_next = time_it; //go to next state
    end
     
    else
    begin
     count_next = count_reg + 1;
    end
   end 
  time_it:
   begin
     sel_next = 2'b01; //start the timer
     state_next = done;    
   end
     
  done:
   begin
    if(db_stop)
     begin
      sel_next = 2'b10; //stop the timer
     end
     
   end
    
  endcase
   
 case(sel_next) //this case statement that will control what is sent to the 7 segment based on the sel signal
  2'b00: //hi
  begin
   go_start = 0; //make sure timer module is off
   regd0 = 4'd12;
   regd1 = 4'd11;
   regd2 = 4'd10;
   regd3 = 4'd12;
  end
   
  2'b01: //timer
  begin
    
   go_start = 1'b1; //enable start signal to start timer
   regd0 = reg_d0;
   regd1 = reg_d1;
   regd2 = reg_d2;
   regd3 = reg_d3;
  end
   
  2'b10: //stop timer
  begin
   go_start = 1'b0;
   regd0 = reg_d0;
   regd1 = reg_d1;
   regd2 = reg_d2;
   regd3 = reg_d3;
  end
   
  2'b11: //Although this condition is of no use to us it is placed here for the sake of completion, case statements left uncompleted will create a latch in implementation
  begin
   regd0 = 4'd12; //4'd12 to siplay '-'
   regd1 = 4'd12;
   regd2 = 4'd12;
   regd3 = 4'd12;
   go_start = 1'b0;
  end
   
  default:
  begin
   regd0 = 4'd12;
   regd1 = 4'd12;
   regd2 = 4'd12;
   regd3 = 4'd12;
   go_start = 1'b0;
  end
 endcase  
end
 
 
//the stopwatch block
 
 
reg [18:0] ticker; //19 bits needed to count up to 500K bits
wire click;
 
//the mod 500K clock to generate a tick ever 0.01 second
 
always @ (posedge clock or posedge reset)
begin
 if(reset)
 
  ticker <= 0;
 
 else if(ticker == 100000) //if it reaches the desired max value of 500K reset it
  ticker <= 0;
 else if(go_start) //only start if the input is set high
  ticker <= ticker + 1;
end
 
assign click = ((ticker == 100000)?1'b1:1'b0); //click to be assigned high every 0.01 second
 
always @ (posedge clock or posedge reset)
begin
 if (reset)
  begin
   reg_d0 <= 0;
   reg_d1 <= 0;
   reg_d2 <= 0;
   reg_d3 <= 0;
  end
   
 else if (click) //increment at every click
  begin
   if(reg_d0 == 9) //xxx9 - the 0.001 second digit
   begin  //if_1
    reg_d0 <= 0;
     
    if (reg_d1 == 9) //xx99
    begin  // if_2
     reg_d1 <= 0;
     if (reg_d2 == 5) //x599 - the two digit seconds digits
     begin //if_3
      reg_d2 <= 0;
      if(reg_d3 == 9) //9599 - The minute digit
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
 
//If count_reg == 500M - check if 'stop' key is pressed, if yes disable led, otherwise enable it. If count_reg ~= 500M keep led off.
assign led = ((count_reg == 500000000)?((db_stop == 1)?1'b0:1'b1):1'b0);
 
endmodule