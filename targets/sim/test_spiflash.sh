OUTPUT="spiflash.sim"

INCLUDE_DIR_1="../../rtl/cpu/SINGLE_SPI/caravel-tiny/include"

GENERAL_IVERILOG_OPTIONS="-g2012 -Wall -I $INCLUDE_DIR_1
 -o $OUTPUT -Wno-implicit -Wno-timescale -Wno-anachronisms"

CMD_1="iverilog $GENERAL_IVERILOG_OPTIONS -f sspi_filelist.f -s spiflash_J26H1"
CMD_2="iverilog $GENERAL_IVERILOG_OPTIONS -f qspi_filelist.f -s spiflash_J26H1"
CMD_3="iverilog $GENERAL_IVERILOG_OPTIONS -f sspi_filelist.f tb_flash_mem.v"
CMD_4="iverilog $GENERAL_IVERILOG_OPTIONS -f sspi_filelist.f tb_singlespi_flash.v"
CMD_5="iverilog $GENERAL_IVERILOG_OPTIONS -f qspi_filelist.f tb_qspi_flash.v"

$CMD_5

if [ $? -ne 0 ]; then
	echo -e "\n\t\e[1;31m Compilation failed \e[0m\n"
	exit 1
fi

echo -e "\n\t\e[1;33m Compilation successful \e[0m\n"
./$OUTPUT -fst

rm $OUTPUT &> /dev/null
#gtkwave *.fst &> /dev/null
rm *.fst &> /dev/null
