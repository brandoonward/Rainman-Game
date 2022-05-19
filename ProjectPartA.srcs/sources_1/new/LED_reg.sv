`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2022 11:09:55 AM
// Design Name: 
// Module Name: LED_reg
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

`default_nettype none


module LED_reg(
    input wire clk,
    input wire lights_wr,
    input wire [15:0] lights_val,
    output wire [15:0] LED
    );
    logic [31:0] LED_reg = 32'b0;
    assign LED = LED_reg;
    always_ff@ (posedge clk) begin
    
        LED_reg <= (lights_wr) ? lights_val : LED;

    end
endmodule