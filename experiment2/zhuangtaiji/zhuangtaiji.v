module zhuangtaiji(x,z,clk,anjian,reset,q);
input x,clk,reset,anjian;
output z;
output [2:0]q;
reg [2:0]q;
reg z;
wire chudou;
debounce db(.clk(clk),.key_i(anjian),.key_o(chudou));
always @(posedge reset or posedge chudou)
begin
	if(reset) begin 
	z<=0;
	q<=0; 
	end
	else begin
	q[2]<=(q[2]&&~q[0]&&x)||(q[2]&&q[0]&&~x)||(q[1]&&q[0]&&~x);
	q[1]<=(q[1]&&~q[0]&&x)||(~q[2]&&~q[1]&&q[0]&&~x);
	q[0]<=x;
	z<=q[2]&&q[0]&&x;
	end
end
endmodule

/*module zhuangtaiji_tb;
reg x=0,clk=0,reset=0;
wire z;
zhuangtaiji z1(.x(x),.z(z),.clk(clk),.reset(reset));
initial begin 
	forever #50 clk<=~clk;
end
always 
begin 
	#2000 reset<=~reset;
	#50 reset<=~reset;
end
begin
initial begin #25 x=0;
end
always
begin
	#100 x=0;
	#100 x=0;
	#100 x=1;
	#100 x=0;
	#100 x=1;
	#100 x=0;
	#100 x=1;
	#100 x=1;
	#100 x=0;
	#100 x=1;
	#100 x=0;
	#100 x=1;
	#100 x=1;
	#100 x=1;
	#100 x=0;
	#100 x=0;
	#100 x=0;
	#100 x=1;
	#100 x=0;
	#100 x=1;
	#100 x=0;
	#100 x=1;
	#100 x=1;
	#100 x=0;
	#100 x=0;
end
end
endmodule */
