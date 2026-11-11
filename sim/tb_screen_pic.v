`timescale 1ns / 1ns

module tb_screen_pic;

reg vga_clk = 1'b0;
reg sys_rst_n = 1'b0;
reg [9:0] pix_x = 10'd0;
reg [9:0] pix_y = 10'd0;
wire [15:0] bar_data, must_data, end_data;

//ten vertical colour bars
bar_pic dut_bar (
    .vga_clk (vga_clk),
    .sys_rst_n (sys_rst_n),
    .pix_x (pix_x),
    .pix_y (pix_y),
    .pix_data (bar_data)
);

//white MUST text on black
MUST_pic dut_must (
    .vga_clk (vga_clk),
    .sys_rst_n (sys_rst_n),
    .pix_x (pix_x),
    .pix_y (pix_y),
    .pix_data (must_data)
);

//white END text on black
end_pic dut_end (
    .vga_clk (vga_clk),
    .sys_rst_n (sys_rst_n),
    .pix_x (pix_x),
    .pix_y (pix_y),
    .pix_data (end_data)
);

always #20 vga_clk = ~vga_clk;

initial begin
$dumpfile("tb_screen_pic.vcd");
$dumpvars(0, tb_screen_pic);
$timeformat(-9, 0, " ns", 6);
$monitor("t=%t rst_n=%b x=%d y=%d bar=%h must=%h end=%h", $time, sys_rst_n, pix_x, pix_y, bar_data, must_data, end_data);

//T1 reset: all three outputs 0000
//T2 apply coordinates at falling edges; check after the next rising edge
#40 sys_rst_n = 1'b1;
pix_x = 10'd192; pix_y = 10'd208; //next rising edge: bar / MUST / END = 07E0 / FFFF / FFFF
#40 pix_x = 10'd255; pix_y = 10'd271; //next rising edge: bar / MUST / END = 07E0 / 0000 / FFFF
#40 pix_x = 10'd208; pix_y = 10'd224; //next rising edge: bar / MUST / END = 07E0 / 0000 / 0000
#40 pix_x = 10'd256; pix_y = 10'd240; //next rising edge: bar / MUST / END = 07FF / 0000 / 0000
#40 pix_x = 10'd288; pix_y = 10'd208; //next rising edge: bar / MUST / END = 07FF / FFFF / FFFF
#40 pix_x = 10'd330; //next rising edge: bar / MUST / END = 001F / 0000 / 0000
#40 pix_x = 10'd384; //next rising edge: bar / MUST / END = F81F / FFFF / FFFF
#40 pix_x = 10'd440; //next rising edge: bar / MUST / END = F81F / FFFF / 0000
#40 pix_x = 10'd447; pix_y = 10'd231; //next rising edge: bar / MUST / END = F81F / 0000 / FFFF
#40 pix_x = 10'd464; pix_y = 10'd208; //next rising edge: bar / MUST / END = 0000 / FFFF / 0000
#40 pix_x = 10'd639; pix_y = 10'd479; //next rising edge: bar / MUST / END = D69A / 0000 / 0000
#40 pix_x = 10'd1023; pix_y = 10'd1023; //next rising edge: bar / MUST / END = 0000 / 0000 / 0000
#40 pix_x = 10'd192; pix_y = 10'd208; //next rising edge: bar / MUST / END = 07E0 / FFFF / FFFF

//T3 reset between clock edges: all outputs become 0000 at once
#30 sys_rst_n = 1'b0;
#80 sys_rst_n = 1'b1;

//T4 recovery: t=660 gives 07E0 / FFFF / FFFF again
#70;
$display("END tb_screen_pic: compare each expected pixel with the waveform.");
$finish;

end

endmodule
