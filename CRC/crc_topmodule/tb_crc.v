`timescale 1ns / 1ps

module tb_crc;

    // --- 1. CÁC TÍN HIỆU KẾT NỐI VỚI TOP MODULE ---
    reg        clk;
    reg        rst;
    reg        ctrl_en;
    reg        tx_data_in; // Đường dữ liệu riêng cho bộ phát
    reg        rx_data_in; // Đường dữ liệu riêng cho bộ nhận
    reg  [2:0] poly_in;

    // Các ngõ ra từ Top Module
    wire [3:0] gen_crc_seq;
    wire [3:0] recv_crc_seq;
    wire       crc_error;

    // --- 2. KHỞI TẠO TOP MODULE (KẾT NỐI CHÍNH XÁC) ---
    crc_top u_crc_top (
        .clk(clk),
        .rst(rst),
        .ctrl_en(ctrl_en),
        .tx_data_in(tx_data_in),
        .rx_data_in(rx_data_in),
        .poly_in(poly_in),
        .tx_crc_seq(gen_crc_seq),
        .rx_crc_seq(recv_crc_seq),
        .crc_error(crc_error)
    );

    // --- 3. TẠO XUNG NHỊP (CLOCK) ---
    always #5 clk = ~clk; // Chu kỳ T = 10ns

    // Biến phụ để chạy vòng lặp dịch dữ liệu
    integer i;
    reg [7:0] test_data;
    reg [3:0] captured_crc;

    // --- 4. KỊCH BẢN MÔ PHỎNG ---
    initial begin
        // Khởi tạo trạng thái ban đầu
        clk        = 0;
        rst        = 1;
        ctrl_en    = 0;
        tx_data_in = 0;
        rx_data_in = 0;
        poly_in    = 4'b011; 
        test_data  = 8'b10110110; // Dữ liệu gốc
        
        #20;
        rst = 0; // Thôi reset
        #10;

        // =================================================================
        // TEST 1: Gửi Data -> Sinh CRC -> Gửi Data + CRC đúng -> Không lỗi
        // =================================================================
        $display("--- Bat dau truyen du lieu dung (TEST 1) ---");
        
        // 1. Kích hoạt mạch và dịch 8 bit Data vào Generator để tạo CRC
        ctrl_en = 1;
        for (i = 7; i >= 0; i = i - 1) begin
            tx_data_in = test_data[i]; // Dịch vào bộ phát
            #10; 
        end
        
        // 2. Tắt enable, lưu lại mã CRC vừa tạo được từ bộ phát
        ctrl_en = 0;
        captured_crc = gen_crc_seq;
        $display("[GEN] Data goc: %b", test_data);
        $display("[GEN] Ma CRC sinh ra: %b", captured_crc);
        #20;

        // 3. Reset hệ thống (đặc biệt là để xóa bộ nhận về trạng thái ban đầu)
        $display("[SYSTEM] Dang reset de chuan bi nhan...");
        rst = 1;
        #10;
        rst = 0;
        #10;

        // 4. Gửi chuỗi Data gốc vào Receiver
        $display("[RECV] Dang gui chuoi Data vao Receiver...");
        ctrl_en = 1;
        for (i = 7; i >= 0; i = i - 1) begin
            rx_data_in = test_data[i]; // Chỉ đẩy vào Receiver, TX lúc này không quan trọng
            #10;
        end

        // 5. Gửi tiếp 4 bit CRC vừa lưu vào Receiver
        $display("[RECV] Dang gui tiep 4 bit CRC: %b vao Receiver...", captured_crc);
        for (i = 3; i >= 0; i = i - 1) begin
            rx_data_in = captured_crc[i];
            #10;
        end

        // 6. Dừng dịch và kiểm tra kết quả lỗi
        ctrl_en = 0;
        rx_data_in = 0;
        #5; // Lệch pha một chút để đọc giá trị ổn định sau cạnh clock
        $display("[RESULT] Trang thai cac DFF nhan: %b", recv_crc_seq);
        $display("[RESULT] Gia tri crc_error = %b (Mong doi: 0)", crc_error);
        if (crc_error == 0) 
            $display("-> TEST 1 thanh cong!\n");
        else 
            $display("-> TEST 1 that bai!\n");
        
        #40;

        // =================================================================
        // TEST 2: Lật 1 bit của Data -> Gửi Data lỗi + CRC -> Báo lỗi
        // =================================================================
        $display("--- Bat dau truyen du lieu sai (TEST 2) ---");
        
        // Thay đổi test_data thành chuỗi bị lỗi bit (lật bit thứ 4 từ 1 thành 0)
        test_data = 8'b10100110; 
        
        // 1. Reset hệ thống trước khi test lượt mới
        rst = 1;
        #10;
        rst = 0;
        #10;

        // 2. Gửi chuỗi Data đã bị LỖI vào Receiver
        $display("[RECV] Dang gui chuoi Data BI LOI: %b vao Receiver...", test_data);
        ctrl_en = 1;
        for (i = 7; i >= 0; i = i - 1) begin
            rx_data_in = test_data[i];
            #10;
        end

        // 3. Gửi tiếp chuỗi CRC cũ (mã CRC chuẩn của data đúng lúc nãy) vào Receiver
        $display("[RECV] Dang gui tiep 4 bit CRC cu: %b vao Receiver...", captured_crc);
        for (i = 3; i >= 0; i = i - 1) begin
            rx_data_in = captured_crc[i];
            #10;
        end

        // 4. Dừng dịch và kiểm tra kết quả lỗi
        ctrl_en = 0;
        rx_data_in = 0;
        #5;
        $display("[RESULT] Trang thai cac DFF nhan: %b", recv_crc_seq);
        $display("[RESULT] Gia tri crc_error = %b (Mong doi: 1)", crc_error);
        if (crc_error == 1) 
            $display("-> TEST 2 thanh cong!\n");
        else 
            $display("-> TEST 2 that bai!\n");

        #20;
        $finish; // Kết thúc mô phỏng
    end

endmodule