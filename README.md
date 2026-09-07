# SPIFlash Device

A Prototype Digital Hardware Device, currently supporting Standard SPI flash operation.

## Notes

For the prototype, memory initializaton happens via UART post reset (u pulse reset low briefly, then send you firmware into the spiflas via an exposed UART_RX pin, byte-by-byte) via its uart reciever.
An external CPU can read the firmware via the SPI interface.
# SPIFlash
