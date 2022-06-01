// Submit this file with other files you created.
// Do not touch port declarations of the module 'CPU'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify the module.
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

module CPU(input reset,       // positive reset signal
           input clk,         // clock signal
           output is_halted); // Whehther to finish simulation
  /***** Wire declarations *****/

  // For PC
  wire [31:0] current_pc;
  wire [31:0] next_pc;
  wire change_pc;

  // For ControlUnit
  wire [6:0] opcode;
  wire pc_write_cond;
  wire pc_write;
  wire i_or_d;
  wire mem_write;
  wire mem_read;
  wire mem_to_reg;
  wire ir_write;
  wire pc_source;
  wire [1:0] ALUOp;
  wire [1:0] alu_src_B;
  wire alu_src_A;
  wire reg_write;
  wire is_ecall;

  wire [31:0] mem_addr;

  // For ALUControlUnit
  wire [2:0] alu_op;

  // For ALU
  wire [31:0] alu_in_1;
  wire [31:0] alu_in_2;
  wire [2:0] funct3;
  wire alu_bcond;
  wire [31:0] alu_result;

  // For RegisterFile
  wire [4:0] rs1;
  wire [4:0] rs2;
  wire [4:0] rd;
  wire [31:0] rd_din;
  wire [31:0] rs1_dout;
  wire [31:0] rs2_dout;

  // For Memory
  wire[31:0] dout;

  // For ImmGen
  wire [31:0] imm_gen_out;

  /***** Register declarations *****/
  reg [31:0] IR; // instruction register
  reg [31:0] MDR; // memory data register
  reg [31:0] A; // Read 1 data register
  reg [31:0] B; // Read 2 data register
  reg [31:0] ALUOut; // ALU output register
  // Do not modify and use registers declared above.


  // x17이 10이면 machine을 halting 처리 => rs1을 통해서 x17를 얻고 그 값이 10이면 halting
  assign is_halted = (is_ecall && (rs1_dout==10));
  assign rs1 = is_ecall ? 17 : IR[19:15];
  assign rs2 = IR[24:20];
  assign rd = IR[11:7];
  assign opcode = IR[6:0];

  assign rd_din = mem_to_reg ? MDR : ALUOut;

  assign funct3 = IR[14:12];

  assign alu_in_1 = (alu_src_A ? A : current_pc);
  assign alu_in_2 = ((alu_src_B==2'b00)?B:(alu_src_B==2'b01)?4:imm_gen_out);

  assign change_pc = (pc_write|(pc_write_cond & !alu_bcond));
  assign next_pc = pc_source ? ALUOut : alu_result;

  assign mem_addr = i_or_d ? ALUOut : current_pc;

  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .change_pc(change_pc),
    .next_pc(next_pc),     // input
    .current_pc(current_pc)   // output
  );

  // ---------- Register File ----------
  RegisterFile reg_file(
    .reset(reset),        // input
    .clk(clk),          // input
    .rs1(rs1),          // input
    .rs2(rs2),          // input
    .rd(rd),           // input
    .rd_din(rd_din),       // input
    .write_enable(reg_write),    // input
    .rs1_dout(rs1_dout),     // output
    .rs2_dout(rs2_dout)      // output
  );

  // ---------- Memory ----------
  Memory memory(
    .reset(reset),        // input
    .clk(clk),          // input
    .addr(mem_addr),         // input : address
    .din(B),          // input : write data
    .mem_read(mem_read),     // input
    .mem_write(mem_write),    // input
    .dout(dout)          // output
  );

  // ---------- Control Unit ----------
  ControlUnit ctrl_unit (
    .opcode(opcode),  // input
    .clk(clk),
    .reset(reset),
    .alu_bcond(alu_bcond),
    .pc_write_cond(pc_write_cond),        // output
    .pc_write(pc_write),       // output
    .i_or_d(i_or_d),        // output
    .mem_read(mem_read),      // output
    .mem_write(mem_write),     // output
    .mem_to_reg(mem_to_reg),    // output
    .ir_write(ir_write),
    .pc_source(pc_source),
    .ALUOp(ALUOp),
    .alu_src_B(alu_src_B),       // output
    .alu_src_A(alu_src_A),
    .reg_write(reg_write),     // output
    .is_ecall(is_ecall)       // output (ecall inst)
  );

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .part_of_inst(IR),  // input
    .imm_gen_out(imm_gen_out)    // output
  );

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit(
    .part_of_inst(IR),  // input
    .ALUOp(ALUOp),        // input (2bit)
    .alu_op(alu_op)         // output (3bit)
  );

  // ---------- ALU ----------
  ALU alu(
    .alu_op(alu_op),      // input
    .alu_in_1(alu_in_1),    // input  
    .alu_in_2(alu_in_2),    // input
    .funct3(funct3),
    .alu_result(alu_result),  // output
    .alu_bcond(alu_bcond)     // output
  );

  always @(posedge clk) begin
    if(reset) begin
      IR <= 0;
      MDR<=0;
      A<=0;
      B<=0;
      ALUOut<=0;
    end
    else begin
      if(ir_write && (IR!=dout)) begin
        IR <= dout;
      end
      if(MDR!=dout) begin
        MDR<=dout;
      // $display("%d", MDR);
      end
      if(A!=rs1_dout) begin
        A<=rs1_dout;
      end
      if(B!=rs2_dout) begin
        B<=rs2_dout;
      end
      if (ALUOut!=alu_result) begin
        ALUOut<=alu_result;
      end

    end


  end

  always @(posedge clk) begin
    // $display("%b", )
  end
endmodule
