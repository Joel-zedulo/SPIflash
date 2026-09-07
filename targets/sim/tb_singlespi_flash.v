`include "defines.v"

module tb_singlespi_flash;
	reg clk_20mhz, clk_50mhz;
	reg flash_rst_n, cpu_rst_n;

	initial {clk_20mhz, clk_50mhz, flash_rst_n, cpu_rst_n} = 4'b0;

	always #25 clk_20mhz = !clk_20mhz;
	always #10 clk_50mhz = !clk_50mhz;


//////////////////////////////////////////////////
// Caravel CPU Core
///////////////////////////////////////
	// Use proper NUM_BIDIR_PADS from the chip definition
	parameter NUM_BIDIR_PADS = 42;
	wire [NUM_BIDIR_PADS-1:0] bidir_in, bidir_out, bidir_oe, bidir_ie;
	wire [NUM_BIDIR_PADS-1:0] bidir_cs, bidir_pu, bidir_pd, bidir_sl;

	assign bidir_in[0] = 1'b0;  // Disable debug mode

	// caravel_core instantiation with proper pad mapping
	caravel_core cpu (
		.rstb(cpu_rst_n),
		.clock_core(clk_20mhz),
		.gpio_out_core(bidir_out[`PAD_GPIO]),
		.gpio_in_core(bidir_in[`PAD_GPIO]),
		.gpio_outenb_core(bidir_oe[`PAD_GPIO]),
		.gpio_inenb_core(bidir_ie[`PAD_GPIO]),

		.flash_csb_frame(bidir_out[`PAD_FLASH_CSB]),
		.flash_clk_frame(bidir_out[`PAD_FLASH_CLK]),
		.flash_csb_oe(bidir_oe[`PAD_FLASH_CSB]),
		.flash_clk_oe(bidir_oe[`PAD_FLASH_CLK]),
		.flash_io0_oe(bidir_oe[`PAD_FLASH_IO0]),
		.flash_io1_oe(bidir_oe[`PAD_FLASH_IO1]),
		.flash_io0_ie(bidir_ie[`PAD_FLASH_IO0]),
		.flash_io1_ie(bidir_ie[`PAD_FLASH_IO1]),
		.flash_io0_do(bidir_out[`PAD_FLASH_IO0]),
		.flash_io1_do(bidir_out[`PAD_FLASH_IO1]),
		.flash_io0_di(bidir_in[`PAD_FLASH_IO0]),
		.flash_io1_di(bidir_in[`PAD_FLASH_IO1]),

		.caravel_io_in(bidir_in[`CARAVEL_IO_PADS-1:0]),
		.caravel_io_out(bidir_out[`CARAVEL_IO_PADS-1:0]),
		.caravel_io_oe(bidir_oe[`CARAVEL_IO_PADS-1:0]),
		.caravel_io_ie(bidir_ie[`CARAVEL_IO_PADS-1:0]),
		.caravel_io_schmitt_sel(bidir_cs[`CARAVEL_IO_PADS-1:0]),
		.caravel_io_pullup_sel(bidir_pu[`CARAVEL_IO_PADS-1:0]),
		.caravel_io_pulldown_sel(bidir_pd[`CARAVEL_IO_PADS-1:0]),
		.caravel_io_slew_sel(bidir_sl[`CARAVEL_IO_PADS-1:0]),

		.user_wb_clk_o(),
		.user_wb_rst_o(),
		.user_wb_cyc_o(),
		.user_wb_stb_o(),
		.user_wb_we_o(),
		.user_wb_sel_o(),
		.user_wb_adr_o(),
		.user_wb_dat_o(),
		.user_wb_dat_i(32'bz),
		.user_wb_ack_i(1'bz),

		.user_irq_core(1'b0),
		.user_gpio_out({`CARAVEL_IO_PADS{1'b0}}),
		.user_gpio_oeb({`CARAVEL_IO_PADS{1'b1}}),

		.npor(),
		.start_mode(1'b0) // Normal boot (reading instructions from external spiflash)
	);


/////////////////////////////////////////////////////////////
// SPIflash
/////////////////////////////////////////
	wire flashloader_tx;
	wire flashed;

	spiflash_J26H1 #(
		.CLK_FREQ           (50_000_000),
		.BAUD_RATE          (50_000_000),
		.MEM_SIZE           (2 * 1024)
	) spiflash (
		.sys_clk            (clk_50mhz), // sys_clk must be at least 2 times faster than the flash spi clk
		.rst_n              (flash_rst_n),

		// Memory initialization happens via UART receiver post reset
		.uart_rx            (flashloader_tx),
		.memset_o           (flashed),

		.dflt_xfer_mode_i   (3'b1), // 1:singleSPI; ?:QSPI
		.dflt_timing_mode_i (2'b0),

		.csb                (bidir_out[`PAD_FLASH_CSB]),
		.clk                (bidir_out[`PAD_FLASH_CLK]),

		.io0_i              (bidir_out[`PAD_FLASH_IO0]),
		.io1_i              (1'b0),
		.io2_i              (1'b0),
		.io3_i              (1'b0),

		.io0_o              (),
		.io1_o              (bidir_in[`PAD_FLASH_IO1]),
		.io2_o              (),
		.io3_o              ()
	);


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// FLASHING          (... or, Loading the hex firmware data from a file on user PC into the spiflash memory)
//
// NOTE: The module below is for simulation model!!
//
//	For physical verification (FPGA/PCB),
//		use the Linux utility in this repo: https://github.com/Joel-zedulo/SPIflashloader
//
////////////////////////////////////////////////////////
	flashloader_J26H1 #(
		.FILENAME  ("example_firmware/gpio_high.hex"),
		.MEM_SIZE  (2 * 1024),
		.CLK_FREQ  (50_000_000),
		.BAUD_RATE (50_000_000)
	) flashloader (
		.clk      (clk_50mhz),
		.rst_n    (flash_rst_n),

		.uart_tx  (flashloader_tx),
		.done_o   ()
	);

	// Test completion monitor
	initial begin
		$dumpfile("tb_singlespi_flash.fst");
		$dumpvars(0, tb_singlespi_flash);
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

			if (!bidir_out[`PAD_GPIO])
				wait (bidir_out[`PAD_GPIO])
					$display("The CPU has successfully run the firmware in '%s' from our SPIflash!!", flashloader.FILENAME);
			$finish;
		end
	end
endmodule
