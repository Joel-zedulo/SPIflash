// SPDX-License-Identifier: MIT

`timescale 1ns/1ns

// serializer: Splits binary_data into samples sent to serial_data on posedge of control sig
module serializer #(
	parameter BAUD_RATE = 19_200,
	parameter CLK_FREQ  = 20_000_000
)(
	output reg serial_data,
	output reg done,
	input start,
	input clock,
	input [7:0] binary_data
);
	// define output period (cycles) per bit
	localparam cycles_per_serial_bit = CLK_FREQ / BAUD_RATE;
	localparam serial_start_bit_cycle = 0;

	localparam serial_bit_0_cycle = 1 + cycles_per_serial_bit;
	localparam serial_bit_1_cycle = 1 + cycles_per_serial_bit * 2;
	localparam serial_bit_2_cycle = 1 + cycles_per_serial_bit * 3;
	localparam serial_bit_3_cycle = 1 + cycles_per_serial_bit * 4;
	localparam serial_bit_4_cycle = 1 + cycles_per_serial_bit * 5;
	localparam serial_bit_5_cycle = 1 + cycles_per_serial_bit * 6;
	localparam serial_bit_6_cycle = 1 + cycles_per_serial_bit * 7;
	localparam serial_bit_7_cycle = 1 + cycles_per_serial_bit * 8;

	localparam serial_stop_bit_cycle = 1 + cycles_per_serial_bit * 9;
	localparam byte_serialized_cycle = 1 + cycles_per_serial_bit * 10;

	reg is_fresh_signal = 0;
	reg active_flag = 0;
	integer cycles = 0;

	// serialize the binary_data using the set sample cycles
	always @(posedge clock)
	begin
		done <= 0;

		if (!start)
			is_fresh_signal <= 1;

		else if (is_fresh_signal)
		begin
			is_fresh_signal <= 0;
			active_flag <= 1;
		end

		if (active_flag)
		begin
			if (cycles == serial_start_bit_cycle)
				serial_data <= 0;

			else if (cycles == serial_bit_0_cycle)
				serial_data <= binary_data[0];

			else if (cycles == serial_bit_1_cycle)
				serial_data <= binary_data[1];

			else if (cycles == serial_bit_2_cycle)
				serial_data <= binary_data[2];

			else if (cycles == serial_bit_3_cycle)
				serial_data <= binary_data[3];

			else if (cycles == serial_bit_4_cycle)
				serial_data <= binary_data[4];

			else if (cycles == serial_bit_5_cycle)
				serial_data <= binary_data[5];

			else if (cycles == serial_bit_6_cycle)
				serial_data <= binary_data[6];

			else if (cycles == serial_bit_7_cycle)
				serial_data <= binary_data[7];

			else if (cycles == serial_stop_bit_cycle)
				serial_data <= 1;

			else if (cycles == byte_serialized_cycle)
				done <= 1;

			cycles <= cycles + 1;
		end
		else
			serial_data <= 1;

		if (done)
		begin
			active_flag <= 0;
			serial_data <= 1;
			cycles <= 0;
		end
	end
endmodule

// deserializer: Samples serial_data; Outputs the samples to binary_data buffer
module deserializer #(
	parameter BAUD_RATE = 19_200,
	parameter CLK_FREQ  = 20_000_000
)(
	output reg [9:0] binary_data,
	output reg done,
	input clock,
	input serial_data
);
	// set cycles per sample
	localparam cycles_per_serial_bit = CLK_FREQ / BAUD_RATE;

	localparam mid_start_bit = cycles_per_serial_bit / 2;
	localparam mid_bit_0 = mid_start_bit + cycles_per_serial_bit;
	localparam mid_bit_1 = mid_start_bit + cycles_per_serial_bit * 2;
	localparam mid_bit_2 = mid_start_bit + cycles_per_serial_bit * 3;
	localparam mid_bit_3 = mid_start_bit + cycles_per_serial_bit * 4;
	localparam mid_bit_4 = mid_start_bit + cycles_per_serial_bit * 5;
	localparam mid_bit_5 = mid_start_bit + cycles_per_serial_bit * 6;
	localparam mid_bit_6 = mid_start_bit + cycles_per_serial_bit * 7;
	localparam mid_bit_7 = mid_start_bit + cycles_per_serial_bit * 8;
	localparam mid_stop_bit = mid_start_bit + cycles_per_serial_bit * 9;

	integer cycles;
	reg sampling = 0;

	// get each sample at it's set cycle (mid-way through sample period)
	always @(posedge clock)
	begin
		done <= 0;

		if (!sampling)
		begin
			cycles <= 0;

			if (serial_data == 0)
			begin
				sampling <= 1;
			end
		end

		else // sampling
		begin
			if (cycles == mid_start_bit)
				binary_data[0] <= serial_data;

			else if (cycles == mid_bit_0)
				binary_data[1] <= serial_data;

			else if (cycles == mid_bit_1)
				binary_data[2] <= serial_data;

			else if (cycles == mid_bit_2)
				binary_data[3] <= serial_data;

			else if (cycles == mid_bit_3)
				binary_data[4] <= serial_data;

			else if (cycles == mid_bit_4)
				binary_data[5] <= serial_data;

			else if (cycles == mid_bit_5)
				binary_data[6] <= serial_data;

			else if (cycles == mid_bit_6)
				binary_data[7] <= serial_data;

			else if (cycles == mid_bit_7)
				binary_data[8] <= serial_data;

			else if (cycles == mid_stop_bit)
				binary_data[9] <= serial_data;

			else if (cycles == mid_stop_bit + 1)
			begin
				done <= 1;
				sampling <= 0;
			end

			cycles <= cycles + 1;
		end
	end
endmodule
