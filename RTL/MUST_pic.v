`timescale 1ns / 1ns

module MUST_pic(
    input wire vga_clk,
    input wire sys_rst_n,
    input wire [9:0] pix_x,
    input wire [9:0] pix_y,

    output reg [15:0] pix_data
);

//white text on a black background
parameter BLACK = 16'h0000,
WHITE = 16'hFFFF;

//four centred 64x64 boxes with 32-pixel gaps
parameter [9:0] M_X = 10'd144,
U_X = 10'd240,
S_X = 10'd336,
T_X = 10'd432,
CHAR_Y = 10'd208,
CHAR_SIZE = 10'd64;

//one byte per row; bit 7 is the leftmost pixel
parameter [7:0] M_ROW_0 = 8'b11000011;
parameter [7:0] M_ROW_1 = 8'b11100111;
parameter [7:0] M_ROW_2 = 8'b11111111;
parameter [7:0] M_ROW_3 = 8'b11011011;
parameter [7:0] M_ROW_4 = 8'b11000011;
parameter [7:0] M_ROW_5 = 8'b11000011;
parameter [7:0] M_ROW_6 = 8'b11000011;
parameter [7:0] M_ROW_7 = 8'b11000011;
parameter [7:0] U_ROW_0 = 8'b11000011;
parameter [7:0] U_ROW_1 = 8'b11000011;
parameter [7:0] U_ROW_2 = 8'b11000011;
parameter [7:0] U_ROW_3 = 8'b11000011;
parameter [7:0] U_ROW_4 = 8'b11000011;
parameter [7:0] U_ROW_5 = 8'b11000011;
parameter [7:0] U_ROW_6 = 8'b01111110;
parameter [7:0] U_ROW_7 = 8'b00111100;
parameter [7:0] S_ROW_0 = 8'b01111110;
parameter [7:0] S_ROW_1 = 8'b11000000;
parameter [7:0] S_ROW_2 = 8'b11000000;
parameter [7:0] S_ROW_3 = 8'b01111100;
parameter [7:0] S_ROW_4 = 8'b00000110;
parameter [7:0] S_ROW_5 = 8'b00000011;
parameter [7:0] S_ROW_6 = 8'b11000011;
parameter [7:0] S_ROW_7 = 8'b01111110;
parameter [7:0] T_ROW_0 = 8'b11111111;
parameter [7:0] T_ROW_1 = 8'b11111111;
parameter [7:0] T_ROW_2 = 8'b00011000;
parameter [7:0] T_ROW_3 = 8'b00011000;
parameter [7:0] T_ROW_4 = 8'b00011000;
parameter [7:0] T_ROW_5 = 8'b00011000;
parameter [7:0] T_ROW_6 = 8'b00011000;
parameter [7:0] T_ROW_7 = 8'b00011000;

wire in_y;
wire [9:0] dy;
wire [2:0] char_y;
wire in_m;
wire [9:0] dx_m;
wire [2:0] col_m;
wire in_u;
wire [9:0] dx_u;
wire [2:0] col_u;
wire in_s;
wire [9:0] dx_s;
wire [2:0] col_s;
wire in_t;
wire [9:0] dx_t;
wire [2:0] col_t;

//share the vertical range; use local offsets inside each box
assign in_y = (pix_y >= CHAR_Y) && (pix_y < CHAR_Y + CHAR_SIZE);
assign dy = pix_y - CHAR_Y;

//fixed x8 scaling; bits [5:3] give row/column 0..7
assign char_y = dy[5:3];
assign in_m = in_y && (pix_x >= M_X) && (pix_x < M_X + CHAR_SIZE);
assign dx_m = pix_x - M_X;
assign col_m = dx_m[5:3];
assign in_u = in_y && (pix_x >= U_X) && (pix_x < U_X + CHAR_SIZE);
assign dx_u = pix_x - U_X;
assign col_u = dx_u[5:3];
assign in_s = in_y && (pix_x >= S_X) && (pix_x < S_X + CHAR_SIZE);
assign dx_s = pix_x - S_X;
assign col_s = dx_s[5:3];
assign in_t = in_y && (pix_x >= T_X) && (pix_x < T_X + CHAR_SIZE);
assign dx_t = pix_x - T_X;
assign col_t = dx_t[5:3];

//one colour register: matches the early request in vga_ctrl
always@(posedge vga_clk or negedge sys_rst_n) begin
  if (!sys_rst_n)
     pix_data <= 16'd0;
  else if(in_m) begin
     case(char_y)
         3'd0: pix_data <= M_ROW_0[3'd7 - col_m] ? WHITE : BLACK;
         3'd1: pix_data <= M_ROW_1[3'd7 - col_m] ? WHITE : BLACK;
         3'd2: pix_data <= M_ROW_2[3'd7 - col_m] ? WHITE : BLACK;
         3'd3: pix_data <= M_ROW_3[3'd7 - col_m] ? WHITE : BLACK;
         3'd4: pix_data <= M_ROW_4[3'd7 - col_m] ? WHITE : BLACK;
         3'd5: pix_data <= M_ROW_5[3'd7 - col_m] ? WHITE : BLACK;
         3'd6: pix_data <= M_ROW_6[3'd7 - col_m] ? WHITE : BLACK;
         3'd7: pix_data <= M_ROW_7[3'd7 - col_m] ? WHITE : BLACK;
         default: pix_data <= BLACK;
     endcase
  end
  else if(in_u) begin
     case(char_y)
         3'd0: pix_data <= U_ROW_0[3'd7 - col_u] ? WHITE : BLACK;
         3'd1: pix_data <= U_ROW_1[3'd7 - col_u] ? WHITE : BLACK;
         3'd2: pix_data <= U_ROW_2[3'd7 - col_u] ? WHITE : BLACK;
         3'd3: pix_data <= U_ROW_3[3'd7 - col_u] ? WHITE : BLACK;
         3'd4: pix_data <= U_ROW_4[3'd7 - col_u] ? WHITE : BLACK;
         3'd5: pix_data <= U_ROW_5[3'd7 - col_u] ? WHITE : BLACK;
         3'd6: pix_data <= U_ROW_6[3'd7 - col_u] ? WHITE : BLACK;
         3'd7: pix_data <= U_ROW_7[3'd7 - col_u] ? WHITE : BLACK;
         default: pix_data <= BLACK;
     endcase
  end
  else if(in_s) begin
     case(char_y)
         3'd0: pix_data <= S_ROW_0[3'd7 - col_s] ? WHITE : BLACK;
         3'd1: pix_data <= S_ROW_1[3'd7 - col_s] ? WHITE : BLACK;
         3'd2: pix_data <= S_ROW_2[3'd7 - col_s] ? WHITE : BLACK;
         3'd3: pix_data <= S_ROW_3[3'd7 - col_s] ? WHITE : BLACK;
         3'd4: pix_data <= S_ROW_4[3'd7 - col_s] ? WHITE : BLACK;
         3'd5: pix_data <= S_ROW_5[3'd7 - col_s] ? WHITE : BLACK;
         3'd6: pix_data <= S_ROW_6[3'd7 - col_s] ? WHITE : BLACK;
         3'd7: pix_data <= S_ROW_7[3'd7 - col_s] ? WHITE : BLACK;
         default: pix_data <= BLACK;
     endcase
  end
  else if(in_t) begin
     case(char_y)
         3'd0: pix_data <= T_ROW_0[3'd7 - col_t] ? WHITE : BLACK;
         3'd1: pix_data <= T_ROW_1[3'd7 - col_t] ? WHITE : BLACK;
         3'd2: pix_data <= T_ROW_2[3'd7 - col_t] ? WHITE : BLACK;
         3'd3: pix_data <= T_ROW_3[3'd7 - col_t] ? WHITE : BLACK;
         3'd4: pix_data <= T_ROW_4[3'd7 - col_t] ? WHITE : BLACK;
         3'd5: pix_data <= T_ROW_5[3'd7 - col_t] ? WHITE : BLACK;
         3'd6: pix_data <= T_ROW_6[3'd7 - col_t] ? WHITE : BLACK;
         3'd7: pix_data <= T_ROW_7[3'd7 - col_t] ? WHITE : BLACK;
         default: pix_data <= BLACK;
     endcase
  end
  else
     pix_data <= BLACK;
end

endmodule
