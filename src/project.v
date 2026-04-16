/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
module tt_um_top (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    // Mode select
    wire [1:0] mode;
    assign mode = {ui_in[0], uio_in[0]};

    wire [7:0] A;
    wire [7:0] B;

    assign A = ui_in;
    assign B = uio_in;

    // =========================
    // STATE
    // =========================
    reg [7:0] prev;

    // =========================
    // FIR FILTER
    // =========================
    wire [9:0] fir_sum;
    assign fir_sum = {2'b00, A} + ({2'b00, B} << 1) + {2'b00, prev};

    wire [7:0] fir_out;
    assign fir_out = fir_sum[9:2];

    // =========================
    // MAC (approx)
    // =========================
    wire [3:0] Ah;
    wire [3:0] Bh;

    assign Ah = A[7:4];
    assign Bh = B[7:4];

    wire [7:0] mult;
    assign mult = (Ah * Bh) << 2;

    wire [7:0] mac_out;
    assign mac_out = mult + prev;

    // =========================
    // EDGE DETECTOR
    // =========================
    wire [7:0] edge_out;
    assign edge_out = A ^ prev;

    // =========================
    // NONLINEAR
    // =========================
    reg [2:0] shift;

    always @(*) begin
        if (A[7]) shift = 3'd4;
        else if (A[6]) shift = 3'd3;
        else if (A[5]) shift = 3'd2;
        else if (A[4]) shift = 3'd1;
        else shift = 3'd0;
    end

    wire [7:0] nonlinear_out;
    assign nonlinear_out = A >> shift;

    // =========================
    // OUTPUT
    // =========================
    reg [7:0] result;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result <= 8'd0;
            prev   <= 8'd0;
        end else begin
            case (mode)
                2'b00: result <= fir_out;
                2'b01: result <= mac_out;
                2'b10: result <= edge_out;
                2'b11: result <= nonlinear_out;
                default: result <= 8'd0;
            endcase

            prev <= result;
        end
    end

    assign uo_out = result;

    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

endmodule
  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule
