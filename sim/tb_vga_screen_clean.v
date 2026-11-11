`timescale 1ns / 1ns

module tb_vga_screen_clean;

reg sys_clk = 1'b0;
reg sys_rst_n = 1'b0;
reg key_in = 1'b1;
wire hsync, vsync;
wire [15:0] rgb;
wire key_press = dut.key_press;
wire [1:0] st_cur = dut.screen_fsm_inst.st_cur;
wire [1:0] disp_state = dut.disp_state;
wire [18:0] cnt_20ms = dut.key_filter_inst.cnt_20ms;

vga_screen dut (
    .sys_clk (sys_clk),
    .sys_rst_n (sys_rst_n),
    .key_in (key_in),
    .hsync (hsync),
    .vsync (vsync),
    .rgb (rgb)
);

always #10 sys_clk = ~sys_clk;

initial begin
$dumpfile("tb_vga_screen_clean.vcd");
$dumpvars(0, tb_vga_screen_clean.sys_rst_n, tb_vga_screen_clean.key_in,
          tb_vga_screen_clean.key_press, tb_vga_screen_clean.st_cur,
          tb_vga_screen_clean.disp_state);
$timeformat(-9, 0, " ns", 6);
$monitor("t=%t rst_n=%b key_in=%b key_press=%b st_cur=%d disp_state=%d",
         $time, sys_rst_n, key_in, key_press, st_cur, disp_state);

//C1 clean click: BARS -> MUST; real 20 ms debounce window
#40 sys_rst_n = 1'b1;
#29999960 key_in = 1'b0; //t=30 ms: press; accepted at 50.00005 ms
#29000000;
$display("C1 t=%t st_cur=%d disp_state=%d", $time, st_cur, disp_state); //t=59 ms: expected 1 / 1
#1000000 key_in = 1'b1; //t=60 ms: release

//C2 second clean click: MUST -> END
#30000000 key_in = 1'b0; //t=90 ms: press; accepted at 110.00005 ms
#29000000;
$display("C2 t=%t st_cur=%d disp_state=%d", $time, st_cur, disp_state); //t=119 ms: expected 2 / 2
#1000000 key_in = 1'b1; //t=120 ms: release

//C3 third clean click: END -> BARS
#30000000 key_in = 1'b0; //t=150 ms: press; accepted at 170.00005 ms
#30000000 key_in = 1'b1; //t=180 ms: release
#29000000;
$display("C3 t=%t st_cur=%d disp_state=%d", $time, st_cur, disp_state); //t=209 ms: expected 0 / 0

//C4 reset during an unfinished debounce interval; keep the key held
#11000000 key_in = 1'b0; //t=220 ms: begin a press
#5000000 sys_rst_n = 1'b0; //t=225 ms: only 5 ms of the 20 ms interval has elapsed
#80 sys_rst_n = 1'b1;
#24999920;
$display("C4 t=%t st_cur=%d disp_state=%d cnt_20ms=%d", $time, st_cur, disp_state, cnt_20ms); //t=250 ms: expected 0 / 0 / 0; no click
#10000000 key_in = 1'b1; //t=260 ms: release

//C5 recovery: release is debounced before the next clean press
#40000000 key_in = 1'b0; //t=300 ms: accepted at 320.00005 ms
#30000000;
$display("C5 t=%t st_cur=%d disp_state=%d", $time, st_cur, disp_state); //t=330 ms: expected 1 / 1
#10000000;
$display("END tb_vga_screen_clean: compare C1-C5 with the waveform.");
$finish;
end

endmodule
