`include "opcodes.v"

module ImmediateGenerator(input [31:0] part_of_inst,
                          output [31:0] imm_gen_out);

  wire [6:0] opcode = part_of_inst[6:0];
  reg [31:0] imm_gen;

  assign imm_gen_out = imm_gen;

  always @(*) begin
    if(opcode==`ARITHMETIC_IMM || opcode==`LOAD || opcode==`JALR) begin // I-type
      imm_gen = {{21{part_of_inst[31]}}, part_of_inst[30:20]};
    end

    else if(opcode==`STORE) begin // S-type
      imm_gen = {{21{part_of_inst[31]}}, part_of_inst[30:25], part_of_inst[11:7]};
    end

    else if(opcode==`BRANCH) begin // B-type
      imm_gen = {{20{part_of_inst[31]}}, part_of_inst[7], part_of_inst[30:25], part_of_inst[11:8], 1'b0};
    end

    else if(opcode==`JAL) begin // J-type
      imm_gen = {{12{part_of_inst[31]}}, part_of_inst[19:12], part_of_inst[20], part_of_inst[30:25], part_of_inst[24:21], 1'b0};
    end
    else begin
      imm_gen = 32'b0;
    end

  end


endmodule