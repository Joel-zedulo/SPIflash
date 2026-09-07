`timescale 1ns/1ns

module spi_slave (
	input		sys_clk,	// System clock (i needed this to handle mode 0 shift logic bfore first sck edge)
	input		bit_order_lsb_i,// Most SPI implementations require MSB-first transfer, (value of 1'b0)
	input	[1:0]	timing_mode_i,	// SPI mode select based on CPOL & CPHA
	input	[2:0]	xfer_mode_i,	// Std:1 / Dual:2 / Quad:3 / Quad_ddr:4

	input	[7:0]	byte_i,		// The byte to be sent to the master during the next transaction
	output reg [7:0] byte_o,	// The last byte  recieved from the connected master

	output reg	byte_sent,	// Pulses high when the final bit of byte_i is sent
	output reg	byte_received,	// Pulses high when the final bit of byte_o is received

// Standard data lines
	input		sck,		// SPI clock from master
	input		cs_n,		// Active-low chip select

// SPI data lines for implementations where tri-stating and transfer mode switching happen often
	input		io0_i,		// STD:MOSI
	input		io1_i,
	input		io2_i,
	input		io3_i,

	output		io0_o,
	output		io1_o,		// STD:MISO
	output		io2_o,
	output		io3_o,
	output	[3:0]	oe
);
//	SPI Timing Modes
	localparam TIMING_MODE_0 = 0;
	localparam TIMING_MODE_1 = 1;
	localparam TIMING_MODE_2 = 2;
	localparam TIMING_MODE_3 = 3;

//	SPI Xfer Modes
	localparam STD_XFER      = 1;
	localparam DUAL_XFER     = 2;
	localparam QUAD_XFER     = 3;
	localparam QUAD_DDR_XFER = 4;

//	SPI bitrate
	localparam SINGLE_BITRATE = 3'd1;
	localparam DUAL_BITRATE   = 3'd2;
	localparam QUAD_BITRATE   = 3'd4;

	localparam logic [1:0] cs_n_dc = 2'd1; // number of EXTRA samples used to debounce cs_n if 0 cs_n and cs_n_prev[0] are compared

//	Bit-shifting order setup (the order in which bits in each byte are to be sent)
	wire [2:0] start_index, index_diff, stop_index;
	wire [2:0] bitrate;

// SPI Device's I/O buffers
	reg  [7:0] shift_in = 0;
	wire [3:0] shift_in_buf;
	reg  [7:0] shift_out;
	reg  [3:0] shift_out_buf;
	reg  [2:0] input_bit_index;
	reg  [2:0] output_bit_index;

// SPI Device status flags
	reg preload_done = 1;

	reg [cs_n_dc:0] cs_n_prev = {cs_n_dc+1{1'b1}};
	reg cs_n_trash = 1'b1;
	reg sck_prev = 1'b0;

	wire cs_n_stable_high;
	wire cs_n_stable_low;

	wire sck_rising;
	wire sck_falling;

	reg sck_r_flag = 1'b0;
	reg sck_f_flag = 1'b0;

// DATA lines
	reg io0_out, io1_out, io2_out, io3_out;

	reg [3:0] oe_buf = 4'b0;

//	assign {io3_o, io2_o, io1_o, io0_o} = (bit_order_lsb) ? shift_out[output_bit_index +: bitrate] : shift_out[output_bit_index -: bitrate];


	assign io0_o = io0_out;
	assign io1_o = io1_out;
	assign io2_o = io2_out;
	assign io3_o = io3_out;

// Flexible bit shifting
	assign shift_in_buf = {io3_i, io2_i, io1_i, io0_i};
//	assign {io3_o, io2_o, io1_o, io0_o} = shift_out_buf;

//	always @(*) begin
//		shift_in_buf = (bit_order_lsb_i) ? shift_in[input_bit_index +: bitrate] : shift_in[input_bit_index -: bitrate];

//		shift_out_buf = (bit_order_lsb_i) ? shift_out[(output_bit_index + bitrate) : output_bit_index] : shift_out[output_bit_index : (output_bit_index - bitrate)];
//	end

	assign oe  = (xfer_mode_i == STD_XFER) ? 4'b10 : oe_buf;

	assign byte_o = shift_in;

	wire _unused_pins = &{cs_n_trash};

	assign bitrate = (xfer_mode_i == STD_XFER) ? SINGLE_BITRATE :
			(xfer_mode_i == DUAL_XFER) ? DUAL_BITRATE :
			(xfer_mode_i == QUAD_XFER) ? QUAD_BITRATE : SINGLE_BITRATE;

	assign start_index = bit_order_lsb_i ? 0 : 7;
	assign index_diff  = bit_order_lsb_i ? (bitrate) : -(bitrate);
	assign stop_index  = bit_order_lsb_i ? 7 : 0;

	assign cs_n_stable_high = &{cs_n_prev, cs_n};
	assign cs_n_stable_low = !(|{cs_n_prev, cs_n});
	assign sck_rising = !sck_prev && sck;
	assign sck_falling = sck_prev && !sck;
	
	always @(posedge sys_clk) begin
		{cs_n_trash, cs_n_prev} <= {cs_n_prev[0+:cs_n_dc+1], cs_n};
		sck_prev   <= sck;

		if (cs_n_stable_high) begin // idle
			byte_sent        <= 0;
			byte_received    <= 0;
			shift_out        <= byte_i;
			input_bit_index  <= start_index;
			output_bit_index <= start_index;
			preload_done     <= 0;
			sck_r_flag       <= 1'b0;
			sck_f_flag       <= 1'b0;
		end else if (cs_n_stable_low) begin
			shift_out        <= byte_i;

			// RESET
			if (byte_sent) byte_sent <= 0;
			if (byte_received) byte_received <= 0;

			case (timing_mode_i)
			TIMING_MODE_1, TIMING_MODE_2: begin
				if ((timing_mode_i == TIMING_MODE_2)) begin // expect sck idles high
					if (!cs_n && sck && !preload_done) begin
/*
						case (xfer_mode_i)
						STD_XFER: begin
							//$display("SLAVE: shift out bit %d: %b", output_bit_index, shift_out[output_bit_index]);						
							io1_out <= shift_out[output_bit_index];
						end

						DUAL_XFER: begin
							//$display("SLAVE: shift out bit %d-%d: %b", (output_bit_index + index_diff), output_bit_index, shift_out[output_bit_index+: index_diff]);						
							{io1_out, io0_out} <= shift_out[output_bit_index+: DUAL_BITRATE];
						end

						default: begin
							{io3_out, io2_out, io1_out, io0_out} <= shift_out[output_bit_index+: QUAD_BITRATE];
						end
						endcase
*/
//						shift_out_buf <= (bit_order_lsb_i) ? shift_out[output_bit_index +: bitrate] : shift_out[output_bit_index -: bitrate];
						shift_out_buf = (bit_order_lsb_i) ? shift_out[(output_bit_index + bitrate) : output_bit_index] : shift_out[output_bit_index : (output_bit_index - bitrate)];

						output_bit_index <= output_bit_index + index_diff;

						preload_done <= 1;
					end
				end

				if (sck_rising) begin
					if (!sck_r_flag) begin
						if (!byte_sent) begin
							//$display("SLAVE: shift out bit %d: %b", output_bit_index, shift_out[output_bit_index]);
							io1_out <= shift_out[output_bit_index];
							output_bit_index <= output_bit_index + index_diff;

							if (output_bit_index == stop_index) begin
								//$display("SLAVE: sent \"%c\" to host", shift_out);
								byte_sent <= 1;
								output_bit_index <= start_index;
							end
						end
						sck_r_flag <= 1;
					end

					sck_f_flag <= 0;
				end else if (sck_falling) begin
					if (!sck_f_flag) begin
						if (!byte_received) begin
							//$display("SLAVE: %b shift in <- bit %d: %b", shift_in, input_bit_index, io0);
							shift_in[input_bit_index] <=  io0_i;
							input_bit_index <= input_bit_index + index_diff;

							if (input_bit_index == stop_index) begin
								byte_received	<= 1;
								input_bit_index	<= start_index;
							end
						end

						sck_f_flag <= 1;
					end

					sck_r_flag <= 0;
				end
			end

			TIMING_MODE_0, TIMING_MODE_3: begin
				if ((timing_mode_i == TIMING_MODE_0)) begin // expect sck idles low
					if (!cs_n && !sck && !preload_done) begin
						//$display("SLAVE: shift out bit %d: %b", output_bit_index, shift_out[output_bit_index]);
						io1_out <= shift_out[output_bit_index];
						output_bit_index <= output_bit_index + index_diff;

//						The "presample" logic below is unecessary though not detrimental to functionality 
//						//$display("SLAVE: %b shift in <- bit %d: %b", shift_in, input_bit_index, io0);
//						shift_in[input_bit_index] <=  io0;
//						input_bit_index <= input_bit_index + index_diff;

						preload_done <= 1;
					end
				end

				if (sck_rising) begin
					if (!sck_r_flag) begin
						if (!byte_received) begin
							//$display("SLAVE: %b shift in <- bit %d: %b", shift_in, input_bit_index, io0);
							shift_in[input_bit_index] <=  io0_i;
							input_bit_index <= input_bit_index + index_diff;

							if (input_bit_index == stop_index) begin
								byte_received	<= 1;
								input_bit_index	<= start_index;
							end
						end

						sck_r_flag <= 1;
					end

					sck_f_flag <= 0;
				end else if (sck_falling) begin
					if (!sck_f_flag) begin
						if (!byte_sent) begin
							//$display("SLAVE: shift out bit %d: %b", output_bit_index, shift_out[output_bit_index]);
							io1_out <= shift_out[output_bit_index];
							output_bit_index <= output_bit_index + index_diff;

							if (output_bit_index == stop_index) begin
								//$display("SLAVE: sent \"%c\" to host", shift_out);
								byte_sent <= 1;
								output_bit_index <= start_index;
							end
						end
						sck_f_flag <= 1;
					end

					sck_r_flag <= 0;
				end
			end

			default: ;
			endcase
		end
	end
endmodule
