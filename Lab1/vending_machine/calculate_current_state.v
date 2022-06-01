
`include "vending_machine_def.v"
	

module calculate_current_state(i_input_coin,i_select_item,item_price,coin_value,current_total,
input_total, output_total, return_total,current_total_nxt,wait_time,o_return_coin,o_available_item,o_output_item);

	input [`kNumCoins-1:0] i_input_coin,o_return_coin;
	input [`kNumItems-1:0]	i_select_item;			
	input [31:0] item_price [`kNumItems-1:0];
	input [31:0] coin_value [`kNumCoins-1:0];
	input [`kTotalBits-1:0] current_total;
	input [31:0] wait_time;
	output reg [`kNumItems-1:0] o_available_item,o_output_item;
	output reg  [`kTotalBits-1:0] input_total, output_total, return_total,current_total_nxt;
	integer i;
	
	
	reg [`kTotalBits-1:0] current_money;
	//////
	
	
	initial begin
	   o_available_item = 0;
	   o_output_item = 0;
	   current_total_nxt = 0;
	   input_total = 0;
	   output_total = 0;
	   return_total = 0;
	   current_money = 0;
	end
	   
	

	// Combinational logic for the next states
	always @(*) begin
		// TODO: current_total_nxt
		// You don't have to worry about concurrent activations in each input vector (or array).
		// Calculate the next current_total state.
		if (i_input_coin) begin
		  if((current_total==0) || (current_total==1)) begin
		      current_total_nxt=1;
		  end
		end
		if ((i_select_item) && (current_total == 1)) begin
		  current_total_nxt=2;
		end
		
		if(current_total==2) begin
		  current_total_nxt = 1;
		end
		
		if (!wait_time) begin
		  current_total_nxt = 0;
		end
		
		//input_total = (i_input_coin[0] * coin_value[0]) + (i_input_coin[1] * coin_value[1]) + (i_input_coin[2] * coin_value[2]);
		//output_total = (o_output_item[0] * item_price[0]) + (o_output_item[1] * item_price[1]) + (o_output_item[2] * item_price[2]) + (o_output_item[3] * item_price[3]);
		//current_total_nxt = current_total + input_total - output_total;
		
		//return_total = (o_return_coin[0] * coin_value[0]) + (o_return_coin[1] * coin_value[1]) + (o_return_coin[2] * coin_value[2]);
	end

	
	
	// Combinational logic for the outputs
	always @(*) begin
		// TODO: o_available_item
		// TODO: o_output_item
		if (current_total == 0) begin
		  o_available_item=0;
		  o_output_item =0;
		  input_total=0;
		  return_total=0;
		  current_money=0;
        end
        
        if (current_total == 1) begin
            for(i=0;i<=2;i=i+1) begin
                input_total = input_total + (i_input_coin[i]*coin_value[i]);
                current_money = current_money + (i_input_coin[i]*coin_value[i]);
                return_total = current_money;
            end
            
            for(i=0;i<=3;i=i+1) begin
                if (current_money >=item_price[i]) begin
                    o_available_item[i] = 1;
                end
                else begin
                    o_available_item[i] = 0;
                end
            end
            
            
        end
        
        if (current_total == 2) begin
            for (i=0;i<=3;i=i+1) begin
                if (i_select_item[i] && o_available_item[i]) begin
                    o_output_item[i] = 1;
                    current_money = current_money - item_price[i];
                end
                else begin
                    o_output_item[i] = 0;
                end
            end
            
            return_total = current_money;
        end
                
	end
 
	


endmodule 