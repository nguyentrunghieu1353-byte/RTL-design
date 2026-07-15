`timescale 1ns/1ps

module tb_crc_4_fixed();

    // Khai báo các tín hiệu kết nối với UUT (Unit Under Test)
    reg        clk;
    reg        rst_n;
    reg        ctrl_en;
    reg        data_in;
    reg        chk_en;
    
    wire       crc_error;
    wire [3:0] crc_seq;

    // Khởi tạo Module cần kiểm tra (UUT)
    crc_4_fixed uut (
        .clk(clk),
        .rst_n(rst_n),
        .ctrl_en(ctrl_en),
        .data_in(data_in),
        .chk_en(chk_en),
        .crc_error(crc_error),
        .crc_seq(crc_seq)
    );

    // Tạo xung Clock hệ thống (Chu kỳ 10ns -> Tần số 100MHz)
    always #5 clk = ~clk;

    // Khai báo các biến phục vụ vòng lặp dịch dữ liệu trong testbench
    reg [7:0] test_data;
    reg [3:0] generated_crc;
    integer i;

    initial begin
        // --- Bước 1: Khởi tạo ban đầu ---
        clk     = 0;
        rst_n   = 0;
        ctrl_en = 0;
        data_in = 0;
        chk_en  = 0;
        test_data = 8'b10100010; // Chuỗi dữ liệu mẫu từ tài liệu
        
        #15 rst_n = 1; // Nhả reset sau 15ns
        #10;

        // --- Bước 2: Quá trình TẠO giá trị CRC-4 ---
        $display("[SENDER] Bat dau tinh toan CRC cho chuoi du lieu: %b", test_data);
        
        // Dịch 8 bit dữ liệu gốc (từ MSB sang LSB)
        ctrl_en = 1;
        for (i = 7; i >= 0; i = i - 1) begin
            data_in = test_data[i];
            @(posedge clk);
        end
        
        // Dịch thêm 4 bit 0 cuối chuỗi theo nguyên lý (Hình 12)
        for (i = 0; i < 4; i = i + 1) begin
            data_in = 1'b0;
            @(posedge clk);
        end
        
        // Kết thúc quá trình dịch, lấy kết quả CRC thu được
        ctrl_en = 0;
        generated_crc = crc_seq;
        $display("[SENDER] Ket qua CRC-4 thu duoc la: %b", generated_crc);
        #20;

        // --- Bước 3: Reset lại mạch để giả lập phía NHẬN (Receiver) ---
        rst_n = 0; #10; rst_n = 1; #10;

        // --- Bước 4: Quá trình KIỂM TRA chuỗi nhận được (Có CRC kèm theo) ---
        $display("[RECEIVER] Bat dau kiem tra chuoi truyen nhan...");
        
        // Dịch lại 8 bit dữ liệu gốc ban đầu
        ctrl_en = 1;
        for (i = 7; i >= 0; i = i - 1) begin
            data_in = test_data[i];
            @(posedge clk);
        end
        
        // Dịch tiếp 4 bit mã CRC đã được tạo ở Bước 2 vào mạch
        for (i = 3; i >= 0; i = i - 1) begin
            data_in = generated_crc[i];
            @(posedge clk);
        end
        
        // Dừng dịch dữ liệu, bật tín hiệu kiểm tra lỗi chk_en
        ctrl_en = 0;
        chk_en  = 1;
        @(posedge clk); // Đợi 1 chu kỳ để mạch Checker cập nhật ngõ ra
        
        // In kết quả kiểm tra ra màn hình mô phỏng
        if (crc_error == 1'b0)
            $display("[RESULT] CHINH XAC: Kiem tra thanh cong, khong co loi! (crc_error = %b)", crc_error);
        else
            $display("[RESULT] CANH BAO: Chuoi nhan bi loi! (crc_error = %b)", crc_error);

        #40;
        $finish; // Kết thúc mô phỏng
    end

endmodule