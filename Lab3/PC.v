module PC (input reset,
            input clk,
            input change_pc,
            input [31:0] next_pc,
            output [31:0] current_pc);
  
  reg [31:0] pc;

  assign current_pc = pc;
  
  always @(posedge clk) begin
    if(reset) begin
      pc <= 32'b0;
    end
    else begin
        if(change_pc) begin
            pc <= next_pc;
        end
    end
  end
endmodule