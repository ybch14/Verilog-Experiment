`timescale 1ns/1ns
module BCD7(din,dout);
input [3:0] din;
output [6:0] dout;
assign dout=(din==4'h0)?7'b111_1110:
            (din==4'h1)?7'b011_0000:
            (din==4'h2)?7'b110_1101:
            (din==4'h3)?7'b111_1001:
            (din==4'h4)?7'b011_0011:
            (din==4'h5)?7'b101_1011:
            (din==4'h6)?7'b101_1111:
            (din==4'h7)?7'b111_0000:
            (din==4'h8)?7'b111_1111:
            (din==4'h9)?7'b111_1011:
	    (din==4'hA)?7'b111_0111:
            (din==4'hB)?7'b001_1111:
            (din==4'hC)?7'b100_1110:
            (din==4'hD)?7'b011_1101:
            (din==4'hE)?7'b100_1111:
            (din==4'hF)?7'b100_0111:7'b0;
endmodule