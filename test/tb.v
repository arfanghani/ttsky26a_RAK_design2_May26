`default_nettype none
`timescale 1ns / 1ps

module tb;

  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;

  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  tt_um_top dut (
      .ui_in(ui_in),
      .uio_in(uio_in),
      .uo_out(uo_out),
      .uio_out(uio_out),
      .uio_oe(uio_oe),
      .ena(ena),
      .clk(clk),
      .rst_n(rst_n)
  );

  always #5 clk = ~clk;

  // waveform dump
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    $dumpvars(1, dut);
  end

  initial begin
    clk = 0;
    rst_n = 0;
    ena = 0;
    ui_in = 0;
    uio_in = 0;

    #20;
    rst_n = 1;
    ena = 1;

    ui_in = 8'b00000010; uio_in = 8'b00000100; #40;
    ui_in = 8'b00000001; uio_in = 8'b00000001; #40;
    ui_in = 8'b00000100; uio_in = 8'b00000000; #40;
    ui_in = 8'b00000011; uio_in = 8'b00000001; #40;

   end

endmodule
