`timescale 1ns / 1ps

module testbench();
    reg clk;
    
    wire[31:0] pc;
    wire[31:0] dinstOut;
    wire ewreg;
    wire em2reg;
    wire ewmem;
    wire[3:0] ealuc;
    wire ealuimm;
    wire[4:0] edestReg;
    wire[31:0] eqa;
    wire[31:0] eqb;
    wire[31:0] eimm32;
    
    initial begin
        clk <= 1'b0;
    end
    
    Datapath datapath(clk, pc, dinstOut, ewreg, em2reg, ewmem, ealuc, ealuimm, edestReg, eqa, eqb, eimm32);
    
    always begin
        #10;
        clk = ~clk;
    end
    
endmodule
