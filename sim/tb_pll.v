`timescale 1ns / 1ns

module tb_pll;

reg sys_clk = 1'b0;
reg sys_rst_n = 1'b0;
wire vga_clk;

pll dut (
    .sys_clk (sys_clk),
    .sys_rst_n (sys_rst_n),
    .vga_clk (vga_clk)
);

always #10 sys_clk = ~sys_clk;

initial begin
$dumpfile ("tb_pll.vcd");
$dumpvars(0, tb_pll);
$timeformat(-9, 0, " ns", 6);
$monitor("t=%t rst_n=%b sys_clk=%b vga_clk=%b", $time, sys_rst_n, sys_clk, vga_clk);

//T1 reset: vga_clk = 0
#40 sys_rst_n = 1'b1;   //t=40: release; vga_clk first rises at t=50

//T2 normal: sys_clk period 20 ns; vga_clk period 40 ns
#220 sys_rst_n = 1'b0;  //t=260: vga_clk falls immediately from 1 to 0

//T3 hold reset: vga_clk stays 0
#40 sys_rst_n = 1'b1;   //t=300: release; first rising edge at t=310
    
//T4 recovery: divide by two again
#200;
$display("END tb_pll: compare T1-T4 with the waveform.");
$finish;               //t=500
end

endmodule
