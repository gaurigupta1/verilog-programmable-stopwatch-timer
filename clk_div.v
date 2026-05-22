`timescale 1ns / 1ps


module clk_div(
    input clk,
    input reset,
    output reg clk_out
    );

    localparam HALF_PERIOD = 500000;
    
    reg [19:0] COUNT;
        
    always @(posedge clk)
    begin
    if(reset) begin
        COUNT <= 0;
        clk_out <= 0;
        end
    else begin 
        if (COUNT == HALF_PERIOD - 1) begin
             COUNT <= 0;
             clk_out <= ~clk_out;
         end else begin
             COUNT <= COUNT + 1;
         end
       end
    end
endmodule
