`timescale 1ns/1ps

module tb_crc_4_fixed();


    reg        clk;
    reg        rst_n;
    reg        ctrl_en;
    reg        data_in;
    reg        chk_en;
    
    wire       crc_error;
    wire [3:0] crc_seq;


    crc_4_fixed uut (
        .clk(clk),
        .rst_n(rst_n),
        .ctrl_en(ctrl_en),
        .data_in(data_in),
        .chk_en(chk_en),
        .crc_error(crc_error),
        .crc_seq(crc_seq)
    );

    always #5 clk = ~clk;


    reg [7:0] test_data;
    reg [3:0] generated_crc;
    integer i;

    initial begin
  
        clk     = 0;
        rst_n   = 0;
        ctrl_en = 0;
        data_in = 0;
        chk_en  = 0;
        test_data = 8'b10100010;
        #15 rst_n = 1; 
        #10;

      
        $display("[SENDER] Bat dau tinh toan CRC cho chuoi du lieu: %b", test_data);
        
      
        ctrl_en = 1;
        for (i = 7; i >= 0; i = i - 1) begin
            data_in = test_data[i];
            @(posedge clk);
        end
        
        
        for (i = 0; i < 4; i = i + 1) begin
            data_in = 1'b0;
            @(posedge clk);
        end
        
        
        ctrl_en = 0;
        generated_crc = crc_seq;
        $display("[SENDER] Ket qua CRC-4 thu duoc la: %b", generated_crc);
        #20;

     
        rst_n = 0; #10; rst_n = 1; #10;

   
        $display("[RECEIVER] Bat dau kiem tra chuoi truyen nhan...");
        
        
        ctrl_en = 1;
        for (i = 7; i >= 0; i = i - 1) begin
            data_in = test_data[i];
            @(posedge clk);
        end
        
        for (i = 3; i >= 0; i = i - 1) begin
            data_in = generated_crc[i];
            @(posedge clk);
        end
        
        ctrl_en = 0;
        chk_en  = 1;
        @(posedge clk); 
        
        if (crc_error == 1'b0)
            $display("[RESULT] CHINH XAC: Kiem tra thanh cong, khong co loi! (crc_error = %b)", crc_error);
        else
            $display("[RESULT] CANH BAO: Chuoi nhan bi loi! (crc_error = %b)", crc_error);

        #40;
        $finish; 
    end

endmodule