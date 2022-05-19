`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2022 12:11:49 AM
// Design Name: 
// Module Name: dmem
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

module dmem #(
   parameter Nloc,
   parameter Dbits,
   parameter initfile
)(
   input wire clock,
   input wire mem_wr,
   input wire [Nloc-1:0] mem_addr,
   input wire [Dbits-1:0] mem_writedata,
   output logic [Dbits-1:0] mem_readdata
   );

   logic [Dbits-1:0] mem [Nloc-1:0];
   initial $readmemh(initfile, mem, 0, Nloc-1);

   always_ff @(posedge clock)
      if(mem_wr)
         mem[mem_addr[$clog2(Nloc)+1:2]] <= mem_writedata;

   assign mem_readdata = mem[mem_addr[$clog2(Nloc)+1:2]];

endmodule
