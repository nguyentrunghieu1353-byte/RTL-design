`timescale 1ns/1ps

module tb_crc_parametric();
// ở module các giá trị được đặt là wire vì là nơi nhận giá trị 
// còn ở tb các giá trị này được gán reg để được hiểu là giá trị truyền đi 
    reg        clk;
    reg        rst_n;
    reg        ctrl_en;
    reg        data_in;
    reg        chk_en;
    integer    i;

    reg  [3:0] poly_in_4;
    wire       crc_error_4;
    wire [3:0] crc_seq_4;

    // gán các giá trị test vào module 
    crc_parametric #(.CRC_WIDTH(4)) uut_crc4 (
        .clk(clk), .rst_n(rst_n), .ctrl_en(ctrl_en), .data_in(data_in), .chk_en(chk_en),
        .poly_in(poly_in_4), .crc_error(crc_error_4), .crc_seq(crc_seq_4)
    );

    reg  [7:0] poly_in_8;
    wire       crc_error_8;
    wire [7:0] crc_seq_8;

    crc_parametric #(.CRC_WIDTH(8)) uut_crc8 (
        .clk(clk), .rst_n(rst_n), .ctrl_en(ctrl_en), .data_in(data_in), .chk_en(chk_en),
        .poly_in(poly_in_8), .crc_error(crc_error_8), .crc_seq(crc_seq_8)
    );

    always #5 clk = ~clk; // thiết lập xung clock 5ns đổi 1 lần 

    reg [3:0] saved_crc4;  // khai báo các biến để lưu trữ kết quả 
    reg [7:0] saved_crc8;
    reg [7:0] test_payload;// để lưu input muốn thêm vào 

    initial begin
        
        clk = 0; rst_n = 0; ctrl_en = 0; data_in = 0; chk_en = 0;
        // thời điểm bắt đầu tất cả về 0 và nhấn rst 
        poly_in_4 = 4'b0011; 
        poly_in_8 = 8'h07;   
        test_payload = 8'b10100010; 
        
        #20 rst_n = 1; #10; // chờ 20ns để nhả rst và thêm 10ns để tín hiệu ổn định 

        $display("\n==================================================");
        $display("bat dau mo phong crc ") ; 
        $display("Chuoi du lieu goc truyen vao: 8'b%b", test_payload);
        $display("==================================================");
        $display("\ndau tien tao crc cho crc 4 vaf crc 8 ");
        ctrl_en = 1; // bắt đầu cho phép dịch các bit 
        
        //gán chuỗi mong muốn cào data in 
        for (i = 7; i >= 0; i = i - 1) begin // nạp bit vào thanh ghi theo chiều từ phải sang trái 
            data_in = test_payload[i];
            @(posedge clk); // có cạnh lên mới được thực hiện 
        end
        
        // tạo các bit 0 cuối chuỗi 
        for (i = 1; i <= 8; i = i + 1) begin
            data_in = 1'b0;   // đẩy các bit 0 vào sau data in để thành chuỗi
            if (i == 4) begin
                #1; // delay 1 ti giup on dinh
                saved_crc4 = crc_seq_4; // lưu crc đã tính được 
            end
            @(posedge clk);
        end
        ctrl_en = 0;
        saved_crc8 = crc_seq_8; 
        
        $display("-> Ma CRC-4 sinh ra: 4'b%b (Hex: %h)", saved_crc4, saved_crc4);
        $display("-> Ma CRC-8 sinh ra: 8'b%b (Hex: %h)", saved_crc8, saved_crc8);
        
        #30;

        $display("\n Kiem tra phia nhan doi voi CRC-4");
        rst_n = 0; #10; rst_n = 1; #10; // Reset lai cac ff 
        
        ctrl_en = 1; // cho phép ff chạy để dịch 
        // dich 8 bit dau
        for (i = 7; i >= 0; i = i - 1) begin
            data_in = test_payload[i];
            @(posedge clk);
        end
        // dich 4 bit sau 
        for (i = 3; i >= 0; i = i - 1) begin
            data_in = saved_crc4[i];
            @(posedge clk);
        end
        ctrl_en = 0; chk_en = 1; 
        @(posedge clk);
        
        if (crc_error_4 == 1'b0)
            $display("RESULT CRC-4 SUCCESS: mach 4 bit khong co loi " ) ; 
        else
            $display("RESULT CRC-4 ERROR: Mach 4-bit co loi "); 
        



        chk_en = 0; #30;

        $display("\nKiem tra phia nhan doi voi CRC-8");
        rst_n = 0; #10; rst_n = 1; #10; // reset lai cac ff 
        ctrl_en = 1;
        for (i = 7; i >= 0; i = i - 1) begin
            data_in = test_payload[i];
            @(posedge clk);
        end

        for (i = 7; i >= 0; i = i - 1) begin
            data_in = saved_crc8[i];
            @(posedge clk);
        end
        ctrl_en = 0; chk_en = 1; // mo bit kiem tra loi
        @(posedge clk);
        
        if (crc_error_8 == 1'b0)
            $display("RESULT CRC-8 SUCCESS: Mạch 8-bit khong co loi ");
        else
            $display("RESULT CRC-8 ERROR: Mach 8-bit co loi") ; 
            
        chk_en = 0;
        $display("==================================================");
        #40;
        $finish;
    end
    endmodule