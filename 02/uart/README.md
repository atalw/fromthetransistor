## UART

Read about it [here](https://en.wikipedia.org/wiki/Universal_asynchronous_receiver-transmitter).

#### Run instructions

- `iverilog -o uart.vvp test_bench.v transmitter.v receiver.v`
- `vvp uart.vvp`
- `gtkwave uart.vcd`
