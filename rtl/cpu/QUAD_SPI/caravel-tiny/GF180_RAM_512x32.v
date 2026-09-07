`timescale 1ps/1ps
`default_nettype none

/*
	512 Words SRAM with byte enable
	Built out of 4 GF180_512x8 banks.
*/
module GF180_RAM_512x32 (
	CLK,
	CEN,
	GWEN,
	WEN,
	A,
	D,
	Q,
	VDD,
	VSS
);

	input           CLK;
	input           CEN;    // Chip Enable (Active Low)
	input           GWEN;   // Global Write Enable (Active Low)
	input   [3:0]  	WEN;    // Byte WEN (Active Low)
	input   [8:0]   A;
	input   [31:0] 	D;
	output	[31:0]	Q;
	inout		    VDD;
	inout		    VSS;

	wire [31: 0] Q0, Q1;

	wire sel_0 = 1;
	//wire sel_1 =   A[9];

	wire gwen_0 = ~(sel_0 & ~GWEN);
	//wire gwen_1 = ~(sel_1 & ~GWEN);

	wire [7:0] wen_0 = {8{WEN[0]}};
	wire [7:0] wen_1 = {8{WEN[1]}};
	wire [7:0] wen_2 = {8{WEN[2]}};
	wire [7:0] wen_3 = {8{WEN[3]}};

	// These SRAMS are not NEEDED IF all we are doing is running firmware used when RUNNING Firmware from an EXTERNAL SPIFLASH

	`ifdef ALTERA_RESERVED_QIS
		localparam MEM_DEPTH = 512;
		localparam MEM_WIDTH = 8;

		// Altera on-board (De10lite FPGA optimized) versions with byte level `wren` instead of bit level `wen` 
		altera_ram #(.MEM_WORDS(512), .MEM_WIDTH(8)) RAM00 (.clock(CLK), .wren(|wen_0), .address(A[8:0]), .data(D[ 7: 0]), .q(Q0[ 7: 0]));
		altera_ram #(.MEM_WORDS(512), .MEM_WIDTH(8)) RAM01 (.clock(CLK), .wren(|wen_1), .address(A[8:0]), .data(D[ 15: 8]), .q(Q0[ 15: 8]));
		altera_ram #(.MEM_WORDS(512), .MEM_WIDTH(8)) RAM02 (.clock(CLK), .wren(|wen_2), .address(A[8:0]), .data(D[ 23: 16]), .q(Q0[ 23: 16]));
		altera_ram #(.MEM_WORDS(512), .MEM_WIDTH(8)) RAM03 (.clock(CLK), .wren(|wen_3), .address(A[8:0]), .data(D[ 31: 24]), .q(Q0[ 31: 24]));
	`else
		gf180_ram_512x8_wrapper RAM00 ( .CLK(CLK), .CEN(CEN), .GWEN(gwen_0), .WEN(wen_0), .A(A[8:0]), .D(D[ 7: 0]), .Q(Q0[ 7: 0]) );
		gf180_ram_512x8_wrapper RAM01 ( .CLK(CLK), .CEN(CEN), .GWEN(gwen_0), .WEN(wen_1), .A(A[8:0]), .D(D[15: 8]), .Q(Q0[15: 8]) );
		gf180_ram_512x8_wrapper RAM02 ( .CLK(CLK), .CEN(CEN), .GWEN(gwen_0), .WEN(wen_2), .A(A[8:0]), .D(D[23:16]), .Q(Q0[23:16]) );
		gf180_ram_512x8_wrapper RAM03 ( .CLK(CLK), .CEN(CEN), .GWEN(gwen_0), .WEN(wen_3), .A(A[8:0]), .D(D[31:24]), .Q(Q0[31:24]) );
	`endif

	assign Q = Q0;//A[9] ? Q1 : Q0;

endmodule
