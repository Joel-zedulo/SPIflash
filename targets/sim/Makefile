OUTPUT := spiflash.sim
INCLUDE_DIR_1 := ../../rtl/cpu/SINGLE_SPI/caravel-tiny/include

GENERAL_IVERILOG_OPTIONS := -g2012 -Wall -I $(INCLUDE_DIR_1) \
	-o $(OUTPUT) -Wno-implicit -Wno-timescale -Wno-anachronisms

# Map LEVEL to specific iverilog commands
CMD_1 := iverilog $(GENERAL_IVERILOG_OPTIONS) -f sspi_filelist.f -s spiflash_J26H1
CMD_2 := iverilog $(GENERAL_IVERILOG_OPTIONS) -f qspi_filelist.f -s spiflash_J26H1
CMD_3 := iverilog $(GENERAL_IVERILOG_OPTIONS) -f sspi_filelist.f tb_flash_mem.v
CMD_4 := iverilog $(GENERAL_IVERILOG_OPTIONS) -f sspi_filelist.f tb_singlespi_flash.v
CMD_5 := iverilog $(GENERAL_IVERILOG_OPTIONS) -f qspi_filelist.f tb_qspi_flash.v

LEVEL ?= 5
SELECTED_CMD = $(CMD_$(LEVEL))

.PHONY: test clean

test:
	@if [ -z "$(SELECTED_CMD)" ]; then \
		echo "Error: Invalid LEVEL=$(LEVEL). Use 1-5."; exit 1; \
	fi
	@$(SELECTED_CMD) || { echo "\n\t\033[1;31m Compilation failed \033[0m\n"; exit 1; }
	@echo "\n\t\033[1;33m Compilation successful \033[0m\n"
	@./$(OUTPUT) -fst
#	@rm -f $(OUTPUT) *.fst

clean:
	rm -f $(OUTPUT) *.fst
