// bộ CRC nhận và kiểm tra lỗi 

module crc_receiver (
    input  wire       clk,      
    input  wire       rst,       
    input  wire       ctrl_en,   
    input  wire       data_in,   
    input  wire [3:0] poly_in,  
    output wire [3:0] crc_seq,    
    output wire       crc_error 
);
// giống như bộ nhận nhưng có thêm 1 bit crc_error là bit xác định lỗi 
    // Tín hiệu kết nối nội bộ giữa các Cell tổ hợp và DFF
    wire [3:0] cell_next;
    
    // Đường feedback chính: Lấy bit cuối cùng (MSB) của chuỗi DFF XOR với bit dữ liệu vào
    wire fb_bit = crc_seq[3] ^ data_in;

    // --- KẾT NỐI CELL 0 ---
    wire cell0_fb = fb_bit & poly_in[0];
    crc_cell cell0 (.feedback(cell0_fb),.shift_in(1'b0),.next_bit(cell_next[0]));
    
    dff dff0 (.clk(clk),.rst(rst),.ctrl_en(ctrl_en),.d(cell_next[0]),.q(crc_seq[0]));

    // --- KẾT NỐI CELL 1 ---
    wire cell1_fb = fb_bit & poly_in[1];
    crc_cell cell1 (.feedback(cell1_fb),.shift_in(crc_seq[0]),.next_bit(cell_next[1]));
    
    dff dff1 (.clk(clk),.rst(rst),.ctrl_en(ctrl_en),.d(cell_next[1]),.q(crc_seq[1]));

    // --- KẾT NỐI CELL 2 ---
    wire cell2_fb = fb_bit & poly_in[2];
    crc_cell cell2 (.feedback(cell2_fb),.shift_in(crc_seq[1]),.next_bit(cell_next[2]));
    
    dff dff2 (.clk(clk),.rst(rst),.ctrl_en(ctrl_en),.d(cell_next[2]),.q(crc_seq[2]));

    // --- KẾT NỐI CELL 3 ---
    wire cell3_fb = fb_bit & poly_in[3];
    crc_cell cell3 (.feedback(cell3_fb),.shift_in(crc_seq[2]),.next_bit(cell_next[3]));
    
    dff dff3 (.clk(clk),.rst(rst),.ctrl_en(ctrl_en),.d(cell_next[3]),.q(crc_seq[3]));

    // --- KIỂM TRA LỖI CRC ---
    // Nếu toàn bộ 4 bit của crc_seq bằng 0000 -> crc_error = 0 (Không lỗi)
    // Nếu có bất kỳ bit nào bằng 1 -> crc_error = 1 (Có lỗi xảy ra)
    assign crc_error = (crc_seq != 4'b0000);

endmodule