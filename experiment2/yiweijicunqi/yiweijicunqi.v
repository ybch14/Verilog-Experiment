module trigger(D,clk,reset,Q,nQ);
input D,clk,reset;
output Q,nQ;
reg Q,nQ;
always @(posedge reset or posedge clk)
begin
	if(reset) begin 
	Q<=0;nQ<=1;
	end
	else begin
	Q<=D;nQ<=~D;
	end
end
endmodule 
module jicunqi(x,reset,clk,anjian,q,z,last);
input x,reset,clk,anjian;
output [5:0]q;
output z;reg z;output last;reg last;
debounce db(.clk(clk),.key_i(anjian),.key_o(chudou));
trigger t1(.D(x),.clk(chudou),.reset(reset),.Q(q[0]),.nQ(n1));
trigger t2(.D(q[0]),.clk(chudou),.reset(reset),.Q(q[1]),.nQ(n2));
trigger t3(.D(q[1]),.clk(chudou),.reset(reset),.Q(q[2]),.nQ(n3));
trigger t4(.D(q[2]),.clk(chudou),.reset(reset),.Q(q[3]),.nQ(n4));
trigger t5(.D(q[3]),.clk(chudou),.reset(reset),.Q(q[4]),.nQ(n5));
trigger t6(.D(q[4]),.clk(chudou),.reset(reset),.Q(q[5]),.nQ(n6));
always @(posedge chudou or posedge reset)
begin
	if(reset) begin
	z<=0;last<=0;
	end
	else begin
	if((q==6'b010101||q==6'b110101)&&x==1) z<=1;
	else z<=0;
	last=x;
	end
end
endmodule

/*module jicunqi_tb;
reg x=0,reset=0,clk=0;
wire [5:0]q;
wire z;
jicunqi j1(.x(x),.reset(reset),.clk(clk),.q(q),.z(z));
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
endmodule*/
