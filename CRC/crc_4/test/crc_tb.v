`timescale 1ns/1ps

module crc_tb();

    reg        clk;
    reg        rst_n;
    reg        ctrl_en;
    reg        data_in;
    reg        chk_en;
    reg  [3:0] poly_in;     
    
    wire       crc_error;
    wire [3:0] crc_seq;

    // FIX LỖI 1: Đổi tên từ crc_4_configurable về đúng tên 'crc' của file thiết kế
    crc uut (
        .clk(clk),
        .rst_n(rst_n),
        .ctrl_en(ctrl_en),
        .data_in(data_in),
        .chk_en(chk_en),
        .poly_in(poly_in),
        .crc_error(crc_error),
        .crc_seq(crc_seq)
    );

    // Tạo xung Clock 100MHz
    always #5 clk = ~clk;

    reg [3:0] temp_crc;
    integer i;

    task send_and_check_packet(input [7:0] data_payload, input [3:0] polynomial);
        begin
            poly_in = polynomial;

            // --- GIAI ĐOẠN 1: SENDER (TÍNH CRC) ---
            $display("\n==================================================");
            $display("[TEST RUN] Da thuc sinh: 4'b%b, Du lieu: 8'b%b", polynomial, data_payload);
            
            rst_n = 0; #10; rst_n = 1; #10;
            
            // Dịch 8 bit dữ liệu gốc
            ctrl_en = 1;
            for (i = 7; i >= 0; i = i - 1) begin
                data_in = data_payload[i];
                @(posedge clk);
            end
            // Dịch thêm 4 bit 0 để lấy số dư
            for (i = 0; i < 7; i = i + 1) begin
                data_in = 1'b0;
                @(posedge clk);
            end
            
            ctrl_en = 0;
            #1; // FIX LỖI 2: Chờ 1ns để dữ liệu mạch ổn định trước khi lấy mẫu
            temp_crc = crc_seq; 
            $display("[SENDER] -> Ma CRC-4 tinh duoc: 4'b%b", temp_crc);
            #20;

            // --- GIAI ĐOẠN 2: RECEIVER (KIỂM TRA) ---
            rst_n = 0; #10; rst_n = 1; #10; 
            
            // Dịch lại 8 bit dữ liệu gốc
            ctrl_en = 1;
            for (i = 3; i >= 0; i = i - 1) begin
                data_in = data_payload[i];
                @(posedge clk);
            end
            // Dịch tiếp 4 bit CRC kèm theo
            for (i = 3; i >= 0; i = i - 1) begin
                data_in = temp_crc[i];
                @(posedge clk);
            end
            
            ctrl_en = 0;
            chk_en  = 1; // Bật bộ kiểm tra lỗi
            @(posedge clk);
            #1; // Chờ tín hiệu kiểm tra xuất ra ổn định
            
            if (crc_error == 1'b0)
                $display("[RESULT] SUCCESS: Chuoi dung, khong co loi! (crc_error = %b)", crc_error);
            else
                $display("[RESULT] ERROR: Chuoi bi thong bao loi! (crc_error = %b)", crc_error);
            chk_en = 0;
            #20;
        end
    endtask

    initial begin
        clk     = 0;
        rst_n   = 0;
        ctrl_en = 0;
        data_in = 0;
        chk_en  = 0;
        poly_in = 4'b0000;
        #20;

        // KỊCH BẢN 1: Dữ liệu 10100010 với đa thức x^4 + x + 1 (4'b0011)
        send_and_check_packet(8'b10100010, 4'b0011);
        // KỊCH BẢN 2: Dữ liệu 11110000 với cùng đa thức
        send_and_check_packet(8'b11110000, 4'b0011);
        // KỊCH BẢN 3: Đổi hẳn sang một ĐA THỨC SINH KHÁC (4'b0101)
        send_and_check_packet(8'b10100010, 4'b0101);

        $display("\n==================================================");
        $display("[FINISH] Hoan thanh tat ca cac kich ban mo phong.");
        $finish;
    end

endmodule