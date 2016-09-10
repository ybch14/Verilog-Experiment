`timescale 1ns/1ns
module tongbu_counter(clk,anjian,reset,shuchu);
input clk,anjian,reset;
output [6:0]shuchu;
reg [3:0]q_out;
wire [6:0]bcd7_out;
wire chudou;
debounce db(.clk(clk),.key_i(anjian),.key_o(chudou));
always @(posedge chudou or negedge reset)
begin
	if(~reset) begin 
		q_out[0]<=1'b0;
		q_out[1]<=1'b0;
		q_out[2]<=1'b0;
		q_out[3]<=1'b0;
	end
	else  begin 
                q_out[0]<=~q_out[0];
		if(q_out[0]==1'b1) q_out[1]<=~q_out[1];
		if(q_out[0]==1'b1&&q_out[1]==1'b1) q_out[2]<=~q_out[2];
		if(q_out[0]==1'b1&&q_out[1]==1'b1&&q_out[2]==1'b1) q_out[3]<=~q_out[3];
		if(q_out[0]==1'b1&&q_out[1]==1'b1&&q_out[2]==1'b1&&q_out[3]==1'b1) q_out=4'b0;
	end
end
BCD7 b1(.din(q_out),.dout(bcd7_out));
assign shuchu=~bcd7_out;
endmodule 
`timescale 1ns/1ns
module tongbu_counter_tb;
reg clk=1'b0,reset=1'b1,anjian=0;
wire [6:0]shuchu;
yibu_counter yibu1(.clk(clk),.anjian(anjian),.reset(reset),.shuchu(shuchu));
initial begin
	#50 reset=~reset;
	#1500 reset=~reset;
	#50 reset=~reset;
end
initial begin
	forever #25 clk=~clk;
end
initial begin
	forever #100 anjian=~anjian;
end
endmodule
	
