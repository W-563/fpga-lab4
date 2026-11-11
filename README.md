# FPGA Lab 4: Simple State Machine

EIE330 FPGA-based System Design, Lab 4.

| Folder | Task | Contents |
|---|---|---|
| RTL | Three-screen VGA controller (Color Bars, MUST, END) | Eight design modules (top `vga_screen.v`) + complete RTL views |
| sim | Module and top-level simulation | Seven testbenches + simulation data (CSV) + waveforms |

Clock: 50 MHz on `sys_clk`, divided to a 25 MHz pixel clock (`clk_25m`).
Screen sequence: Color Bars -> MUST -> END -> Color Bars, one transition per click of B2 (`key_in`, active-low, debounced for 20 ms).
Reset: B3 (`sys_rst_n`, active-low asynchronous reset), returns to Color Bars from any screen, including while the switching button is held.

Simulation (run inside the repository folder):

```bash
iverilog -o sim/tb_vga_screen.vvp -y RTL sim/tb_vga_screen.v
vvp sim/tb_vga_screen.vvp
gtkwave tb_vga_screen.vcd
```

For module tests, replace `tb_vga_screen` with `tb_key_filter`, `tb_screen_fsm`, `tb_screen_pic`, `tb_pll` or `tb_vga_ctrl`. For the continuous clean-click test, use `tb_vga_screen_clean`. The key-filter standalone test uses a 20 us window; the top-level test uses the full 20 ms window.

Synthesis:

```bash
yosys -p 'read_verilog RTL/*.v; proc; opt; stat vga_screen'
```

Board: Intel/Altera Cyclone IV EP4CE10F17C8N.
Virtual-board mapping: clk -> sys_clk, B3 -> sys_rst_n, B2 -> key_in, h_sync -> hsync, v_sync -> vsync, rgb -> rgb.

Tools: Icarus Verilog, Yosys, GTKWave, Simple-VGA-Simulator.

Group members: Zheng Mengxu, Wang Minglun, Ding Zhaoheng.

Board-test video: [Bilibili](https://www.bilibili.com/video/BV1KFWj6DEFf/).
