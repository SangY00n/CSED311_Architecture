`include "vending_machine_def.v"

	

module check_time_and_coin(i_input_coin,i_select_item,clk,reset_n,wait_time,o_return_coin, i_trigger_return);
	input clk;
	input reset_n;
	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0]	i_select_item;
	output reg  [`kNumCoins-1:0] o_return_coin;
	output reg [31:0] wait_time;
    input i_trigger_return;

    reg [31:0] moneySum;
    
    reg [31:0] temp_wait_time;

	// initiate values
	initial begin
		// TODO: initiate values
		temp_wait_time = `kWaitTime;
		moneySum=0;
	end

//
    always @(i_trigger_return) begin
        if(i_trigger_return == 1) begin
            temp_wait_time =0;
        end
    end


	// update coin return time
	always @(i_input_coin, i_select_item) begin
		// TODO: update coin return time
		
		if(i_input_coin[0]) begin
		  temp_wait_time = `kWaitTime;
		  moneySum = moneySum + 100;		  
		end
		if(i_input_coin[1]) begin
		  temp_wait_time = `kWaitTime;
		  moneySum = moneySum + 500;		  
		end
		if(i_input_coin[2]) begin
		  temp_wait_time = `kWaitTime;
		  moneySum = moneySum + 1000;		  
		end
		
		if(i_select_item) begin
		temp_wait_time = `kWaitTime;
            if(i_select_item[0]) begin
              if(moneySum>=400) begin
                  moneySum=moneySum-400;
              end
            end
            if(i_select_item[1]) begin
              if(moneySum>=500) begin
                  moneySum=moneySum-500;
              end
            end
            if(i_select_item[2]) begin
              if(moneySum>=1000) begin
                  moneySum=moneySum-1000;
              end
            end
            if(i_select_item[3]) begin
              if(moneySum>=2000) begin
                  moneySum=moneySum-2000;
              end
            end
		      		  
		end
	end

	always @(*) begin
		// TODO: o_return_coin
        if(temp_wait_time==0) begin
            if(moneySum&&(moneySum<0)) begin
                o_return_coin = 3'b001;
                moneySum=moneySum-100;
            end
        end
        
        else begin
            o_return_coin = 3'b000;
        end
	end

	always @(posedge clk ) begin
		if (!reset_n) begin
		// TODO: reset all states.
		  moneySum <= 0;
		  temp_wait_time <= `kWaitTime;
		end
		else begin
		// TODO: update all states.
		  
		  if(temp_wait_time > 0) begin
		      temp_wait_time <= temp_wait_time - 1;
		      wait_time <= temp_wait_time;
		  end
		  else begin
		      temp_wait_time <= 0;
		      wait_time <= 0;
		  end
		end
	end
endmodule 