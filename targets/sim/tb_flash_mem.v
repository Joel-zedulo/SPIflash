module tb_flash_mem;
	reg clk_20mhz, clk_50mhz;
	reg flash_rst_n, cpu_rst_n;

	initial {clk_20mhz, clk_50mhz, flash_rst_n, cpu_rst_n} = 4'b0;

	always #25 clk_20mhz = !clk_20mhz;
	always #10 clk_50mhz = !clk_50mhz;

	///////////////////////////////////////

	// SPIflash

	///////////////////////////////////////////////////////////

	wire flashloader_tx;
	wire flashed;

	spiflash_J26H1 #(
		.CLK_FREQ  (50_000_000),
		.BAUD_RATE (50_000_000), // Don't try this at home(ON FPGA) :)
		.MEM_SIZE  (2 * 1024)
	) spiflash ( 
		.sys_clk  (clk_50mhz),
		.rst_n    (flash_rst_n),

		// Memory initialization happens via UART receiver post reset
		.uart_rx  (flashloader_tx),
		.memset_o (flashed),

		.dflt_xfer_mode_i   (3'b1), // 1:singleSPI; ?:QSPI
		.dflt_timing_mode_i (2'b0),

		.csb      (1'bz),
		.clk      (1'bz),

		.io0_i    (1'bz),
		.io1_i    (1'bz),
		.io2_i    (1'bz),
		.io3_i    (1'bz),

		.io0_o    (),
		.io1_o    (),
		.io2_o    (),
		.io3_o    ()
	);

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	// FLASHING          (... or, Loading the hex firmware data from a file on user PC into the spiflash memory)

	// NOTE: The module below is for simulation only !!
	//	For physical verification, use the Linux utility in this repo: https://github.com/Joel-zedulo/SPIflashloader

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	flashloader_J26H1 #(
		.FILENAME  ("example_firmware/gpio_high.hex"),
		.MEM_SIZE  (2 * 1024),
		.CLK_FREQ  (50_000_000),
		.BAUD_RATE (50_000_000) // Don't try this at home(ON FPGA) :)
	) flashloader (
		.clk      (clk_50mhz),
		.rst_n    (flash_rst_n),

		.uart_tx  (flashloader_tx),
		.done_o   ()
	);

	// Test completion monitor
	initial begin
		$dumpfile("tb_flash_mem.fst");
		$dumpvars(0, tb_flash_mem);
	end

	initial begin
		$display("SPIFLASH & CPU in reset");

		#100;
		flash_rst_n = 1;
		$display("Waiting for spiflash to be initialized via its writeonly uart interface");

		wait (flashed) begin
			$display("\nSPIFLASH initialized, Releasing CPU from reset...\n");

			#100;
			cpu_rst_n = 1;
			$display("Waiting for CPU CORE to read and execute firmware...");

			$finish;
		end
	end
endmodule
