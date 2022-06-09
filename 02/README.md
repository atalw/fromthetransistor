## Bringup: What language is hardware coded in?

#### Read

- [Verilog intro](https://www.iitg.ac.in/hemangee/cs224_2020/verilog2.pdf)

#### Run instructions

- `iverilog -o testbench.vvp clock_test_bench.v clock.v`
- `vvp testbench.vvp`
- `gtkwave freq_div.vcd`
