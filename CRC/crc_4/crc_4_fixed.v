module crc_4_fixed (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       ctrl_en,   
    input  wire       data_in,   
    input  wire       chk_en,     
    
    output reg        crc_error,  
    output reg  [3:0] crc_seq     
);

    wire [3:0] crc_next;

    wire crc_msb = crc_seq[3];

    assign crc_next[0] = crc_msb ^ data_in;
    assign crc_next[1] = crc_msb ^ crc_seq[0];
    assign crc_next[2] = crc_seq[1];
    assign crc_next[3] = crc_seq[2];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            crc_seq <= 4'b0000;
        end 
        else begin
            if (ctrl_en) begin
                crc_seq <= crc_next;
            end 
            else begin
                crc_seq <= crc_seq;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            crc_error <= 1'b0;
        end 
        else if (chk_en && !ctrl_en) begin
            if (crc_seq != 4'b0000)
                crc_error <= 1'b1;
            else
                crc_error <= 1'b0;
        end 
        else begin
            crc_error <= crc_error;
        end
    end

endmodule
//iverilog -o crc_sim -s tb_crc_4_fixed crc_4_fixed.v tb_crc_4_fixed.v 
//vvp crc_sim 