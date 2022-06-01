`include "alu_func.v"

module ALU #(parameter data_width = 16) (
	input [data_width - 1 : 0] A, 
	input [data_width - 1 : 0] B, 
	input [3 : 0] FuncCode,
       	output reg [data_width - 1: 0] C,
       	output reg OverflowFlag);
// Do not use delay in your implementation.

// You can declare any variables as needed.
/*
	YOUR VARIABLE DECLARATION...
*/

initial begin
	C = 0;
	OverflowFlag = 0;
end   	

// TODO: You should implement the functionality of ALU!
// (HINT: Use 'always @(...) begin ... end')
/*
	YOUR ALU FUNCTIONALITY IMPLEMENTATION...
*/

always @(*) begin
	case (FuncCode)
		`FUNC_ADD: C = A + B;
		`FUNC_SUB: C = A - B;
		`FUNC_ID: C = A;
		`FUNC_NOT: C = ~A;
		`FUNC_AND: C = A & B;
		`FUNC_OR: C = A | B;
		`FUNC_NAND: C = ~(A & B);
		`FUNC_NOR: C = ~(A | B);
		`FUNC_XOR: C = (A ^ B);
		`FUNC_XNOR: C = ~(A ^ B);
		`FUNC_LLS: C = A << 1;
		`FUNC_LRS: C = A >> 1;
		`FUNC_ALS: C = (A <<< 1);
		`FUNC_ARS: C = (A >>> 1) | (A[15] << 15);
		`FUNC_TCP: C = ~A + 1;
		`FUNC_ZERO: C = 0;
		default: C = 0;
	endcase
	if (FuncCode == `FUNC_ADD)
		OverflowFlag = ((A[15]==B[15])&&(A[15]!=C[15]));
	else if (FuncCode == `FUNC_SUB)
		OverflowFlag = ((A[15]!=B[15])&&(A[15]!=C[15]));
	else
		OverflowFlag = 0;
end

endmodule

