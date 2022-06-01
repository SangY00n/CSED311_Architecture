`include "opcodes.v"

module PC (input reset, input clk, input [31:0] next_pc, output [31:0] current_pc);
  
  reg [31:0] pc;

  assign current_pc = pc;
  
  always @(posedge clk) begin
    if(reset) begin
      pc <= 32'b0;
    end
    else begin
      pc <= next_pc;
    end
  end
endmodule


module ControlUnit(input [6:0] part_of_inst,  // input : opcode
                    output is_jal,        // output 
                    output is_jalr,       // output
                    output branch,        // output
                    output mem_read,      // output
                    output mem_to_reg,    // output
                    output mem_write,     // output
                    output alu_src,       // output
                    output write_enable,     // output : RegWrite
                    output pc_to_reg,     // output
                    output is_ecall);      // output (ecall inst)


  assign is_jal=(part_of_inst==`JAL);
  assign is_jalr=(part_of_inst==`JALR);
  assign branch=(part_of_inst==`BRANCH);
  assign mem_read=(part_of_inst==`LOAD);
  assign mem_to_reg=(part_of_inst==`LOAD);
  assign mem_write=(part_of_inst==`STORE); 
  assign alu_src=(part_of_inst==`ARITHMETIC_IMM || part_of_inst==`LOAD || part_of_inst==`JALR || part_of_inst==`STORE);
  assign write_enable=(part_of_inst!=`STORE && part_of_inst!=`BRANCH);
  assign pc_to_reg=(part_of_inst==`JAL || part_of_inst==`JALR);

  assign is_ecall=(part_of_inst==`ECALL);

endmodule

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

module ALUControlUnit (input [31:0] part_of_inst, output [2:0] alu_op);
  wire [6:0] opcode;
  wire [2:0] func3;
  wire [6:0] func7;

  reg [2:0] op;

  assign alu_op = op;

  assign opcode = part_of_inst[6:0];
  assign func3 = part_of_inst[14:12];
  assign func7 = part_of_inst[31:25];

  always @(*) begin
    if (opcode==`ARITHMETIC) begin
      if (func7==`FUNCT7_SUB) begin // R-type
        op = `FUNCT_SUB;
      end
      else begin
        op = func3; 
      end
    end
    else if (opcode==`ARITHMETIC_IMM) begin // I-type 중 imm
      op = func3;
    end
    else if (opcode==`LOAD || opcode==`STORE || opcode==`JALR) begin
      op = `FUNCT_ADD;
    end
    else if (opcode==`BRANCH) begin
      op = `FUNCT_SUB;
    end
    else begin
      op = 3'b000; //
    end
  end


endmodule

module ALU (input [2:0] alu_op,
            input [31:0] alu_in_1,
            input [31:0] alu_in_2,
            input [2:0] funct3,
            output [31:0] alu_result,
            output alu_bcond);

  reg [31:0] result;
  reg bcond;

  assign alu_result = result;
  assign alu_bcond = bcond;

  always @(*) begin
    case(alu_op)
      `FUNCT_ADD: begin
        result = alu_in_1 + alu_in_2;
        bcond = 1'b0;
      end
      `FUNCT_SUB: begin
        result = alu_in_1 - alu_in_2;
        case(funct3)
          `FUNCT3_BEQ: begin
            bcond = (result == 32'b0);
          end
          `FUNCT3_BNE: begin
            bcond = (result != 32'b0);
          end
          `FUNCT3_BLT: begin
            bcond = (result[31] == 1'b1);
          end
          `FUNCT3_BGE: begin
            bcond = (result[31] != 1'b1);
          end
          default: bcond = 1'b0;
        endcase
      end
      `FUNCT_SLL: begin
        result = alu_in_1 << alu_in_2;
        bcond = 1'b0;
      end
      `FUNCT_XOR: begin
        result = alu_in_1 ^ alu_in_2;
        bcond = 1'b0;
      end
      `FUNCT_OR: begin
        result = alu_in_1 | alu_in_2;
        bcond = 1'b0;
      end
      `FUNCT_AND: begin
        result = alu_in_1 & alu_in_2;
        bcond = 1'b0;
      end
      `FUNCT_SRL: begin
        result = alu_in_1 >> alu_in_2;
        bcond = 1'b0;
      end

      default: begin
        result = 0;
        bcond = 1'b0;
      end

    endcase
      
  end


endmodule