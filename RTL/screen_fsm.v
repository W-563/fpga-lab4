`timescale 1ns / 1ns

module screen_fsm(
    input wire vga_clk,
    input wire sys_rst_n,
    input wire key_press,         //one-clock pulse per click
    input wire vsync,             //high during the vertical sync lines

    output reg [1:0] disp_state   //screen shown in the current frame
);

//state encoding: three states in two bits
localparam S_BARS = 2'd0;
localparam S_MUST = 2'd1;
localparam S_END  = 2'd2;

reg [1:0] st_cur;
reg [1:0] st_next;

//state register: sequential logic, non-blocking assignment
always@(posedge vga_clk or negedge sys_rst_n) begin
  if (!sys_rst_n)
     st_cur <= S_BARS;
  else
     st_cur <= st_next;
end

//next state: combinational logic, blocking assignment, preset to avoid a latch
always@(*) begin
  st_next = st_cur;
  case(st_cur)
      S_BARS: if (key_press) st_next = S_MUST;
      S_MUST: if (key_press) st_next = S_END;
      S_END:  if (key_press) st_next = S_BARS;
      default: st_next = S_BARS;
  endcase
end

//Moore output register: the shown screen follows the state
always@(posedge vga_clk or negedge sys_rst_n) begin
  if (!sys_rst_n)
     disp_state <= S_BARS;
  else if (vsync)
     disp_state <= st_cur;
  else
     disp_state <= disp_state;
end

endmodule