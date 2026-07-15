`timescale 1ns / 1ps

module tb_crc;

    // --- CÁC TÍN HIỆU KẾT NỐI ---
    reg        clk;
    reg        rst;
    reg        ctrl_en;
    reg        data_in;
    reg  [3:0] poly_in;

    // Ngõ ra từ Generator
    wire [3:0] gen_crc_seq;
    
    // Ngõ ra từ Receiver
    wire [3:0] recv_crc_seq;
    wire       crc_error;

    // --- KHỞI TẠO MODULE PHÁT (GENERATOR) ---
    crc_generator u_generator (.clk(clk),.rst(rst),.ctrl_en(ctrl_en),.data_in(data_in),.poly_in(poly_in),.crc_seq(gen_crc_seq));

    // --- KHỞI TẠO MODULE NHẬN (RECEIVER) ---
    crc_receiver u_receiver (.clk(clk),.rst(rst),.ctrl_en(ctrl_en),.data_in(data_in),.poly_in(poly_in),.crc_seq(recv_crc_seq),.crc_error(crc_error));

    // --- TẠO XUNG NHỊP (CLOCK) ---
    always #5 clk = ~clk; // Chu kỳ T = 10ns

    // Biến phụ để chạy vòng lặp dịch dữ liệu
    integer i;
    reg [7:0] test_data;
    reg [3:0] captured_crc;

    // --- KỊCH BẢN MÔ PHỎNG ---
    initial begin
        // Khởi tạo trạng thái ban đầu
        clk     = 0;
        rst     = 1;
        ctrl_en = 0;
        data_in = 0;
        poly_in = 4'b0011; // Đa thức x^4 + x + 1
        test_data = 8'b10110110; // Dữ liệu gốc theo ví dụ của bạn
        
        #20;
        rst = 0; // Thôi reset
        #10;

        // =================================================================
        // TEST 1: Gửi Data -> Sinh CRC -> Gửi Data + CRC đúng -> Không lỗi
        // =================================================================
        $display("Bat dau truyen du lieu dung");
        
        // 1. Kích hoạt mạch và dịch 8 bit Data vào Generator để tạo CRC
        ctrl_en = 1;
        for (i = 7; i >= 0; i = i - 1) begin
            data_in = test_data[i];     // Dịch từ MSB đến LSB
            #10;                        // Chờ 1 chu kỳ clock
        end
        
        // 2. Tắt enable, lưu lại mã CRC vừa tạo được
        ctrl_en = 0;
        captured_crc = gen_crc_seq;
        $display("[GEN] Data goc: %b", test_data);
        $display("[GEN] Ma CRC sinh ra: %b", captured_crc);
        #20;

        // 3. Reset Receiver trước khi nhận dữ liệu mới
        $display("[RECV] Dang reset Receiver...");
        rst = 1;
        #10;
        rst = 0;
        #10;

        // 4. Gửi chuỗi Data gốc vào Receiver
        $display("[RECV] Dang gui chuoi Data vao Receiver...");
        ctrl_en = 1;
        for (i = 7; i >= 0; i = i - 1) begin
            data_in = test_data[i];
            #10;
        end

        // 5. Gửi tiếp 4 bit CRC vừa lưu vào Receiver
        $display("[RECV] Dang gui tiep 4 bit CRC: %b vao Receiver...", captured_crc);
        for (i = 3; i >= 0; i = i - 1) begin
            data_in = captured_crc[i];
            #10;
        end

        // 6. Dừng dịch và kiểm tra kết quả lỗi
        ctrl_en = 0;
        data_in = 0;
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
        $display("bat dau truyen du lieu sai");
        
        // Lật bit thứ 4 của dữ liệu gốc: từ 10110110 thành 10100110 giống ví dụ của bạn
        test_data = 8'b10100110; 
        
        // 1. Reset Receiver
        rst = 1;
        #10;
        rst = 0;
        #10;

        // 2. Gửi chuỗi Data đã bị LỖI vào Receiver
        $display("[RECV] Dang gui chuoi Data BI LOI: %b vao Receiver...", test_data);
        ctrl_en = 1;
        for (i = 7; i >= 0; i = i - 1) begin
            data_in = test_data[i];
            #10;
        end

        // 3. Gửi tiếp chuỗi CRC cũ (chuỗi CRC của data đúng) vào Receiver
        $display("[RECV] Dang gui tiep 4 bit CRC cu: %b vao Receiver...", captured_crc);
        for (i = 3; i >= 0; i = i - 1) begin
            data_in = captured_crc[i];
            #10;
        end

        // 4. Dừng dịch và kiểm tra kết quả lỗi
        ctrl_en = 0;
        data_in = 0;
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