`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2015 04:35:30 PM
// Design Name: 
// Module Name: mux
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


module mux(
    input clock,
    input reset,
    input start,
    input stop,
    input inc,
    input [1:0]sw,
    output a, b, c, d, e, f, g, dp,
    output [3:0] an,
    output [3:0] anode,
    output [1:0]led
    );
    
   wrapper stopwatch (
    .clock(clock),
    .En(sw[0]),
    .reset(reset),
    .start(start),
    .stop(stop),
    .inc(inc),
    .a(a),
    .b(b), 
    .c(c), 
    .d(d), 
    .e(e), 
    .f(f),
    .g(g), 
    .dp(dp),
    .an(an),
    .anode(anode)    
    );
   
endmodule
