`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/24/2022 12:22:18 PM
// Design Name: 
// Module Name: display_reg
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


module display_reg(
    input wire clk,
    input wire display_wr,
    input wire [31:0] display_val,
    output wire [31:0] disp
    );
    
    logic [31:0] display_reg = 32'b0;
    assign disp = display_reg;
    always_ff@ (posedge clk) begin
        display_reg <= (display_wr) ? display_val : disp;
    end
endmodule
