module UART_receiver(UART_RX,sysclk,RX_DATA,RX_STATUS);
input UART_RX;
input sysclk;
output [7:0]RX_DATA;
reg [7:0]RX_DATA;
output RX_STATUS;
reg RX_STATUS;

reg enable;
reg previous_enable;
reg [9:0]baud_rate_counter;
reg [4:0]time_center_counter;
reg [3:0]data_counter;
reg [4:0]status_counter;
reg [7:0]temp_data;
//set the first values
initial begin
	RX_DATA=8'b0;
	RX_STATUS=0;
	enable=0;
	previous_enable=0;
	baud_rate_counter=10'b0;
	time_center_counter=5'b0;
	data_counter=4'b0;
	temp_data=8'b0;
	status_counter=5'b0;
end
always @(posedge sysclk) begin
	previous_enable=enable;//record the status of the last clock period
	if(enable==0) begin
		if(UART_RX==0) begin
			enable=1;//find the beginning 0 and set enable to 1
			RX_STATUS=0;
		end
	end
	if(enable==1&&previous_enable==0) begin
		baud_rate_counter=0;
	end
	else begin
		baud_rate_counter=baud_rate_counter+10'b00000_00001;
		if(baud_rate_counter==652) begin //find a posedge of 153600Hz signal
			if(enable==1) begin
				time_center_counter=time_center_counter+5'b00001;
				if(time_center_counter==16) begin//find a posedge of 9600Hz
					data_counter=data_counter+4'b0001;
					time_center_counter=0;
				end
				if(data_counter==9) begin
					data_counter=0;
					enable=0;
					RX_STATUS=1;
				end
				if(time_center_counter==8&&data_counter!=0) begin
					temp_data[data_counter-1]=UART_RX;
				end
			end
			if(RX_STATUS==1) begin
				status_counter=status_counter+5'b00001;
				if(status_counter==16) begin
					RX_STATUS=0;
					status_counter=0;
				end
			end
			baud_rate_counter=0;
		end
	end
end
always @(posedge sysclk) begin
	if(RX_STATUS==1) begin
		RX_DATA=temp_data;
	end
end
endmodule

module UART_sender(sample_clk,TX_DATA,TX_EN,TX_STATUS,UART_TX);
input sample_clk;
input [7:0]TX_DATA;
input TX_EN;
output TX_STATUS;
output UART_TX;
reg UART_TX;

reg enable;
reg [8:0]temp_data;
reg [3:0]counter;
initial begin
	UART_TX<=1;
	enable<=0;
	temp_data<=7'b0;
	counter<=4'b0;
end
assign TX_STATUS=counter==0?1:0;
always @(posedge sample_clk) begin
	if(TX_EN==1) begin
		enable=1;
	end
	if(enable==1&&TX_EN==0) begin
		temp_data[8]<=1;
		temp_data[7:0]<=TX_DATA;
		counter<=1;
		UART_TX<=0;
		enable<=0;
	end
	else begin
	   if(counter==10)
	       counter<=0;
	   else if(counter!=0) begin
	       if(counter<10) begin
	           UART_TX=temp_data[counter-1];
	       end
	       counter<=counter+1;
	   end
	end
end
endmodule

module UART_control(RX_DATA,RX_STATUS,sysclk,TX_STATUS,TX_DATA,TX_EN);
input [7:0]RX_DATA;
input RX_STATUS;
input sysclk;
input TX_STATUS;
output [7:0]TX_DATA;
output TX_EN;
reg TX_EN;
reg receive_enable;//decide if the control mode have received a new data
reg [13:0]counter;

assign TX_DATA[7]=RX_DATA[7];
assign TX_DATA[6:0]=RX_DATA[7]?(~RX_DATA[6:0]):RX_DATA[6:0];
initial begin
	TX_EN=0;
	receive_enable=0;
	counter=13'b0;
end
always @(posedge sysclk) begin
	if(RX_STATUS==1) begin
		receive_enable=1;
	end
	else if(TX_STATUS==1&&receive_enable==1) begin
		receive_enable=0;
		TX_EN=1;
	end
	if(TX_EN==1) begin
		counter=counter+13'b000000_0000001;
		if(counter==11000) begin
			counter=0;
			TX_EN=0;
		end
	end
end
endmodule

module Baud_Rate_Generator(sysclk,baud_rate_clk);
input sysclk;
output baud_rate_clk;//153600Hz signal
reg baud_rate_clk;
reg [9:0]counter;
initial begin
	counter=10'b0;
	baud_rate_clk=0;
end
always @(posedge sysclk) begin
	counter=counter+10'b00000_00001;
	if(counter==326) begin
		baud_rate_clk=~baud_rate_clk;
		counter=0;
	end
end
endmodule

module sample_generator(baud_rate_clk,sample_clk);
input baud_rate_clk;
output sample_clk;//9600Hz signal
reg sample_clk;
reg [3:0]counter;
initial begin
	sample_clk=0;
	counter=4'b0000;
end
always @(posedge baud_rate_clk) begin
	counter=counter+4'b0001;
	if (counter==8) begin
		sample_clk=~sample_clk;
		counter=0;
	end
end
endmodule 

module UART(UART_RX,sysclk,UART_TX);
input UART_RX;
input sysclk;
output UART_TX;
wire [7:0]RX_DATA;
wire RX_STATUS;
wire [7:0]TX_DATA;
wire TX_STATUS;
wire TX_EN;
wire baud_rate_clk;
wire sample_clk;
UART_receiver ur1(UART_RX,sysclk,RX_DATA,RX_STATUS);
UART_control uc1(RX_DATA,RX_STATUS,sysclk,TX_STATUS,TX_DATA,TX_EN);
Baud_Rate_Generator brg1(sysclk,baud_rate_clk);
sample_generator sg1(baud_rate_clk,sample_clk);
UART_sender us1(sample_clk,TX_DATA,TX_EN,TX_STATUS,UART_TX);
endmodule

/*module UART_testbench;
reg UART_RX;
reg sysclk;
wire UART_TX;

wire [7:0]RX_DATA;
wire RX_STATUS;
wire [7:0]TX_DATA;
wire TX_STATUS;
wire TX_EN;
wire baud_rate_clk;
wire sample_clk;
UART_receiver ur1(UART_RX,sysclk,RX_DATA,RX_STATUS);
UART_control uc1(RX_DATA,RX_STATUS,sysclk,TX_STATUS,TX_DATA,TX_EN);
Baud_Rate_Generator brg1(sysclk,baud_rate_clk);
sample_generator sg1(baud_rate_clk,sample_clk);
UART_sender us1(sample_clk,TX_DATA,TX_EN,TX_STATUS,UART_TX);
initial begin
	forever #5 sysclk<=~sysclk;
end
initial begin
	sysclk<=0;
	UART_RX=1;
	#52083 UART_RX=0;
	#104166 UART_RX=1;
	#104166 UART_RX=0;
	#104166 UART_RX=1;
	#104166 UART_RX=0;
	#104166 UART_RX=1;
	#104166 UART_RX=0;
	#104166 UART_RX=1;
	#104166 UART_RX=0;
	#104166 UART_RX=1;
	#104166 UART_RX=0;
	#104166 UART_RX=1;
	#104166 UART_RX=1;
	#104166 UART_RX=0;
	#104166 UART_RX=1;
	#104166 UART_RX=0;
	#104166 UART_RX=0;
	#104166 UART_RX=1;
	#104166 UART_RX=1;
	#104166 UART_RX=1;
end
endmodule */