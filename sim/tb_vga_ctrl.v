`timescale 1ns / 1ns

module tb_vga_ctrl;

reg vga_clk = 1'b0;
reg sys_rst_n = 1'b0;
reg [15:0] pix_data = 16'hF800;
wire [9:0] pix_x, pix_y;
wire hsync, vsync;
wire [15:0] rgb;

wire [9:0] cnt_h = dut.cnt_h;
wire [9:0] cnt_v = dut.cnt_v;
wire rgb_valid = dut.rgb_valid;
wire pix_data_req = dut.pix_data_req;

vga_ctrl dut (
    .vga_clk (vga_clk),
    .sys_rst_n (sys_rst_n),
    .pix_data (pix_data),
    .pix_x (pix_x),
    .pix_y (pix_y),
    .hsync (hsync),
    .vsync (vsync),
    .rgb (rgb)
);

always #20 vga_clk = ~vga_clk;

initial begin
$dumpfile("tb_vga_ctrl.vcd");

//Extra usage: select signals to keep the two-frame VCD small.
$dumpvars(0, tb_vga_ctrl.sys_rst_n, tb_vga_ctrl.hsync,
          tb_vga_ctrl.vsync, tb_vga_ctrl.rgb_valid,
          tb_vga_ctrl.pix_data_req, tb_vga_ctrl.rgb);
$timeformat(-9, 0, " ns", 6);
$monitor("t=%t rst_n=%b hsync=%b vsync=%b rgb=%h", $time, sys_rst_n, hsync, vsync, rgb);

//T1 reset: cnt_h=0, cnt_v=0, rgb=0000
#40 sys_rst_n = 1'b1;   //t=40: release on a falling clock edge

//T2 first visible line: request starts one pixel before valid
#1125701;              //t=1125741: h=143, v=35, request=1, valid=0
$display("T2a t=%t h=%d v=%d x=%d y=%d req=%b valid=%b rgb=%h",
         $time, cnt_h, cnt_v, pix_x, pix_y, pix_data_req, rgb_valid, rgb);
#40;                   //t=1125781: h=144, v=35, rgb=F800, x=1
$display("T2b t=%t h=%d v=%d x=%d y=%d req=%b valid=%b rgb=%h",
         $time, cnt_h, cnt_v, pix_x, pix_y, pix_data_req, rgb_valid, rgb);

//T3 asynchronous reset while rgb is red; keep reset for 80 ns
#299 sys_rst_n = 1'b0;  //t=1126080: clear counters and rgb at once
#80 sys_rst_n = 1'b1;   //t=1126160: restart scanning

//T4 two full frames plus 100 us; measure sync in GTKWave
#33700000;
$display("END tb_vga_ctrl: compare T1-T4 with the waveform.");
$finish;               //t=34826160
end

endmodule