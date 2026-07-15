// =================================================================
// 1. TOP MODULE KẾT NỐI SENDER VÀ RECEIVER (ĐÃ SỬA LOGIC GALOIS)
// =================================================================
module crc_top (
    input  wire       clk,        // Xung clock hệ thống
    input  wire       rst,        // Tín hiệu reset
    input  wire       ctrl_en,    // Cho phép dịch dữ liệu
    input  wire       tx_data_in, // Dữ liệu đầu vào của bộ phát
    input  wire       rx_data_in, // Dữ liệu đầu vào của bộ nhận
    input  wire [2:0] poly_in,    // Đa thức sinh cấu hình cổng XOR [2:0] (Ví dụ: x^4 + x + 1 -> poly_in = 3'b011)
    output wire [3:0] tx_crc_seq, // Mã CRC 4-bit đầu ra của bộ phát
    output wire [3:0] rx_crc_seq, // Trạng thái 4-bit bộ nhận
    output wire       crc_error   // Cờ báo lỗi từ bộ nhận (1: Lỗi, 0: OK)
);

    // Khởi tạo bộ phát CRC (Sender)
    crc_generator tx_inst (
        .clk(clk),
        .rst(rst),
        .ctrl_en(ctrl_en),
        .data_in(tx_data_in),
        .poly_in(poly_in),
        .crc_seq(tx_crc_seq)
    );

    // Khởi tạo bộ nhận CRC (Receiver)
    crc_receiver rx_inst (
        .clk(clk),
        .rst(rst),
        .ctrl_en(ctrl_en),
        .data_in(rx_data_in),
        .poly_in(poly_in),
        .crc_seq(rx_crc_seq),
        .crc_error(crc_error)
    );

endmodule


// =================================================================
// 2. CÁC MODULE THÀNH PHẦN (SUB-MODULES)
// =================================================================

// --- Khối Flip-Flop (DFF) ---
module dff (
    input  wire clk,      
    input  wire rst,      
    input  wire ctrl_en,  
    input  wire d,        
    output reg  q         
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= 1'b0;     
        end else if (ctrl_en) begin
            q <= d;        
        end
    end
endmodule

// --- Khối tổ hợp XOR (CRC Cell) ---
module crc_cell (
    input  wire feedback,  
    input  wire shift_in,  
    output wire next_bit   
);
    assign next_bit = feedback ^ shift_in;
endmodule

// --- Bộ phát CRC chuẩn Galois LFSR (CRC Generator) ---
module crc_generator (
    input  wire       clk,        
    input  wire       rst,        
    input  wire       ctrl_en,    
    input  wire       data_in,    
    input  wire [2:0] poly_in,    // Cấu hình XOR cho tầng 0, 1, 2
    output wire [3:0] crc_seq     // Thanh ghi trạng thái 4-bit
);
    // Tín hiệu kết nối ngõ vào cho dff0, dff1, dff2
    wire [2:0] cell_next;
    
    // Đường feedback chính: MSB (crc_seq[3]) XOR với data_in
    wire fb_bit = crc_seq[3] ^ data_in;

    // --- TẦNG 0: Nhận dịch vào bằng 0 ---
    wire cell0_fb = fb_bit & poly_in[0];
    crc_cell cell0 (.feedback(cell0_fb), .shift_in(1'b0), .next_bit(cell_next[0]));
    dff dff0 (.clk(clk), .rst(rst), .ctrl_en(ctrl_en), .d(cell_next[0]), .q(crc_seq[0]));

    // --- TẦNG 1: Nhận dịch vào từ dff0 ---
    wire cell1_fb = fb_bit & poly_in[1];
    crc_cell cell1 (.feedback(cell1_fb), .shift_in(crc_seq[0]), .next_bit(cell_next[1]));
    dff dff1 (.clk(clk), .rst(rst), .ctrl_en(ctrl_en), .d(cell_next[1]), .q(crc_seq[1]));

    // --- TẦNG 2: Nhận dịch vào từ dff1 ---
    wire cell2_fb = fb_bit & poly_in[2];
    crc_cell cell2 (.feedback(cell2_fb), .shift_in(crc_seq[1]), .next_bit(cell_next[2]));
    dff dff2 (.clk(clk), .rst(rst), .ctrl_en(ctrl_en), .d(cell_next[2]), .q(crc_seq[2]));

    // --- TẦNG 3 (TẦNG CUỐI): DỊCH THUẦN TÚY KHÔNG CÓ CỔNG XOR ---
    // Ngõ vào dff3 nối trực tiếp với ngõ ra của dff2 (crc_seq[2])
    dff dff3 (.clk(clk), .rst(rst), .ctrl_en(ctrl_en), .d(crc_seq[2]), .q(crc_seq[3]));

endmodule 

// --- Bộ nhận và kiểm tra lỗi chuẩn Galois LFSR (CRC Receiver) ---
module crc_receiver (
    input  wire       clk,      
    input  wire       rst,       
    input  wire       ctrl_en,   
    input  wire       data_in,   
    input  wire [2:0] poly_in,  
    output wire [3:0] crc_seq,    
    output wire       crc_error 
);
    wire [2:0] cell_next;
    wire fb_bit = crc_seq[3] ^ data_in;

    // --- TẦNG 0 ---
    wire cell0_fb = fb_bit & poly_in[0];
    crc_cell cell0 (.feedback(cell0_fb), .shift_in(1'b0), .next_bit(cell_next[0]));
    dff dff0 (.clk(clk), .rst(rst), .ctrl_en(ctrl_en), .d(cell_next[0]), .q(crc_seq[0]));

    // --- TẦNG 1 ---
    wire cell1_fb = fb_bit & poly_in[1];
    crc_cell cell1 (.feedback(cell1_fb), .shift_in(crc_seq[0]), .next_bit(cell_next[1]));
    dff dff1 (.clk(clk), .rst(rst), .ctrl_en(ctrl_en), .d(cell_next[1]), .q(crc_seq[1]));

    // --- TẦNG 2 ---
    wire cell2_fb = fb_bit & poly_in[2];
    crc_cell cell2 (.feedback(cell2_fb), .shift_in(crc_seq[1]), .next_bit(cell_next[2]));
    dff dff2 (.clk(clk), .rst(rst), .ctrl_en(ctrl_en), .d(cell_next[2]), .q(crc_seq[2]));

    // --- TẦNG 3 (TẦNG CUỐI): DỊCH THUẦN TÚY KHÔNG CÓ CỔNG XOR ---
    dff dff3 (.clk(clk), .rst(rst), .ctrl_en(ctrl_en), .d(crc_seq[2]), .q(crc_seq[3]));

    // Kiểm tra lỗi: Nếu toàn bộ 4 bit bằng 0 -> không lỗi (crc_error = 0)
    assign crc_error = (crc_seq != 4'b0000); 

endmodule