//khối đống vai trò là Flip Flop 

module dff (
    input  wire clk,      
    input  wire rst,      
    input  wire ctrl_en,  
    input  wire d,        
    output reg  q         
);

    // Kích hoạt bằng cạnh lên của clock hoặc cạnh lên của reset (bất đồng bộ)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= 1'b0;     // Khi reset, xóa trạng thái về 0
        end else if (ctrl_en) begin
            q <= d;        // Khi ctrl_en = 1, cập nhật giá trị mới từ ngõ vào d
        end
        // Nếu ctrl_en = 0, q giữ nguyên giá trị cũ
    end

endmodule