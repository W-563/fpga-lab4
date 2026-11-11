`timescale 1ns / 1ns

module end_pic(
    input wire vga_clk,
    input wire sys_rst_n,
    input wire [9:0] pix_x,
    input wire [9:0] pix_y,

    output reg [15:0] pix_data
);

parameter BLACK = 16'h0000,
WHITE = 16'hFFFF;

//three centred 64x64 boxes with 32-pixel gaps: (640 - 3*64 - 2*32)/2 = 192
parameter [9:0] E_X = 10'd192,
N_X = 10'd288,
D_X = 10'd384,
CHAR_Y = 10'd208,
CHAR_SIZE = 10'd64;

//one byte per row; bit 7 is the leftmost pixel
parameter [7:0] E_ROW_0 = 8'b11111111;
parameter [7:0] E_ROW_1 = 8'b11111111;
parameter [7:0] E_ROW_2 = 8'b11000000;
parameter [7:0] E_ROW_3 = 8'b11111100;
parameter [7:0] E_ROW_4 = 8'b11111100;
parameter [7:0] E_ROW_5 = 8'b11000000;
parameter [7:0] E_ROW_6 = 8'b11111111;
parameter [7:0] E_ROW_7 = 8'b11111111;
parameter [7:0] N_ROW_0 = 8'b11000011;
parameter [7:0] N_ROW_1 = 8'b11100011;
parameter [7:0] N_ROW_2 = 8'b11110011;
parameter [7:0] N_ROW_3 = 8'b11011011;
parameter [7:0] N_ROW_4 = 8'b11001111;
parameter [7:0] N_ROW_5 = 8'b11000111;
parameter [7:0] N_ROW_6 = 8'b11000011;
parameter [7:0] N_ROW_7 = 8'b11000011;
parameter [7:0] D_ROW_0 = 8'b11111100;
parameter [7:0] D_ROW_1 = 8'b11111110;
parameter [7:0] D_ROW_2 = 8'b11000111;
parameter [7:0] D_ROW_3 = 8'b11000011;
parameter [7:0] D_ROW_4 = 8'b11000011;
parameter [7:0] D_ROW_5 = 8'b11000111;
parameter [7:0] D_ROW_6 = 8'b11111110;
parameter [7:0] D_ROW_7 = 8'b11111100;

wire in_y;
wire [9:0] dy;
wire [2:0] char_y;
wire in_e;
wire [9:0] dx_e;
wire [2:0] col_e;
wire in_n;
wire [9:0] dx_n;
wire [2:0] col_n;
wire in_d;
wire [9:0] dx_d;
wire [2:0] col_d;

//share the vertical range; use local offsets inside each box
assign in_y = (pix_y >= CHAR_Y) && (pix_y < CHAR_Y + CHAR_SIZE);
assign dy = pix_y - CHAR_Y;

//fixed x8 scaling; bits [5:3] give row/column 0..7
assign char_y = dy[5:3];
assign in_e = in_y && (pix_x >= E_X) && (pix_x < E_X + CHAR_SIZE);
assign dx_e = pix_x - E_X;
assign col_e = dx_e[5:3];
assign in_n = in_y && (pix_x >= N_X) && (pix_x < N_X + CHAR_SIZE);
assign dx_n = pix_x - N_X;
assign col_n = dx_n[5:3];
assign in_d = in_y && (pix_x >= D_X) && (pix_x < D_X + CHAR_SIZE);
assign dx_d = pix_x - D_X;
assign col_d = dx_d[5:3];

//one colour register: matches the early request in vga_ctrl
always@(posedge vga_clk or negedge sys_rst_n) begin
  if (!sys_rst_n)
     pix_data <= 16'd0;
  else if(in_e) begin
     case(char_y)
         3'd0: pix_data <= E_ROW_0[3'd7 - col_e] ? WHITE : BLACK;
         3'd1: pix_data <= E_ROW_1[3'd7 - col_e] ? WHITE : BLACK;
         3'd2: pix_data <= E_ROW_2[3'd7 - col_e] ? WHITE : BLACK;
         3'd3: pix_data <= E_ROW_3[3'd7 - col_e] ? WHITE : BLACK;
         3'd4: pix_data <= E_ROW_4[3'd7 - col_e] ? WHITE : BLACK;
         3'd5: pix_data <= E_ROW_5[3'd7 - col_e] ? WHITE : BLACK;
         3'd6: pix_data <= E_ROW_6[3'd7 - col_e] ? WHITE : BLACK;
         3'd7: pix_data <= E_ROW_7[3'd7 - col_e] ? WHITE : BLACK;
         default: pix_data <= BLACK;
     endcase
  end
  else if(in_n) begin
     case(char_y)
         3'd0: pix_data <= N_ROW_0[3'd7 - col_n] ? WHITE : BLACK;
         3'd1: pix_data <= N_ROW_1[3'd7 - col_n] ? WHITE : BLACK;
         3'd2: pix_data <= N_ROW_2[3'd7 - col_n] ? WHITE : BLACK;
         3'd3: pix_data <= N_ROW_3[3'd7 - col_n] ? WHITE : BLACK;
         3'd4: pix_data <= N_ROW_4[3'd7 - col_n] ? WHITE : BLACK;
         3'd5: pix_data <= N_ROW_5[3'd7 - col_n] ? WHITE : BLACK;
         3'd6: pix_data <= N_ROW_6[3'd7 - col_n] ? WHITE : BLACK;
         3'd7: pix_data <= N_ROW_7[3'd7 - col_n] ? WHITE : BLACK;
         default: pix_data <= BLACK;
     endcase
  end
  else if(in_d) begin
     case(char_y)
         3'd0: pix_data <= D_ROW_0[3'd7 - col_d] ? WHITE : BLACK;
         3'd1: pix_data <= D_ROW_1[3'd7 - col_d] ? WHITE : BLACK;
         3'd2: pix_data <= D_ROW_2[3'd7 - col_d] ? WHITE : BLACK;
         3'd3: pix_data <= D_ROW_3[3'd7 - col_d] ? WHITE : BLACK;
         3'd4: pix_data <= D_ROW_4[3'd7 - col_d] ? WHITE : BLACK;
         3'd5: pix_data <= D_ROW_5[3'd7 - col_d] ? WHITE : BLACK;
         3'd6: pix_data <= D_ROW_6[3'd7 - col_d] ? WHITE : BLACK;
         3'd7: pix_data <= D_ROW_7[3'd7 - col_d] ? WHITE : BLACK;
         default: pix_data <= BLACK;
     endcase
  end
  else
     pix_data <= BLACK;
end

endmodule