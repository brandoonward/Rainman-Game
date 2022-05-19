//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2022 11:09:55 AM
// Design Name: 
// Module Name: sound_reg
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


`timescale 1ns / 1ps
`default_nettype none


module sound_reg(
    input wire clk,
    input wire sound_wr,
    input wire [31:0] sound_val,
    output wire [31:0] period
    );
    logic [31:0] period_reg = 32'b0;
    assign period = period_reg;
    always_ff @(posedge clk) begin
        period_reg <= (sound_wr) ? sound_val : period;
    end
    
endmodule