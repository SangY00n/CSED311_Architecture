module PC (input reset,
            input clk,
            input [31:0] next_pc,
            input pc_write,
            input is_not_cache_stall,
            output [31:0] current_pc);
  
  reg [31:0] pc;

  assign current_pc = pc;
  


  always @(posedge clk) begin
    if(reset) begin
      pc <= 32'b0;
    end
    else if(pc_write&is_not_cache_stall) begin
      pc <= next_pc;
    end
    else begin
      // pc <= pc;
    end
  end
endmodule

module Adder (input [31:0] input1, input [31:0] input2, output [31:0] output_adder);
    assign output_adder=input1+input2;
endmodule