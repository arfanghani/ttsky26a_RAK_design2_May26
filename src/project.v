`default_nettype none

module tt_um_arfanghani_design2_top (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    wire [1:0] mode = {ui_in[0], uio_in[0]};

    wire [7:0] A = ui_in;
    wire [7:0] B = uio_in;

    reg [7:0] prev;

    // FIR
    wire [9:0] fir_sum = {2'b00, A} + ({2'b00, B} << 1) + {2'b00, prev};
    wire [7:0] fir_out = fir_sum[9:2];

    // MAC
    wire [3:0] Ah = A[7:4];
    wire [3:0] Bh = B[7:4];
    wire [7:0] mac_out = (Ah * Bh) + prev;

    // EDGE
    wire [7:0] edge_out = A ^ prev;

    // NONLINEAR
    reg [2:0] shift;
    always @(*) begin
        if (A[7]) shift = 3'd4;
        else if (A[6]) shift = 3'd3;
        else if (A[5]) shift = 3'd2;
        else if (A[4]) shift = 3'd1;
        else shift = 3'd0;
    end

    wire [7:0] nonlinear_out = A >> shift;

    reg [7:0] result;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result <= 0;
            prev   <= 0;
        end else if (ena) begin
            case (mode)
                2'b00: result <= fir_out;
                2'b01: result <= mac_out;
                2'b10: result <= edge_out;
                2'b11: result <= nonlinear_out;
            endcase

            prev <= result;
        end
    end

    assign uo_out  = result;
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

endmodule
