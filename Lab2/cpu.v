// Submit this file with other files you created.
// Do not touch port declarations of the module 'CPU'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify the module.
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

`include "opcodes.v"

module CPU(input reset,       // positive reset signal
           input clk,         // clock signal
           output is_halted); // Whehther to finish simulation
  /***** Wire declarations *****/
  
  // For RegisterFile
  wire [4:0] rs1;
  wire [4:0] rs2;
  wire [4:0] rd;
  wire [6:0] opcode;

  wire [31:0] rd_din;
  wire [31:0] rs1_dout;
  wire [31:0] rs2_dout;

  // For Data memory
  wire [31:0] dmem_dout;


  // For imm_gen
  wire [31:0] imm_gen_out;

  wire is_jal;
  wire is_jalr;
  wire branch;
  wire mem_read;
  wire mem_to_reg;
  wire mem_write;
  wire alu_src;
  wire write_enable; // == RegWrite
  wire pc_to_reg;
  wire is_ecall;
  wire x17_is_10;

  // For ALUControlUnit
  wire [2:0] alu_op;

  // For ALU
  wire [31:0] alu_in_2; // rs2 or imm. => mux로 결정
  wire [31:0] alu_result;
  wire alu_bcond;
  wire [2:0] funct3;

  // For calculating next_pc value
  wire pc_src1;
  wire pc_src2;

  // reg였다가 wire로 바꿈
  wire [31:0] current_pc; // wire여도 될 것 같음. PC에서 output으로 받아옴.
  wire [31:0] instr; // register로 선언해야 할까? wire여도 될 것 같음. instmem에서 dout으로 받아오니까. wire로 바꿈.
  wire [31:0] next_pc;

  /***** Register declarations *****/
  

  


  // split instr to rs1, rs2, rd, opcode
  assign rs1 = instr[19:15];
  assign rs2 = instr[24:20];
  assign rd = instr[11:7];
  assign opcode = instr[6:0];

  // assignment 모음
  assign is_halted = (is_ecall && x17_is_10);
  
  assign rd_din = pc_to_reg ? (current_pc + 4) : (mem_to_reg ? dmem_dout : alu_result);
  // assign rd_din = pc_to_reg ? 

  assign alu_in_2 = (alu_src ? imm_gen_out : rs2_dout);

  assign funct3 = instr[14:12];

  // next_pc 계산
  assign pc_src1 = ( (branch & alu_bcond) | is_jal );
  assign pc_src2 = is_jalr;
  assign next_pc = pc_src2 ? alu_result : (pc_src1 ? (current_pc + imm_gen_out) : (current_pc + 4));

  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .next_pc(next_pc),     // input
    .current_pc(current_pc)   // output
  );
  
  // ---------- Instruction Memory ----------
  InstMemory imem(
    .reset(reset),   // input
    .clk(clk),     // input
    .addr(current_pc),    // input
    .dout(instr)     // output
  );

  // ---------- Register File ----------
  RegisterFile reg_file (
    .reset (reset),        // input
    .clk (clk),          // input
    .rs1 (rs1),          // input
    .rs2 (rs2),          // input
    .rd (rd),           // input
    .rd_din (rd_din),       // input : Write data
    .write_enable (write_enable),    // input
    .rs1_dout (rs1_dout),     // output
    .rs2_dout (rs2_dout),      // output
    .x17_is_10 (x17_is_10) // output
  );


  // ---------- Control Unit ----------
  ControlUnit ctrl_unit (
    .part_of_inst(opcode),  // input
    .is_jal(is_jal),        // output
    .is_jalr(is_jalr),       // output
    .branch(branch),        // output
    .mem_read(mem_read),      // output
    .mem_to_reg(mem_to_reg),    // output
    .mem_write(mem_write),     // output
    .alu_src(alu_src),       // output
    .write_enable(write_enable),     // output : RegWrite
    .pc_to_reg(pc_to_reg),     // output
    .is_ecall(is_ecall)       // output (ecall inst)
  );

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .part_of_inst(instr),  // input
    .imm_gen_out(imm_gen_out)    // output
  );

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit (
    .part_of_inst(instr),  // input
    .alu_op(alu_op)         // output
  );

  // ---------- ALU ----------
  ALU alu (
    .alu_op(alu_op),      // input : ALUOp
    .alu_in_1(rs1_dout),    // input  : rs1
    .alu_in_2(alu_in_2),    // input  : rs2 or imm. => mux로 결정
    .funct3(funct3), // input : For bcond
    .alu_result(alu_result),  // output : 여러군데로 퍼짐. mem에서 data를 읽기위한 addr로 쓰이거나, register에 write할 값으로 쓰이거나, pc에 더하는 값으로 쓰임
    .alu_bcond(alu_bcond)     // output : AND 연산자로 연결되어 Branch signal과 AND 연산
  );

  // ---------- Data Memory ----------
  DataMemory dmem(
    .reset (reset),      // input
    .clk (clk),        // input
    .addr (alu_result),       // input
    .din (rs2_dout),        // input
    .mem_read (mem_read),   // input
    .mem_write (mem_write),  // input
    .dout (dmem_dout)        // output
  );


  // For debugging
  always @(posedge clk) begin
    // $display("%b", )
  end
endmodule

