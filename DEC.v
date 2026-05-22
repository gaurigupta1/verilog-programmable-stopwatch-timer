`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2026 11:09:09 AM
// Design Name: 
// Module Name: mode0
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


module DEC(
    input r,
    input en,
    input slow_clk, 
    input [15:0] preset,
    output reg running, 
    output reg [3:0] cntms,
    output reg [3:0] cnt10ms, 
    output reg [3:0] cnts, 
    output reg [3:0] cnt10s
    );
     
  
    always@(posedge slow_clk)begin
         
         if(r)begin
            cntms <= preset[3:0];
            cnt10ms <= preset[7:4];
            cnts <= preset[11:8];
            cnt10s <= preset[15:12];
            running <= 1;
        end  
        else if (en)begin
            if(cntms == 4'b0000)begin
                if(cnt10ms == 4'b0000)begin
                    if(cnts == 4'b0000)begin
                        if(cnt10s == 4'b0000)begin
                            running <= 0;
                        end
                        else begin
                            cnt10s <=cnt10s-1;
                            cnts <= 9;
                            cnt10ms <= 9;
                            cntms <= 9;
                        end
                    end
                    else begin
                        cnts <=cnts-1;
                        cnt10ms <= 9;
                        cntms <= 9;
                    end
                end
                else begin
                    cnt10ms <=cnt10ms-1;
                    cntms <= 9;
                end
            end
            else begin
            cntms <= cntms -1;
            end
          end  
     end
endmodule