// =================================================================
// 1. TOP MODULE CRC TỔNG QUÁT (ĐỘ RỘNG POLY CỐ ĐỊNH 32-BIT)
// =================================================================
module crc_generic #(
    parameter CRC_WIDTH = 4 // Mặc định là 4 nếu Testbench không truyền gì vào
)(
    input  wire                   clk,        
    input  wire                   rst,        
    input  wire                   ctrl_en,    
    input  wire                   tx_data_in, 
    input  wire                   rx_data_in, 
    input  wire [31:0]            poly_in,    // SỬA THÀNH: Cố định 32-bit để Testbench dễ can thiệp
    output wire [CRC_WIDTH-1:0]   tx_crc_seq, 
    output wire [CRC_WIDTH-1:0]   rx_crc_seq, 
    output wire                   crc_error   
);
    crc_generator_generic #(.CRC_WIDTH(CRC_WIDTH)) tx_inst (
        .clk(clk), .rst(rst), .ctrl_en(ctrl_en),
        .data_in(tx_data_in), .poly_in(poly_in[CRC_WIDTH-1:0]), .crc_seq(tx_crc_seq) // Chỉ lấy số bit tương ứng
    );

    crc_receiver_generic #(.CRC_WIDTH(CRC_WIDTH)) rx_inst (
        .clk(clk), .rst(rst), .ctrl_en(ctrl_en),
        .data_in(rx_data_in), .poly_in(poly_in[CRC_WIDTH-1:0]), .crc_seq(rx_crc_seq),
        .crc_error(crc_error)
    );
endmodule

// =================================================================
// 2. BỘ PHÁT CRC TỔNG QUÁT GALOIS CHUẨN
// =================================================================
module crc_generator_generic #(
    parameter CRC_WIDTH = 4
)(
    input  wire                   clk,
    input  wire                   rst,
    input  wire                   ctrl_en,
    input  wire                   data_in,
    input  wire [CRC_WIDTH-1:0]   poly_in, // Giữ nguyên theo WIDTH bên trong
    output reg  [CRC_WIDTH-1:0]   crc_seq
);
    wire [CRC_WIDTH-1:0] cell_next;
    wire fb_bit = crc_seq[CRC_WIDTH-1] ^ data_in;

    genvar i;
    generate
        for (i = 0; i < CRC_WIDTH; i = i + 1) begin : g_crc_lanes
            if (i == 0) begin
                assign cell_next[0] = fb_bit;
            end 
            else begin
                assign cell_next[i] = poly_in[i] ? (crc_seq[i-1] ^ fb_bit) : crc_seq[i-1];
            end
        end
    endgenerate

    always @(posedge clk) begin
        if (rst)          crc_seq <= {CRC_WIDTH{1'b0}};
        else if (ctrl_en) crc_seq <= cell_next;
    end
endmodule

// =================================================================
// 3. BỘ NHẬN CRC TỔNG QUÁT GALOIS CHUẨN
// =================================================================
module crc_receiver_generic #(
    parameter CRC_WIDTH = 4
)(
    input  wire                   clk,
    input  wire                   rst,
    input  wire                   ctrl_en,
    input  wire                   data_in,
    input  wire [CRC_WIDTH-1:0]   poly_in,
    output reg  [CRC_WIDTH-1:0]   crc_seq,
    output wire                   crc_error
);
    wire [CRC_WIDTH-1:0] cell_next;
    wire fb_bit = crc_seq[CRC_WIDTH-1] ^ data_in;

    genvar i;
    generate
        for (i = 0; i < CRC_WIDTH; i = i + 1) begin : r_crc_lanes
            if (i == 0) begin
                assign cell_next[0] = fb_bit;
            end 
            else begin
                assign cell_next[i] = poly_in[i] ? (crc_seq[i-1] ^ fb_bit) : crc_seq[i-1];
            end
        end
    endgenerate

    always @(posedge clk) begin
        if (rst)          crc_seq <= {CRC_WIDTH{1'b0}};
        else if (ctrl_en) crc_seq <= cell_next;
    end

    assign crc_error = (cell_next != {CRC_WIDTH{1'b0}});
endmodule