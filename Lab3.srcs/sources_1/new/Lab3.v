`timescale 1ns / 1ps

module ProgramCounter(next_pc, clk, pc);
    input [31:0]next_pc;
    input clk;
    output pc;
    reg[31:0] pc;
    
    initial begin
        pc = 100;
    end
    always @(posedge clk) begin
        pc = next_pc;
    end
endmodule


module InstructionMemory(pc, instOut);
    input [31:0]pc;
    output [31:0]instOut;
    reg[31:0] instOut;
    
    //32x64 memory
    reg[31:0] memory[0:63];
    
    initial begin
        //assign the instruction values in memory here (words 25 and 26)
        //lw $v0, 00($at)
        memory[25] = {6'b100011, 5'b00001, 5'b00010, 5'b00000, 5'b00000, 6'b000000};
        //lw $v1, 04($at)
        memory[26] = {6'b100011, 5'b00001, 5'b00011, 5'b00000, 5'b00000, 6'b000100};
    end
    always @(*) begin
        instOut = memory[pc[7:2]];
    end
endmodule


module PCAdder(pc, nextPc);
    input [31:0]pc;
    output [31:0]nextPc;
    reg[31:0] nextPc;
    
    always @(*) begin
        nextPc = pc + 4;
    end
endmodule


module IFIDPipelineRegister(instOut, clk, dinstOut);
    input[31:0] instOut;
    input clk;
    output[31:0] dinstOut;
    reg[31:0] dinstOut;
    
    always @(posedge clk) begin
        dinstOut = instOut;
    end
endmodule


module ControlUnit(op, func, wreg, m2reg, wmem, aluc, aluimm, regrt);
    input[5:0] op;
    input[5:0] func;
    output wreg;
    output m2reg;
    output wmem;
    output[3:0] aluc;
    output aluimm;
    output regrt;
    
    reg wreg;
    reg m2reg;
    reg wmem;
    reg[3:0] aluc;
    reg aluimm;
    reg regrt;
    
    always @(*) begin
        //do something
        case(op)
            6'b000000:
            begin
                //r type instruction
                case(func)
                    6'b100000:
                        begin
                            //add instruction
                            wreg = 1'b1;
                            m2reg = 1'b0;
                            wmem = 1'b0;
                            aluc = 4'b0010;
                            aluimm = 1'b0;
                            regrt = 1'b1;
                        end
                endcase
            end
            6'b100011:
            begin
                //load word instruction
                wreg = 1'b1;
                m2reg = 1'b1;
                wmem = 1'b0;
                aluc = 4'b0000;
                aluimm = 1'b1;
                regrt = 1'b0;
            end
        endcase
    end
endmodule 


module RegRTMux(rd, rt, regrt, destReg);
    input[4:0] rd, rt;
    input regrt;
    output[4:0] destReg;
    reg[4:0] destReg;
    
    always @(*) begin
        case(regrt)
            1'b0:
                begin
                   destReg = rd; 
                end
            1'b1:
                begin
                    destReg = rt;
                end
        endcase
    end
endmodule


module RegisterFile(rs, rt, qa, qb);
    input[4:0] rs;
    input[4:0] rt;
    output[31:0] qa;
    output[31:0] qb;
    reg[31:0] qa;
    reg[31:0] qb;
    
    //make a 32x32 register array
    reg[31:0] registers[31:0];
    
    //initialize all registers to 0
    integer r;
    initial begin
        for (r = 0; r <= 31; r = r + 1) begin
            registers[r] = 0;
        end
    end
    
    always @(*) begin
        qa = registers[rs];
        qb = registers[rt];
    end
endmodule


module ImmediateExtender(imm, imm32);
    input[15:0] imm;
    output[31:0] imm32;
    reg[31:0] imm32;
    
    always @(*) begin
        imm32 <= {{16{imm[15]}},{imm[15:0]}};
    end
endmodule


module IDEXEPipelineRegister(wreg, m2reg, wmem, aluc, aluimm, destReg, qa, qb, imm32, clk,
    ewreg, em2reg, ewmem, ealuc, ealuimm, edestReg, eqa, eqb, eimm32);
    input wreg;
    input m2reg;
    input wmem;
    input[3:0] aluc;
    input aluimm;
    input[4:0] destReg;
    input[31:0] qa;
    input[31:0] qb;
    input[31:0] imm32;
    input clk;
    
    output ewreg;
    output em2reg;
    output ewmem;
    output[3:0] ealuc;
    output ealuimm;
    output[4:0] edestReg;
    output[31:0] eqa;
    output[31:0] eqb;
    output[31:0] eimm32;
    reg ewreg;
    reg em2reg;
    reg ewmem;
    reg[3:0] ealuc;
    reg ealuimm;
    reg[4:0] edestReg;
    reg[31:0] eqa;
    reg[31:0] eqb;
    reg[31:0] eimm32;
    
    always @(posedge clk) begin
        ewreg = wreg;
        em2reg = m2reg;
        ewmem = wmem;
        ealuc = aluc;
        ealuimm = aluimm;
        edestReg = destReg;
        eqa = qa;
        eqb = qb;
        eimm32 = imm32;
    end
endmodule


module Datapath(clk, pc, dinstOut, ewreg, em2reg , ewmem, ealuc, ealuimm, edestReg, eqa, eqb, eimm32);
    input clk;
    output[31:0] pc;
    output dinstOut;
    output ewreg;
    output em2reg;
    output ewmem;
    output[3:0] ealuc;
    output ealuimm;
    output[4:0] edestReg;
    output[31:0] eqa;
    output[31:0] eqb;
    output[31:0] eimm32;
    
    wire[31:0] pc;
    wire[31:0] next_pc;
    wire[31:0] instOut;
    wire[31:0] dinstOut;
    wire wreg;
    wire m2reg;
    wire wmem;
    wire[3:0] aluc;
    wire aluimm;
    wire regrt;
    wire[4:0] destReg;
    wire[31:0] qa;
    wire[31:0] qb;
    wire[31:0] imm32;
    
    //outputs for id/exe pipeline register
    wire ewreg;
    wire em2reg;
    wire ewmem;
    wire[3:0] ealuc;
    wire ealuimm;
    wire[4:0] edestReg;
    wire[31:0] eqa;
    wire[31:0] eqb;
    wire[31:0] eimm32;
    
    PCAdder pcAdder(pc, next_pc);
    
    ProgramCounter programCounter(next_pc, clk, pc);
    
    InstructionMemory instructionMemory(pc, instOut);
    
    IFIDPipelineRegister ifIdPipelineRegister(instOut, clk, dinstOut);
    
    ControlUnit controlUnit(dinstOut[31:26], dinstOut[5:0], wreg, m2reg, wmem, aluc, aluimm, regrt);
    
    RegRTMux regRTMux(dinstOut[15:11], dinstOut[20:16], regrt, destReg);
    
    RegisterFile registerFile(dinstOut[25:21], dinstOut[20:16], qa, qb);
    
    ImmediateExtender immediateExtender(dinstOut[15:0],imm32);
    
    IDEXEPipelineRegister idExePipelineRegister(wreg, m2reg, wmem, aluc, aluimm, destReg, qa, qb, imm32, clk,
        ewreg, em2reg, ewmem, ealuc, ealuimm, edestReg, eqa, eqb, eimm32);    
    
endmodule