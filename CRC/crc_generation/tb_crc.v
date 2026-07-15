`timescale 1ns / 1ps

module tb_crc;

    // =================================================================
    // VÙNG CẤU HÌNH DUY NHẤT: BẠN CHỈ CẦN SỬA TẠI ĐÂY KHI MUỐN ĐỔI CRC
    // =================================================================
    parameter TEST_CRC_WIDTH = 16;               // Bước 1: Đổi thành 4, 8, 16, 32 tùy ý
    wire [31:0]          CONFIG_POLY = 32'h1021;  // Bước 2: Nhập đa thức tương ứng dạng Hex
                                                // CRC-4 (x^4+x+1)   -> poly = 32'h03 (hoặc 4'b0011)
                                                // CRC-8 (x^8+x^2+x+1)-> poly = 32'h07 (hoặc 8'b00000111)

    parameter CLK_PERIOD = 10; 

    // --- Các dây kết nối tự động co giãn theo TEST_CRC_WIDTH ---
    reg                   clk;
    reg                   rst;
    reg                   ctrl_en;
    reg                   tx_data_in; 
    reg                   rx_data_in; 
    reg  [31:0]           poly_in;    // Luôn giữ 32-bit ở mức testbench

    wire [TEST_CRC_WIDTH-1:0]  gen_crc_seq;  
    wire [TEST_CRC_WIDTH-1:0]  recv_crc_seq; 
    wire                       crc_error;

    // --- Ghi đè tham số TEST_CRC_WIDTH vào module tổng quát ---
    crc_generic #(.CRC_WIDTH(TEST_CRC_WIDTH)) u_crc_top (
        .clk(clk), .rst(rst), .ctrl_en(ctrl_en),
        .tx_data_in(tx_data_in), .rx_data_in(rx_data_in), 
        .poly_in(poly_in), // Đẩy nguyên khung 32-bit vào, module tự cắt gọn
        .tx_crc_seq(gen_crc_seq), .rx_crc_seq(recv_crc_seq), .crc_error(crc_error)
    );

    always #(CLK_PERIOD/2) clk = ~clk; 

    integer i;
    reg [7:0] test_data;
    reg [TEST_CRC_WIDTH-1:0] captured_crc;

    task reset_system;
        begin
            @(posedge clk); rst = 1;
            #(CLK_PERIOD);
            @(posedge clk); rst = 0;
            #(CLK_PERIOD);
        end
    endtask

    initial begin
        // Nạp cấu hình từ vùng cấu hình trung tâm
        clk        = 0;
        rst        = 1;
        ctrl_en    = 0;
        tx_data_in = 0;
        rx_data_in = 0;
        poly_in    = CONFIG_POLY; 
        test_data  = 8'b10110110; // Dữ liệu test
        
        #(CLK_PERIOD * 2);
        rst = 0;
        #(CLK_PERIOD);

        $display("=== DANG CHAY MO PHONG VOI CRC-%0d THIET LAP TU TESTBENCH ===", TEST_CRC_WIDTH);
        
        // --- 1. Tạo CRC ---
        ctrl_en = 1;
        for (i = 7; i >= 0; i = i - 1) begin
            tx_data_in = test_data[i]; #(CLK_PERIOD); 
        end
        ctrl_en = 0; tx_data_in = 0;
        captured_crc = gen_crc_seq;
        $display("[TX] CRC sinh ra: %b", captured_crc);

        // --- 2. Bộ nhận kiểm tra dữ liệu ĐÚNG ---
        reset_system();
        ctrl_en = 1;
        for (i = 7; i >= 0; i = i - 1) begin rx_data_in = test_data[i]; #(CLK_PERIOD); end 
        for (i = TEST_CRC_WIDTH - 1; i >= 0; i = i - 1) begin rx_data_in = captured_crc[i]; #(CLK_PERIOD); end 
        ctrl_en = 0; rx_data_in = 0;
        $display("[RX] ket qua du lieu chuan -> crc_error = %b (mong doi: 0)", crc_error);

        // --- 3. Bộ nhận kiểm tra dữ liệu SAI ---
        $display("\n=== THU NGHIEM LOI DUONG TRUYEN ===");
        reset_system();
        ctrl_en = 1;
        test_data = 8'b10110001; // Fake data bị lỗi bit
        for (i = 7; i >= 0; i = i - 1) begin rx_data_in = test_data[i]; #(CLK_PERIOD); end
        for (i = TEST_CRC_WIDTH - 1; i >= 0; i = i - 1) begin rx_data_in = captured_crc[i]; #(CLK_PERIOD); end
        ctrl_en = 0; rx_data_in = 0;
        $display("[RX] KET QUA DU LIEU LOI -> crc_error = %b (MONG DOI: 1)", crc_error);

        #(CLK_PERIOD * 5);
        $finish;
    end
endmodule