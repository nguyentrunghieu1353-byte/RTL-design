// khối phục vụ việc xor tính ra từng bit trong mạch gửi crc 

module crc_cell (
    input  wire feedback,  
    input  wire shift_in,  
    output wire next_bit   
);

    assign next_bit = feedback ^ shift_in;

endmodule