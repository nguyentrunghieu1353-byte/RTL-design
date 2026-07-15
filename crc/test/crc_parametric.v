module crc_parametric (
    clk,        // xung clock 
    rst_n,      // reset cac thanh ghi 
    ctrl_en,    // dung de cho phep dich du lieu tinh toan crc
    data_in,    // bit du lieu dau vao 
    chk_en,     // bit kich hoat kiem tra loi 
    poly_in,    // da thuc sinh 
    crc_error,  // bit crc 0 or 1 
    crc_seq     // thanh ghi chua chuoi crc 
);

   
    parameter CRC_WIDTH = 4;// do dai cua crc 
// parameter la mot dong hang so co the thay doi duoc 
    // du lieu vao module
    input  wire                   clk;
    input  wire                   rst_n;
    input  wire                   ctrl_en;
    input  wire                   data_in;
    input  wire                   chk_en;
    input  wire [CRC_WIDTH-1:0]   poly_in;  //do dai dua tren CRC
    // du lieu ra module 
    output reg                    crc_error;
    output reg  [CRC_WIDTH-1:0]   crc_seq;

    wire [CRC_WIDTH-1:0] crc_next;
    wire crc_msb = crc_seq[CRC_WIDTH-1];

    genvar i;
    generate
        for (i = 0; i < CRC_WIDTH; i = i + 1) begin : crc_logic_grid
            if (i == 0) begin : bit_0
                assign crc_next[0] = poly_in[0] ? (crc_msb ^ data_in) : data_in;
                //Đây chính là bước lấy bit dữ liệu vừa hạ xuống XOR với bit tương ứng của đa thức sinh ở hàng đầu tiên của phép chia. 
            end else begin : bit_higher
                // hành động hạ bit này chính là việc testbench cấp từng bit dữ liệu vào chân data_in 
                assign crc_next[i] = poly_in[i] ? (crc_msb ^ crc_seq[i-1]) : crc_seq[i-1];
            end
        end
    endgenerate
// ở đây là quá trình tạo crc và lưu tạm vào thanh ghi crc_next . 
// mỗi xung clock sẽ lần lượt đi vào lần lượt 
// ở xung 1 bit dât đi vào sau đó tính toán ra được crc đầu tiên sẽ được lưu vào crc_next 
// ở xung 2 bit đi vào , lúc này crc vừa tín được khi nãy sẽ lưu vào crc_seg 
// lặp lại quá trình đến hết xung 
// sau sau dịch đủ các bit yêu cầu 


    always @(posedge clk or negedge rst_n) begin
        // điều kiện kích hoạt là cạnh lên xung clock + cạnh xuống chân rst 
        if (!rst_n) begin // khi rst được kích hoạt 
            crc_seq <= {CRC_WIDTH{1'b0}}; // tất cả các ff sẽ trở về 0 khi cần rst để chuẩn bị cho giá trị tiếp theo 
        end else begin
            if (ctrl_en) // ưu tiên phía sau của rst là ctrl_en  
                crc_seq <= crc_next; // khi ctrl_en có bật lên 
                                     // mọi giá trị trong thanh ghi tạm crc sẽ lưu vào thanh ghi crc chính là crc_seg
            else
                crc_seq <= crc_seq;  // khi đã dịch hết gói ctrl_en =0 
                                     // dòng này dùng để chốt mã crc lại 
        end                          // có thể truyền nó đi kiểm tra crc mà không sợ bị thay đổi hay biến mất 
    end
    // đây là khối đóng vai trò là FF 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin   // rst được kích hoạt 
            crc_error <= 1'b0; // xóa sạch bộ kiểm tra trước khi nhận dữ liệu mới 
        end else if (chk_en && !ctrl_en) begin // thời điểm kt lỗi
            // testbench sẽ ra lệnh cho chk_en 
            // chk_en đóng vai trò cho phép kiểm tra lỗi 
            // ctrl_en trở về 0 khi đã dịch hết bit crc đã được nạp xog vào thanh ghi seg
            if (crc_seq != {CRC_WIDTH{1'b0}})
                crc_error <= 1'b1; // khác 0 thì bit error sẽ lên 1
            else
                crc_error <= 1'b0; // =0 thì bit error sẽ =0 
        end else begin
            crc_error <= crc_error; // nếu không có rst và thời điểm ktra lỗi thì giữ nguyên error 
        end
    end
    // khối dóng vai trò là bộ kiểm tra lỗi 
endmodule