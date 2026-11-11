`timescale 1ns / 1ns

module tb_screen_fsm;

reg vga_clk = 1'b0;
reg sys_rst_n = 1'b0;
reg key_press = 1'b0;
reg vsync = 1'b0;
wire [1:0] disp_state;

wire [1:0] st_cur = dut.st_cur;

screen_fsm dut (
    .vga_clk (vga_clk),
    .sys_rst_n (sys_rst_n),
    .key_press (key_press),
    .vsync (vsync),
    .disp_state (disp_state)
);

always #20 vga_clk = ~vga_clk;

initial begin
$dumpfile("tb_screen_fsm.vcd");
$dumpvars(0, tb_screen_fsm);
$timeformat(-9, 0, " ns", 6);
$monitor("t=%t rst_n=%b key_press=%b vsync=%b st_cur=%d disp_state=%d", $time, sys_rst_n, key_press, vsync, st_cur, disp_state);

//States: 0 = BARS, 1 = MUST, 2 = END. key_press is one clock wide, as from key_filter

//T1 reset: st_cur=0, disp_state=0
#40 sys_rst_n = 1'b1;   //t=40: release on a falling edge

//T2 one click: st_cur moves at once, disp_state waits for vsync
#160 key_press = 1'b1;  //t=200: click; st_cur=1 (MUST) at t=220
#40 key_press = 1'b0;
#20;
$display("T2a t=%t st_cur=%d disp_state=%d", $time, st_cur, disp_state);
#140 vsync = 1'b1;
#80 vsync = 1'b0;
#20;
$display("T2b t=%t st_cur=%d disp_state=%d", $time, st_cur, disp_state);

//T3 second and third click: END, then back to BARS
#100 key_press = 1'b1;  //t=600: click, st_cur=2 (END) at t=620
#40 key_press = 1'b0;
#160 vsync = 1'b1;
#80 vsync = 1'b0;
#120 key_press = 1'b1;  //t=1000: click, st_cur=0 (BARS) at t=1020
#40 key_press = 1'b0; 
#160 vsync = 1'b1;
#80 vsync = 1'b0;

//T4 reset in MUST
#120 key_press = 1'b1;
#40 key_press = 1'b0;
#160 vsync = 1'b1;
#80 vsync = 1'b0;
#120 sys_rst_n = 1'b0;
#80 sys_rst_n = 1'b1;   //t=1880: restart from BARS

//T5 reset in END
#120 key_press = 1'b1;
#40 key_press = 1'b0;
#160 key_press = 1'b1;
#40 key_press = 1'b0;
#160 vsync = 1'b1;
#80 vsync = 1'b0;
#120 sys_rst_n = 1'b0;
#80 sys_rst_n = 1'b1;

//T6 click while vsync is high: disp_state follows one clock later
#120 vsync = 1'b1;      //t=2800: sync window already open
#40 key_press = 1'b1;
#40 key_press = 1'b0;
#80 vsync = 1'b0;
#240;
$display("END tb_screen_fsm: compare T1-T6 with the waveform.");
$finish;
end

endmodule