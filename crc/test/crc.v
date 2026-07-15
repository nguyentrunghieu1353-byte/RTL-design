module crc (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       ctrl_en,    // 1 = Cho phép dịch dữ liệu vào để tính toán CRC
    input  wire       data_in,    // Bit dữ liệu nối tiếp dịch vào
    input  wire       chk_en,     // 1 = Kích hoạt kiểm tra lỗi khi dừng dịch
    input  wire [3:0] poly_in,    // Đa thức sinh cấu hình động truyền từ Testbench
    
    output reg        crc_error,  // 1 = Chuỗi nhận được bị lỗi CRC, 0 = Không lỗi
    output reg  [3:0] crc_seq     // Thanh ghi chứa 4 bit kết quả CRC
);

    // Tín hiệu nội bộ chứa giá trị kế tiếp của từng bit
    wire [3:0] crc_next;
    wire crc_msb = crc_seq[3]; // Bit phản hồi (MSB)

    // Khối Logic Tổ Hợp Cấu Hình Động: 
    // Sử dụng toán tử điều kiện để quyết định có qua cổng XOR hay không dựa vào poly_in
    assign crc_next[0] = poly_in[0] ? (crc_msb ^ data_in)    : data_in;
    assign crc_next[1] = poly_in[1] ? (crc_msb ^ crc_seq[0]) : crc_seq[0];
    assign crc_next[2] = poly_in[2] ? (crc_msb ^ crc_seq[1]) : crc_seq[1];
    assign crc_next[3] = poly_in[3] ? (crc_msb ^ crc_seq[2]) : crc_seq[2];

    // Khối Logic Tuần Tự: Cập nhật trạng thái thanh ghi dịch CRC
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            crc_seq <= 4'b0000;
        end 
        else begin
            if (ctrl_en)
                crc_seq <= crc_next;
            else
                crc_seq <= crc_seq;
        end
    end

    // Khối Kiểm Tra Lỗi (CRC Checker)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            crc_error <= 1'b0;
        end 
        else if (chk_en && !ctrl_en) begin
            if (crc_seq != 4'b0000)
                crc_error <= 1'b1;
            else
                crc_error <= 1'b0;
        end 
        else begin
            crc_error <= crc_error;
        end
    end

endmodule