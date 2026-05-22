`timescale 1ns / 1ps

module swtmain(
    input r,
    input s, 
    input clk, 
    input [1:0] mode,
    input [7:0] load,
    output reg dp,
    output [2:0] led,
    output reg [3:0] an,
    output wire [6:0] seg
    );
    
    wire [3:0] cntmsi, cnt10msi, cntsi, cnt10si;
    wire [3:0] cntmsd, cnt10msd, cntsd, cnt10sd;

    reg [2:0] state = 0;
    reg [2:0] next_state;
    reg running = 1;
    wire slow_clk;
    reg [15:0] preset;
    
    wire running_inc;
    wire running_dec;

    
    assign led = state;

    
    clk_div cl(clk, r, slow_clk);
    DEC d(.r(state==3'd0), .en(state==3'd2), .slow_clk(slow_clk), .preset(preset), .running(running_dec),
    .cntms(cntmsd), .cnt10ms(cnt10msd), .cnts(cntsd), .cnt10s(cnt10sd));
    
    INC i(.r(state==3'd0), .en(state==3'd1), .slow_clk(slow_clk), .preset(preset), .running(running_inc),
    .cntms(cntmsi), .cnt10ms(cnt10msi), .cnts(cntsi), .cnt10s(cnt10si));
      
    reg [1:0] digit_sel = 0;
    reg [3:0] current_digit;
    reg [14:0] notasalow_clock =0;
    reg clk_en;
    
    reg s_prev;
    always @(posedge slow_clk) begin
        s_prev <= s;
    end
    wire s_edge = s && !s_prev;
    
    
    always @(*) begin
        case(state)
            3'd0:begin
            if(s_edge == 1'b0)
                next_state = 3'd0;
            else begin
            if(mode[0]==0)
                next_state = 3'd1;
            else
                next_state = 3'd2;
            end   
         end
            3'd1:begin
                if(s_edge || (cntmsi==9 && cnt10msi==9 && cntsi==9 && cnt10si==9))
                    next_state = 3'd3;
                else 
                    next_state = 3'd1;  
            end
            3'd2:begin
                if(s_edge || (cntmsd==0 && cnt10msd==0 && cntsd==0 && cnt10sd==0))
                    next_state = 3'd4;
                else 
                    next_state = 3'd2; 
                 end   
             3'd3:begin
             if(s_edge && running_inc)
                next_state = 3'd1;
             else
                next_state = 3'd3;
             end
             3'd4:begin
             if(s_edge && running_dec)
                next_state = 3'd2;
             else
                next_state = 3'd4;
             end
             default: next_state = 3'd0;
        endcase
    end
    
    always @(posedge slow_clk or posedge r) begin
    if (r)
        preset <= 16'd0;
    else if (state == 3'd0) begin
        case(mode)
            2'b00: preset <= 16'd0;
            2'b01: preset <= 16'b1001100110011001;
            2'b10: preset <= {load, 8'b00000000};
            2'b11: preset <= {load, 8'b00000000};
        endcase
    end
end

    
    always @(posedge clk) begin
        if (notasalow_clock == 24999) begin  // 100MHz / 25000 = 4kHz
            notasalow_clock <= 0;
            clk_en <= 1;
        end else begin
            notasalow_clock <= notasalow_clock + 1;
            clk_en <= 0;
        end
    end
    
    always @(posedge clk) begin
        if (clk_en)
            digit_sel <= digit_sel + 1;
    end


    always @(*) begin
        case (digit_sel)
            2'd0: begin an = 4'b1110; 
            if(state == 3'd1 || state == 3'd3)
            current_digit = cntmsi; 
            else
            current_digit = cntmsd;  
            dp = 1;
            end
            2'd1: begin an = 4'b1101; 
            
            if(state == 3'd1 || state == 3'd3)
            current_digit = cnt10msi; 
            else
            current_digit = cnt10msd;  
            
            dp = 1;
            end
            2'd2: begin an = 4'b1011; 
            
            if(state == 3'd1 || state == 3'd3)
            current_digit = cntsi; 
            else
            current_digit = cntsd;  
              
            dp = 0;  
            end
            2'd3: begin an = 4'b0111; 
            
            if(state == 3'd1 || state == 3'd3)
            current_digit = cnt10si; 
            else
            current_digit = cnt10sd;  
              
            dp = 1;
            end
        endcase
    end
    
     always@(posedge slow_clk or posedge r)begin
        if(r)
            state <=3'b000;
        else 
            state<= next_state;
        end

    
    Ht7 decoder(
            .x(current_digit),
            .r(seg)
        );
    
    endmodule
