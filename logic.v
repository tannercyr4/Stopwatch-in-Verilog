`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/12/2015 09:16:35 PM
// Design Name: 
// Module Name: logic
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


module logic(
    input start, stop, inc, clock, reset,
    output a, b, c, d, e, f, g, dp,
    output [3:0] an,
    output [3:0] anode
    );
    reg run;
    reg incr;
    always @ (clock or start or stop or inc)
    begin
        controller(
        .clk(clock),
        .rst(reset),
        .start(start),
        .stop(stop),
        .inc(inc),
        .run(run),
        .Incr(incr)
        );
        
        wrapper(
         .clock(clock),
         .reset(reset),
         .start(run),
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
       end
endmodule
