`timescale 1ns / 1ns

module vga_screen(
    input wire sys_clk,         //50 MHz board clock
    input wire sys_rst_n,       //reset button, active low
    input wire key_in,          //switching button, active low

    output wire hsync,
    output wire vsync,
    output wire [15:0] rgb
);

localparam S_BARS = 2'd0;
localparam S_MUST = 2'd1;
localparam S_END = 2'd2;

wire vga_clk;
wire key_flag;
wire key_press;
wire [1:0] disp_state;
wire [9:0] pix_x;
wire [9:0] pix_y;
wire [15:0] bar_data;
wire [15:0] must_data;
wire [15:0] end_data;
reg [15:0] pix_data;

pll pll_inst(
    .sys_clk (sys_clk),
    .sys_rst_n (sys_rst_n),
    .vga_clk (vga_clk)
);

key_filter key_filter_inst(
    .vga_clk (vga_clk),
    .sys_rst_n (sys_rst_n),
    .key_in (key_in),
    .key_flag (key_flag),
    .key_press (key_press)
);

screen_fsm screen_fsm_inst(
    .vga_clk (vga_clk),
    .sys_rst_n (sys_rst_n),
    .key_press (key_press),
    .vsync (vsync),
    .disp_state (disp_state)
);

bar_pic bar_pic_inst(
    .vga_clk (vga_clk),
    .sys_rst_n (sys_rst_n),
    .pix_x (pix_x),
    .pix_y (pix_y),
    .pix_data (bar_data)
);

MUST_pic MUST_pic_inst(
    .vga_clk (vga_clk),
    .sys_rst_n (sys_rst_n),
    .pix_x (pix_x),
    .pix_y (pix_y),
    .pix_data (must_data)
);

end_pic end_pic_inst(
    .vga_clk (vga_clk),
    .sys_rst_n (sys_rst_n),
    .pix_x (pix_x),
    .pix_y (pix_y),
    .pix_data (end_data)
);

//the shown screen selects one of the three registered colours
always@(*) begin
  case(disp_state)
      S_BARS: pix_data = bar_data;
      S_MUST: pix_data = must_data;
      S_END: pix_data = end_data;
      default: pix_data = bar_data;
  endcase
end

vga_ctrl vga_ctrl_inst(
    .vga_clk (vga_clk),
    .sys_rst_n (sys_rst_n),
    .pix_data (pix_data),
    .pix_x (pix_x),
    .pix_y (pix_y),
    .hsync (hsync),
    .vsync (vsync),
    .rgb (rgb)
);

endmodule
