`timescale 1ns / 1ns

module key_filter(
    input wire vga_clk,
    input wire sys_rst_n,
    input wire key_in,          //switching button, active low, bounces

    output reg key_flag,        //debounced button level (0 = pressed)
    output wire key_press       //one-clock pulse per accepted click
);

//20 ms at 25 MHz: 20e-3 * 25e6 = 500,000 clocks; 2^18 < 500,000 <= 2^19 -> 19 bits
parameter CNT_MAX = 19'd500_000;

reg key_d1;
reg key_d2;
reg [18:0] cnt_20ms;
reg key_flag_d;

//two-flop synchroniser: key_in is asynchronous to vga_clk
always@(posedge vga_clk or negedge sys_rst_n) begin
  if (!sys_rst_n) begin
     key_d1 <= 1'b1;
     key_d2 <= 1'b1;
  end
  else begin
     key_d1 <= key_in;
     key_d2 <= key_d1;
  end
end

//any bounce back to the accepted level restarts the 20 ms window
always@(posedge vga_clk or negedge sys_rst_n) begin
  if (!sys_rst_n)
     cnt_20ms <= 19'd0;
  else if (key_d2 == key_flag)
     cnt_20ms <= 19'd0;
  else if (cnt_20ms == CNT_MAX - 1'b1)
     cnt_20ms <= 19'd0;
  else
     cnt_20ms <= cnt_20ms + 1'b1;
end

//accept the new level after 20 ms without a change;
//reset value 0: a key held through reset cannot produce a click
always@(posedge vga_clk or negedge sys_rst_n) begin
  if (!sys_rst_n)
     key_flag <= 1'b0;
  else if (cnt_20ms == CNT_MAX - 1'b1)
     key_flag <= key_d2;
  else
     key_flag <= key_flag;
end

//falling edge of the debounced level = one click
always@(posedge vga_clk or negedge sys_rst_n) begin
  if (!sys_rst_n)
     key_flag_d <= 1'b0;
  else
     key_flag_d <= key_flag;
end

assign key_press = (key_flag_d == 1'b1) && (key_flag == 1'b0);

endmodule
