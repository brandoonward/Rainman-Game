`timescale 1ns / 1ps
`default_nettype none


module memIO # (
    parameter wordsize = 32,
    parameter dmem_size,
    parameter dmem_init = "dmem_test.mem",
    parameter Nchars = 16,
    parameter smem_size,
    parameter smem_init = "smem_test.mem"
) (
    input wire clk,
    input wire cpu_wr,
    input wire [31:0] cpu_addr,
    input wire [wordsize-1:0] cpu_writedata,
    output wire [wordsize-1:0] cpu_readdata,
    input wire [$clog2(smem_size)-1:0] vga_addr,
    output wire [$clog2(Nchars)-1:0] vga_readdata, smem_before,
    
    input wire [31:0] keyb_char, accel_val,

    
    output wire [31:0] period, display_val,
    
    
    output wire [15:0] LED
    );
    
    wire dmem_wr, smem_wr, sound_wr, lights_wr, display_wr;
    
    wire [wordsize-1:0] dmem_readdata;
    wire [31:0] smem_readdata;
    assign smem_readdata = {{(wordsize-$clog2(Nchars)-1){1'b0}}, smem_before};    
    
    ram2port_module #(.Nloc(smem_size), .Dbits($clog2(Nchars)), .initfile(smem_init)) smem(.clock(clk), .wr(smem_wr), .addr1(cpu_addr[wordsize-1:2]),
                                                                    .addr2(vga_addr), .din(cpu_writedata), 
                                                                    .dout1(smem_before), .dout2(vga_readdata));
    
    //{wordsize-$clog(Nchars)'b0, smem_readdata}
    
    ram_module #(.Nloc(dmem_size), .Dbits(wordsize), .initfile(dmem_init)) dmem(.clock(clk), .wr(dmem_wr), 
                                .addr(cpu_addr[wordsize-1:2]), .din(cpu_writedata), .dout(dmem_readdata));
    
    
    
    

    LED_reg led(.clk(clk), .lights_wr(lights_wr), .lights_val(cpu_writedata[15:0]), .LED(LED));

    display_reg disp(.clk(clk), .display_wr(display_wr), .display_val(cpu_writedata), .disp(display_val));
    sound_reg sound_reg(.clk(clk), .sound_wr(sound_wr), .sound_val(cpu_writedata), .period(period));

    
    
    memory_mapper #(.wordsize(32)) memory_mapper(.accel_val(accel_val), 
                    .keyb_char(keyb_char), .smem_readdata(smem_readdata), .dmem_readdata(dmem_readdata),
                    .cpu_addr(cpu_addr), .cpu_wr(cpu_wr), .lights_wr(lights_wr), .sound_wr(sound_wr),
                    .smem_wr(smem_wr), .dmem_wr(dmem_wr), .display_wr(display_wr), .cpu_readdata(cpu_readdata));
    

    
endmodule