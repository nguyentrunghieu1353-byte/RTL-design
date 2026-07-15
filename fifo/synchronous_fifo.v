`timescale 1ns/1ps

module synchronous_fifo #(
    parameter integer DATA_WIDTH = 8,
    parameter integer DEPTH      = 8
)(
    input  wire                  clk,
    input  wire                  rst_n,

    input  wire                  w_en,
    input  wire                  r_en,
    input  wire [DATA_WIDTH-1:0] data_in,

    output reg  [DATA_WIDTH-1:0] data_out,

    output wire                  full,
    output wire                  empty,
    output wire                  almost_full,
    output wire                  almost_empty,

    output wire [$clog2(DEPTH):0] count // dem so luong o nho // log2 vi vi du thanh ghi 8 bit thi can 3 bit dem 
);

localparam ADDR_WIDTH = $clog2(DEPTH);


// Memory

reg [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];




reg [ADDR_WIDTH-1:0] wr_ptr;
reg [ADDR_WIDTH-1:0] rd_ptr;
reg [ADDR_WIDTH:0]   fifo_count; // so phan tu 

//==========================================================
// Status
//==========================================================
assign count = fifo_count;

assign full  = (fifo_count == DEPTH);
assign empty = (fifo_count == 0);

assign almost_full  = (fifo_count >= DEPTH-1);
assign almost_empty = (fifo_count <= 1);


wire do_read;
wire do_write;

assign do_read  = r_en && !empty;
assign do_write = w_en && !full; 


// Write Logic

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wr_ptr <= 0; 
    end
    else if(do_write) begin
        fifo_mem[wr_ptr] <= data_in;

        if(wr_ptr == DEPTH-1) //xuong cuoi quay ve
            wr_ptr <= 0;
        else
            wr_ptr <= wr_ptr + 1'b1;
    end
end


// Read Logic

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rd_ptr   <= 0;
        data_out <= 0;
    end
    else if(do_read) begin
        data_out <= fifo_mem[rd_ptr];

        if(rd_ptr == DEPTH-1)
            rd_ptr <= 0;
        else
            rd_ptr <= rd_ptr + 1'b1;
    end
end


// Count Logic

always @(posedge clk or negedge rst_n) begin // dung de dem phan tu trong thanh ghi 
    if(!rst_n)
        fifo_count <= 0;
    else begin
        case ({do_write, do_read})
            2'b10: fifo_count <= fifo_count + 1'b1;
            2'b01: fifo_count <= fifo_count - 1'b1;
            default: fifo_count <= fifo_count; // Bao gồm cả trường hợp 2'b11 
        endcase
    end
end




initial begin
    if (DEPTH < 2)
        $error("DEPTH must be at least 2.");

    if ((1<<ADDR_WIDTH) < DEPTH)
        $display("do dai cua chuoi khong phai luy thua 2 ");
end

endmodule
// fifo_count đóng vai trò là đếm số lượng trong thanh ghi 
// w đóng vai trò là ghi con trỏ từ trái sang phải
// r đóng vai trò là đọc con trỏ từ trái sang phải 
// nếu có 1 ghi thì sẽ +1 cho count 
// nếu có 1 đọc thì sẽ -1 cho count 
// 