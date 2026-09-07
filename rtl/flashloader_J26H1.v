module flashloader_J26H1 #(
	parameter FILENAME = "firmware.hex",
	parameter MEM_SIZE = 4 * 1024,
	parameter CLK_FREQ  = 20_000_000,
	parameter BAUD_RATE = 19_200
)(
	input clk,
	input rst_n,

	output uart_tx,
	output done_o
);
	reg send_byte;
	reg sending;
	wire byte_sent;
	reg done;
	integer byte_count;
	wire [7:0] outbound_byte;

	reg [7:0] memory [0: MEM_SIZE-1];

	initial begin
		$readmemh(FILENAME, memory);
		$display("FIRMWARE '%s' LOADED", FILENAME);
	end

	assign outbound_byte = memory[byte_count];
	assign done_o = done;

	serializer #(
		.CLK_FREQ    (CLK_FREQ),
		.BAUD_RATE   (BAUD_RATE)
	) uart_loader (
		.serial_data (uart_tx),
		.done        (byte_sent),
		.start       (send_byte),
		.clock       (clk),
		.binary_data (outbound_byte)
	);

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			send_byte  <= 0;
			sending    <= 0;
			done       <= 0;
			byte_count <= 0;
		end else if (!done) begin
			if (!sending) begin
				send_byte <= 1;
				sending   <= 1;
			end else begin
				send_byte  <= 0;

				if (byte_sent) begin
					if (byte_count < MEM_SIZE-1) byte_count <= byte_count + 1;
					else done <= 1;

					sending <= 0;
				end
			end
		end
	end

endmodule
