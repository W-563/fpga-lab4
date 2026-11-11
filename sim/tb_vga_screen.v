`timescale 1ns / 1ns

module tb_vga_screen;

reg sys_clk = 1'b0;
reg sys_rst_n = 1'b0;
reg key_in = 1'b1;
wire hsync, vsync;
wire [15:0] rgb;

wire [9:0] cnt_h = dut.vga_ctrl_inst.cnt_h;
wire [9:0] cnt_v = dut.vga_ctrl_inst.cnt_v;
wire key_flag = dut.key_flag;
wire key_press = dut.key_press;
wire [18:0] cnt_20ms = dut.key_filter_inst.cnt_20ms;
wire [1:0] st_cur = dut.screen_fsm_inst.st_cur;
wire [1:0] disp_state = dut.disp_state;

integer i;

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
$dumpfile("tb_vga_screen.vcd");
$dumpvars(0, tb_vga_screen.sys_rst_n, tb_vga_screen.key_in,
          tb_vga_screen.key_flag, tb_vga_screen.key_press,
          tb_vga_screen.st_cur, tb_vga_screen.disp_state,
          tb_vga_screen.hsync, tb_vga_screen.vsync);
$timeformat(-9, 0, " ns", 6);
$monitor("t=%t rst_n=%b key_in=%b key_flag=%b key_press=%b st_cur=%d disp_state=%d",
         $time, sys_rst_n, key_in, key_flag, key_press, st_cur, disp_state);

//States: 0 = BARS, 1 = MUST, 2 = END. Probes: pixel (192,208) is h=336, v=243; pixel (440,208) is h=584, v=243.
//T1 reset: colour bars
#40 sys_rst_n = 1'b1;   //t=40: release on a falling edge
#7789411;
//expected: st_cur=0, disp_state=0, rgb=07E0
$display("T1a t=%t h=%d v=%d st_cur=%d disp_state=%d rgb=%h", $time, cnt_h, cnt_v, st_cur, disp_state, rgb);
#9920;
//expected: st_cur=0, disp_state=0, rgb=F81F
$display("T1b t=%t h=%d v=%d st_cur=%d disp_state=%d rgb=%h", $time, cnt_h, cnt_v, st_cur, disp_state, rgb);

//T2 click 1 with press and release bounce: BARS -> MUST
#22200629 key_in = 1'b0;
for (i=0; i<4; i=i+1) begin
    #1000000 key_in = 1'b1;
    #1000000 key_in = 1'b0;
end
//t=38000000: stable low; key_press about 20 ms later, st_cur=1
#36989451;
//expected: st_cur=1, disp_state=1, rgb=FFFF
$display("T2a t=%t h=%d v=%d st_cur=%d disp_state=%d rgb=%h", $time, cnt_h, cnt_v, st_cur, disp_state, rgb);
#9920;
//expected: st_cur=1, disp_state=1, rgb=FFFF
$display("T2b t=%t h=%d v=%d st_cur=%d disp_state=%d rgb=%h", $time, cnt_h, cnt_v, st_cur, disp_state, rgb);
#5000629 key_in = 1'b1;
for (i=0; i<4; i=i+1) begin
    #1000000 key_in = 1'b0;
    #1000000 key_in = 1'b1;
end

//T3 click 2, held for 300 ms: MUST -> END only once
#32000000 key_in = 1'b0;
#38989451;
//expected: st_cur=2, disp_state=2, rgb=FFFF
$display("T3a t=%t h=%d v=%d st_cur=%d disp_state=%d rgb=%h", $time, cnt_h, cnt_v, st_cur, disp_state, rgb);
#9920;
//expected: st_cur=2, disp_state=2, rgb=0000
$display("T3b t=%t h=%d v=%d st_cur=%d disp_state=%d rgb=%h", $time, cnt_h, cnt_v, st_cur, disp_state, rgb);
#241000629;
$display("T3c t=%t st_cur=%d cnt_20ms=%d", $time, st_cur, cnt_20ms);
#20000000 key_in = 1'b1;

//T4 click 3: END -> BARS
#40000000 key_in = 1'b0;
#34989451;
//expected: st_cur=0, disp_state=0, rgb=07E0
$display("T4a t=%t h=%d v=%d st_cur=%d disp_state=%d rgb=%h", $time, cnt_h, cnt_v, st_cur, disp_state, rgb);
#9920;
//expected: st_cur=0, disp_state=0, rgb=F81F
$display("T4b t=%t h=%d v=%d st_cur=%d disp_state=%d rgb=%h", $time, cnt_h, cnt_v, st_cur, disp_state, rgb);
#5000629 key_in = 1'b1;

//T5 reset in MUST
#40000000 key_in = 1'b0;
#38999371;
//expected: st_cur=1, disp_state=1, rgb=FFFF
$display("T5a t=%t h=%d v=%d st_cur=%d disp_state=%d rgb=%h", $time, cnt_h, cnt_v, st_cur, disp_state, rgb);
#1000629 key_in = 1'b1;
#40000000 sys_rst_n = 1'b0;
#80 sys_rst_n = 1'b1;
#7799331;
//expected: st_cur=0, disp_state=0, rgb=F81F
$display("T5b t=%t h=%d v=%d st_cur=%d disp_state=%d rgb=%h", $time, cnt_h, cnt_v, st_cur, disp_state, rgb);

//T6 reset in END
#32200589 key_in = 1'b0;
#40000000 key_in = 1'b1;
#40000000 key_in = 1'b0;
#38989491;
//expected: st_cur=2, disp_state=2, rgb=FFFF
$display("T6a t=%t h=%d v=%d st_cur=%d disp_state=%d rgb=%h", $time, cnt_h, cnt_v, st_cur, disp_state, rgb);
#1010509 key_in = 1'b1;
#40000000 sys_rst_n = 1'b0;
#80 sys_rst_n = 1'b1;
#7789411;
//expected: st_cur=0, disp_state=0, rgb=07E0
$display("T6b t=%t h=%d v=%d st_cur=%d disp_state=%d rgb=%h", $time, cnt_h, cnt_v, st_cur, disp_state, rgb);

//T7 reset while the key is held: no click after reset
#32210509 key_in = 1'b0;
#40000000 sys_rst_n = 1'b0;
#80 sys_rst_n = 1'b1;
#7789411;
//expected: st_cur=0, disp_state=0, rgb=07E0
$display("T7a t=%t h=%d v=%d st_cur=%d disp_state=%d rgb=%h", $time, cnt_h, cnt_v, st_cur, disp_state, rgb);
#42210509;
$display("T7b t=%t st_cur=%d key_flag=%b cnt_20ms=%d", $time, st_cur, key_flag, cnt_20ms);
#10000000 key_in = 1'b1;

//T8 recovery: the next click works
#40000000 key_in = 1'b0;
#42199411;
//expected: st_cur=1, disp_state=1, rgb=FFFF
$display("T8 t=%t h=%d v=%d st_cur=%d disp_state=%d rgb=%h", $time, cnt_h, cnt_v, st_cur, disp_state, rgb);
#17800589 key_in = 1'b1;
#40000000;
$display("END tb_vga_screen: compare T1-T8 with the waveform.");
$finish;
end

endmodule