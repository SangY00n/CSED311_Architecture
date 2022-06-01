`include "opcodes.v"

module ALUControlUnit (input [31:0] part_of_inst, input[1:0] ALUOp, output [2:0] alu_op);
  wire [6:0] opcode;
  wire [2:0] func3;
  wire [6:0] func7;

  reg [2:0] op;

  assign alu_op = op;

  assign opcode = part_of_inst[6:0];
  assign func3 = part_of_inst[14:12];
  assign func7 = part_of_inst[31:25];

  always @(*) begin
    if(ALUOp==2'b00) begin // add
        op=`FUNCT_ADD;
    end
    else if(ALUOp==2'b01) begin // sub <- branch 일 때 커버
        op=`FUNCT_SUB;
    end
    else begin // ALUOp==2'b10 일 때를 모두 커버
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
        // else if (opcode==`LOAD || opcode==`STORE || opcode==`JALR) begin
        // op = `FUNCT_ADD;
        // end
        // else if (opcode==`BRANCH) begin
        // op = `FUNCT_SUB;
        // end
        else begin
            op = 3'b000; //
        end
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