module frequency2(sigin,sysclk,modelcontrol,highfreq,cathodes,AN);
input sigin;
input sysclk;
input modelcontrol;
output highfreq;
//output control_ref;
output [7:0]cathodes;
output [3:0]AN;
reg [3:0]AN;
reg clk_one_hz;
reg clk_one_khz;
reg [27:0] clk_one_counter;
reg [27:0] clk_one_divide;
reg [17:0] clk_onek_counter;
reg [17:0] clk_onek_divide;
reg test_signal;
reg [3:0]test_signal_counter;
reg [3:0]test_signal_divide;
reg sigin_final;
reg control_signal;
reg [3:0] number4;
reg [3:0] number3;
reg [3:0] number2;
reg [3:0] number1;
reg [3:0] savenum4;
reg [3:0] savenum3;
reg [3:0] savenum2;
reg [3:0] savenum1;
reg [3:0]save;
wire [7:0]digi;
//reg control_ref;
assign highfreq=modelcontrol;
initial begin
	clk_one_hz=0;
	clk_one_khz=0;
	clk_one_counter=27'b000000000000000000000000000;
	clk_one_divide=27'b101111101011110000100000000;
	clk_onek_counter=17'b00000000000000000;
	clk_onek_divide=17'b11000011010100000;
	test_signal=0;
	test_signal_counter=4'b0000;
	test_signal_divide=4'b1010;	
	sigin_final=0;
	control_signal=0;
	number4=4'b0000;
	number3=4'b0000;
	number2=4'b0000;
	number1=4'b0000;
	savenum4=4'b0000;
	savenum3=4'b0000;
	savenum2=4'b0000;
	savenum1=4'b0000;
	AN[0]=1;
	AN[1]=1;
	AN[2]=1;
	AN[3]=0;
	save=4'b0000;
	//control_ref=0;
end
//generate a 1hz signal
always @(posedge sysclk)
begin
	if(clk_one_counter==0) begin
	clk_one_hz=~clk_one_hz;
	end
	clk_one_counter=clk_one_counter+27'b000000000000000000000000010;
	if(clk_one_counter==clk_one_divide) begin
	clk_one_counter=27'b000000000000000000000000000;
	end
end
//generate a 1khz signal
always @(posedge sysclk)
begin
	if(clk_onek_counter==0) begin
	clk_one_khz=~clk_one_khz;
	end
	clk_onek_counter=clk_onek_counter+17'b00000000000000010;
	if(clk_onek_counter==clk_onek_divide) begin
	clk_onek_counter=17'b00000000000000000;
	end
end
//divide frequency depend on modelcontrol
always @(posedge sigin)
begin
		if(test_signal_counter==0) begin
			test_signal=~test_signal;
		end
		test_signal_counter=test_signal_counter+4'b0010;
		if(test_signal_counter==test_signal_divide) begin
			test_signal_counter=4'b0000;
		end
end
always @(sysclk)
begin
    if(modelcontrol==1) sigin_final=test_signal;
    else sigin_final=sigin;
end
//generate the control signal
always @(posedge clk_one_hz)
begin
	control_signal=~control_signal;
	/*if(control_signal==1)
	      control_ref=1;
	else 
	      control_ref=0;*/
end
//dec_counter module
always @(posedge sigin_final)
begin
	if(control_signal==0) begin
		number4=4'b0000;
		number3=4'b0000;
		number2=4'b0000;
		number1=4'b0000;
	end
	else if(control_signal==1) begin
		number1=number1+4'b0001;
		if(number1==4'b1010) begin
			number2=number2+4'b0001;
			number1=4'b0000;
		end
		if(number2==4'b1010) begin
                	number3=number3+4'b0001;
                	number2=4'b0000;
		end
                if(number3==4'b1010) begin
                        number4=number4+4'b0001;
                        number3=4'b0000;
                end
	end
end
//save module
always @(negedge control_signal)
begin
	savenum4=number4;
	savenum3=number3;
 	savenum2=number2;
	savenum1=number1;
end
//display module
always @(posedge clk_one_khz)
begin
	if(AN==4'b1110) begin
		AN=4'b1101;
		save=savenum3;
	end
	else if(AN==4'b1101) begin
		AN=4'b1011;
		save=savenum2;
	end
	else if(AN==4'b1011) begin
		AN=4'b0111;
		save=savenum1;
	end
	else if(AN==4'b0111) begin
		AN=4'b1110;
		save=savenum4;
	end
	else AN=4'b1110;
end
BCD7 bcd7(save,digi);
assign cathodes=~digi;
endmodule

module test(input [1:0] testmode,input sysclk,input modelcontrol,
output highfreq,output [7:0]cathodes,output [3:0]test_AN);
wire sigin;
signalinput signalin(testmode,sysclk,sigin);
frequency2 freq(sigin,sysclk,modelcontrol,highfreq,cathodes,test_AN);
endmodule
/*
module testbench;
reg [1:0] testmode;
reg sysclk;
reg modelcontrol;
wire highfreq;
wire [7:0] cathodes;
wire [3:0]AN;
test t1(testmode,sysclk,modelcontrol,highfreq,cathodes,AN);
initial begin
	testmode<=2'b00;
	sysclk<=0;
	modelcontrol<=0;
end
initial begin 
	forever #5 sysclk<=~sysclk;
end
endmodule*/
