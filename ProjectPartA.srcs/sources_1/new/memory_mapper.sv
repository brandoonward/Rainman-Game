`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/08/2022 11:39:05 AM
// Design Name: 
// Module Name: memory_mapper
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


module memory_mapper # (
    parameter wordsize = 32 )
    (
    input wire [wordsize-1:0] accel_val, keyb_char, smem_readdata, dmem_readdata, cpu_addr,
    input wire cpu_wr,
    output wire lights_wr, sound_wr, smem_wr, dmem_wr, display_wr,
    output wire [wordsize-1:0] cpu_readdata
    );
    
    assign cpu_readdata = (cpu_addr[17:16] == 2'b01) ? dmem_readdata :
                            (cpu_addr[17:16] == 2'b10) ? smem_readdata :
                            (cpu_addr[17:16] == 2'b11) ? ((cpu_addr[3:2] == 2'b01) ? accel_val :
                             (cpu_addr[3:2] == 2'b00) ? keyb_char : 32'b0) : 32'b0;
                            
    assign display_wr = (cpu_addr[17:16] == 2'b00 && cpu_wr) ? 1'b1:1'b0;
    assign dmem_wr = (cpu_addr[17:16] == 2'b01 && cpu_wr) ? 1'b1 : 1'b0;
    assign smem_wr = (cpu_addr[17:16] == 2'b10 && cpu_wr) ? 1'b1 : 1'b0;
    assign sound_wr = (cpu_addr[17:16] == 2'b11 && cpu_addr[3:2] == 2'b10 && cpu_wr) ? 1'b1 : 1'b0;
    assign lights_wr = (cpu_addr[17:16] == 2'b11 && cpu_addr[3:2] == 2'b11 && cpu_wr) ? 1'b1 : 1'b0;
endmodule
