module crc_4_fixed (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       ctrl_en,    // 1 = Cho phép dịch dữ liệu vào để tính toán CRC
    input  wire       data_in,    // Bit dữ liệu nối tiếp dịch vào (mỗi chu kỳ 1 bit)
    input  wire       chk_en,     // 1 = Kích hoạt kiểm tra lỗi khi quá trình dịch kết thúc
    
    output reg        crc_error,  // 1 = Chuỗi nhận được bị lỗi CRC, 0 = Không lỗi
    output reg  [3:0] crc_seq     // Thanh ghi chứa 4 bit kết quả CRC [b3, b2, b1, b0]
);

    // Tín hiệu nội bộ chứa giá trị kế tiếp của từng bit trong thanh ghi
    wire [3:0] crc_next;

    // Bit cao nhất (MSB) của thanh ghi CRC hiện tại (b3) chính là đường phản hồi
    wire crc_msb = crc_seq[3];

    // Khối Logic Tổ Hợp: Đa thức x^4 + x + 1 (4'b0011 -> XOR tại bit 1 và bit 0)
    assign crc_next[0] = crc_msb ^ data_in;
    assign crc_next[1] = crc_msb ^ crc_seq[0];
    assign crc_next[2] = crc_seq[1];
    assign crc_next[3] = crc_seq[2];

    // Khối Logic Tuần Tự: Cập nhật trạng thái thanh ghi dịch CRC
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            crc_seq <= 4'b0000;
        end 
        else begin
            if (ctrl_en) begin
                crc_seq <= crc_next;
            end 
            else begin
                crc_seq <= crc_seq;
            end
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
//iverilog -o crc_sim -s tb_crc_4_fixed crc_4_fixed.v tb_crc_4_fixed.v 
//vvp crc_sim 