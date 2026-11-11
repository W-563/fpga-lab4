`timescale 1ns / 1ns

module tb_key_filter;

reg vga_clk = 1'b0;
reg sys_rst_n = 1'b0;
reg key_in = 1'b1;
wire key_flag, key_press;

wire key_d2 = dut.key_d2;
wire [18:0] cnt_20ms = dut.cnt_20ms;

integer i;

//CNT_MAX = 500 (20 us)
key_filter #(.CNT_MAX(19'd500)) dut (
    .vga_clk (vga_clk),
    .sys_rst_n (sys_rst_n),
    .key_in (key_in),
    .key_flag (key_flag),
    .key_press (key_press)
);

always #20 vga_clk = ~vga_clk;

initial begin
$dumpfile("tb_key_filter.vcd");
$dumpvars(0, tb_key_filter);
$timeformat(-9, 0, " ns", 6);
$monitor("t=%t rst_n=%b key_in=%b key_flag=%b key_press=%b", $time, sys_rst_n, key_in, key_flag, key_press);

//T1 reset; T2 press bounce; T3 long hold; T4 release bounce; T5 glitch and short press; T6 reset while held; T7 recovery

//T1 reset: key_flag=0 
#40 sys_rst_n = 1'b1;   //t=40: release;

//T2 press with 8 us of bounce: one click
#39960 key_in = 1'b0;   //t=40000: press starts
for (i=0; i<4; i=i+1) begin   //t=41000-48000: four bounces, each 1 clears cnt_20ms
    #1000 key_in = 1'b1;
    #1000 key_in = 1'b0;
end
//t=48000: stable low;

//T3 long hold: no second click
#102000 $display("T3 t=%t key_flag=%b cnt_20ms=%d", $time, key_flag, cnt_20ms);   //t=150000: key_flag=0, cnt_20ms=0

//T4 release with bounce: no click
#50000 key_in = 1'b1;   //t=200000: release starts
for (i=0; i<4; i=i+1) begin
    #1000 key_in = 1'b0;
    #1000 key_in = 1'b1;
end
//t=208000: stable high;

#52000 key_in = 1'b0;   //t=260000: glitch
#2000 key_in = 1'b1;
#38000 key_in = 1'b0;   //t=300000: short press
#11960 $display("T5 t=%t key_flag=%b cnt_20ms=%d", $time, key_flag, cnt_20ms);
#40 key_in = 1'b1;      //t=312000: released before 20 us

//T6 reset while the key is held: no extra click after reset
#48000 key_in = 1'b0;   //t=360000: clean press; key_press at t=380060
#60000 sys_rst_n = 1'b0;
#80 sys_rst_n = 1'b1;   //t=420080: release reset; key_d2 still 1 for two clocks (cnt_20ms 1, 2), back to 0 at t=420180
#49920 $display("T6 t=%t key_flag=%b cnt_20ms=%d", $time, key_flag, cnt_20ms);
#10000 key_in = 1'b1;   //t=480000: release; key_flag rises at t=500060

//T7 recovery: the next press is one click again
#60000 key_in = 1'b0;
#60000 key_in = 1'b1;
#60000 $display("END tb_key_filter: 3 key_press pulses expected (T2, T6, T7); compare T1-T7 with the waveform.");
$finish;               //t=660000
end

endmodule