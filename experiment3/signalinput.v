module signalinput(input [1:0] testmode,
//00,01,10,11 mean four frequencies, 3125,6250,50,12500Hz
//ocntrol by SW1-SW0
input sysclk,
output sigin1);
reg [20:0] state;
reg [20:0] divide;
reg sigin;
assign sigin1=sigin;
initial begin
	sigin=0;
	state=21'b000000000000000000000;
	divide=21'b000000_1111_1010_0000000;
end
always @(testmode)
begin
	case(testmode[1:0])
	2'b00:divide=21'b000000_1111_1010_0000000;//3125Hz
	2'b01:divide=21'b0000000_1111_1010_000000;//6250Hz
	2'b10:divide=21'b1111_0100_0010_0100_00000;//50Hz
	2'b11:divide=21'b00000000_1111_1010_00000;//12500Hz
	endcase
end
always @(posedge sysclk)//divide the frequency by divide
begin
	if(state==0)
		sigin=~sigin;
	state=state+21'b0_00_0000_0000_0000_0000_10;
	if(state==divide)
		state=27'b000_0000_0000_0000_0000_0000_0000;
end
endmodule
