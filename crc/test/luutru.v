module crc_parametric (
    parameter CRC_WIDTH = 4 // Mặc định là 4. Có thể ghi đè thành 8, 16, 32... từ Testbench
)(
    input  wire                   clk,
    input  wire                   rst_n,
    input  wire                   ctrl_en,    // 1 = Cho phép dịch dữ liệu tính toán CRC
    input  wire                   data_in,    // Bit dữ liệu nối tiếp dịch vào
    input  wire                   chk_en,     // 1 = Kích hoạt kiểm tra lỗi khi dừng dịch
    input  wire [CRC_WIDTH-1:0]   poly_in,    // Đa thức sinh cấu hình động (bỏ bit MSB cao nhất)
    
    output reg                    crc_error,  // 1 = Lỗi CRC, 0 = Không lỗi
    output reg  [CRC_WIDTH-1:0]   crc_seq     // Thanh ghi chứa kết quả CRC tự co giãn
);

    wire [CRC_WIDTH-1:0] crc_next;
    wire crc_msb = crc_seq[CRC_WIDTH-1]; // Luôn tự động lấy bit cao nhất của cấu trúc hiện tại làm đường phản hồi

    // Sử dụng vòng lặp generate để tự động sinh ra số lượng cổng XOR và đường dịch tương ứng theo cấu hình CRC_WIDTH
    genvar i;
    generate
        for (i = 0; i < CRC_WIDTH; i = i + 1) begin : crc_logic_grid
            if (i == 0) begin : bit_0
                assign crc_next[0] = poly_in[0] ? (crc_msb ^ data_in) : data_in;
            end else begin : bit_higher
                assign crc_next[i] = poly_in[i] ? (crc_msb ^ crc_seq[i-1]) : crc_seq[i-1];
            end
        end
    endgenerate

    // Khối tuần tự cập nhật giá trị cho thanh ghi dịch
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            crc_seq <= {CRC_WIDTH{1'b0}};
        end else begin
            if (ctrl_en)
                crc_seq <= crc_next;
            else
                crc_seq <= crc_seq;
        end
    end

    // Khối kiểm tra lỗi CRC
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            crc_error <= 1'b0;
        end else if (chk_en && !ctrl_en) begin
            if (crc_seq != {CRC_WIDTH{1'b0}})
                crc_error <= 1'b1;
            else
                crc_error <= 1'b0;
        end else begin
            crc_error <= crc_error;
        end
    end

endmodule