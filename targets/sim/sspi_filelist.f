+timescale+1ns/1ns

# spiflash
-l ../../rtl/comms/uart.v
-l ../../rtl/comms/spi_slave.v
-l ../../rtl/spiflash_J26H1.v

# external uart transmitter (Simulation model for flashloader)
-l ../../rtl/flashloader_J26H1.v

# EXTERNAL CPU FILES
#gf180mcu cell librarcy
-l ../../rtl/cpu/SINGLE_SPI/caravel-tiny/gf180mcu/primitives.v
-l ../../rtl/cpu/SINGLE_SPI/caravel-tiny/gf180mcu/gf180mcu_fd_sc_mcu7t5v0.v

# Caravel verilog header files
-l ../../rtl/cpu/SINGLE_SPI/caravel-tiny/include/pinout.vh
-l ../../rtl/cpu/SINGLE_SPI/caravel-tiny/include/defines.v

#gf180mcuD macros
-l ../../rtl/cpu/SINGLE_SPI/caravel-tiny/gf180mcu/gf18mcuD/gf180mcu_fd_io.v
-l ../../rtl/cpu/SINGLE_SPI/caravel-tiny/gf180mcu/gf18mcuD/gf180mcu_ws_io.v
-l ../../rtl/cpu/SINGLE_SPI/caravel-tiny/sram/gf180_ram_512x8_wrapper.v
-l ../../rtl/cpu/SINGLE_SPI/caravel-tiny/simple_por/simple_por.v
-l ../../rtl/cpu/SINGLE_SPI/caravel-tiny/ring_osc/ring_osc2x13.nl.v

# Caravel core
-l ../../rtl/cpu/SINGLE_SPI/caravel-tiny/caravel_clocking.v
-l ../../rtl/cpu/SINGLE_SPI/caravel-tiny/caravel_core.v
-l ../../rtl/cpu/SINGLE_SPI/caravel-tiny/clock_div.v
-l ../../rtl/cpu/SINGLE_SPI/caravel-tiny/digital_pll.v
-l ../../rtl/cpu/SINGLE_SPI/caravel-tiny/digital_pll_controller.v
-l ../../rtl/cpu/SINGLE_SPI/caravel-tiny/gpio_defaults_block.v
-l ../../rtl/cpu/SINGLE_SPI/caravel-tiny/gpio_control_block.v
-l ../../rtl/cpu/SINGLE_SPI/caravel-tiny/GF180_RAM_512x32.v
-l ../../rtl/cpu/SINGLE_SPI/caravel-tiny/mgmt_core.v
-l ../../rtl/cpu/SINGLE_SPI/caravel-tiny/mgmt_core_wrapper.v
-l ../../rtl/cpu/SINGLE_SPI/caravel-tiny/mgmt_protect.v
-l ../../rtl/cpu/SINGLE_SPI/caravel-tiny/mprj_io_buffer.v
-l ../../rtl/cpu/SINGLE_SPI/caravel-tiny/sram.v
-l ../../rtl/cpu/SINGLE_SPI/caravel-tiny/VexRiscv_MinDebugCache.v
-l ../../rtl/cpu/SINGLE_SPI/caravel-tiny/housekeeping.v
-l ../../rtl/cpu/SINGLE_SPI/caravel-tiny/housekeeping_spi.v

## External SPIflash
-l ../../rtl/cpu/SINGLE_SPI/caravel-tiny/spiflash_model/spiflash_model.v
