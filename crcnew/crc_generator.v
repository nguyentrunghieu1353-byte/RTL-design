// module gửi 

module crc_generator (
    input  wire       clk,       // xung clock 
    input  wire       rst,       // bit reset 
    input  wire       ctrl_en,   // cho phép dịch dữ liệu
    input  wire       data_in,   // dữ liệu đầu vào 
    input  wire [3:0] poly_in,   // đa thức sinh 
    output wire [3:0] crc_seq    // mã CRC 4-bit đầu ra (chính là trạng thái của 4 DFF)
);

    // Tín hiệu kết nối giữa các cell và DFF
    wire [3:0] cell_next;
    
    //  đường feedback chính của mạch 
    wire fb_bit = crc_seq[3] ^ data_in;

    // Cell 0 nhận dữ liệu vào từ fb_bit. Do là tầng đầu tiên nên shift_in = 1'b0.
    // Nếu bit đa thức poly_in[0] = 1, nó sẽ XOR fb_bit. Nếu poly_in[0] = 0, nó giữ nguyên.
    wire cell0_fb = fb_bit & poly_in[0];
    crc_cell cell0 (.feedback(cell0_fb),.shift_in(1'b0),.next_bit(cell_next[0]));
    
    dff dff0 (.clk(clk),.rst(rst),.ctrl_en(ctrl_en),.d(cell_next[0]),.q(crc_seq[0]));

    // cell1 Nhận shift_in từ đầu ra của dff0
    wire cell1_fb = fb_bit & poly_in[1];
    crc_cell cell1 (.feedback(cell1_fb),.shift_in(crc_seq[0]),.next_bit(cell_next[1]));
    
    dff dff1 (.clk(clk),.rst(rst),.ctrl_en(ctrl_en),.d(cell_next[1]),.q(crc_seq[1]));

    //cell2 Nhận shift_in từ đầu ra của dff1
    wire cell2_fb = fb_bit & poly_in[2];
    crc_cell cell2 (.feedback(cell2_fb),.shift_in(crc_seq[1]),.next_bit(cell_next[2]));
    
    dff dff2 (.clk(clk),.rst(rst),.ctrl_en(ctrl_en),.d(cell_next[2]),.q(crc_seq[2]));


    //cell3 Nhận shift_in từ đầu ra của dff2
    wire cell3_fb = fb_bit & poly_in[3];
    crc_cell cell3 (.feedback(cell3_fb),.shift_in(crc_seq[2]),.next_bit(cell_next[3]));
    
    dff dff3 (.clk(clk),.rst(rst),.ctrl_en(ctrl_en),.d(cell_next[3]),.q(crc_seq[3]));

endmodule