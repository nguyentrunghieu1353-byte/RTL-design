`timescale 1ns/1ps

module tb_fifo;

parameter DATA_WIDTH = 8;
parameter DEPTH = 8;

reg clk;
reg rst_n;
reg w_en;
reg r_en;
reg [DATA_WIDTH-1:0] data_in;

wire [DATA_WIDTH-1:0] data_out;
wire full;
wire empty;


synchronous_fifo #(
    .DEPTH(DEPTH),
    .DATA_WIDTH(DATA_WIDTH)
) dut (
    .clk(clk),
    .rst_n(rst_n),
    .w_en(w_en),
    .r_en(r_en),
    .data_in(data_in),
    .data_out(data_out),
    .full(full),
    .empty(empty)
);

//=====================================================
// Queue làm Reference Model
//=====================================================
reg [DATA_WIDTH-1:0] model_q[$];
reg [DATA_WIDTH-1:0] expected;

//=====================================================
// Clock
//=====================================================
initial clk = 0;
always #5 clk = ~clk;

//=====================================================
// Reset
//=====================================================
initial begin
    rst_n   = 0;
    w_en    = 0;
    r_en    = 0;
    data_in = 0;

    repeat(5) @(posedge clk);
    rst_n = 1;
end

//=====================================================
// MAIN TEST
//=====================================================
integer i;

initial begin

    wait(rst_n);

    //-------------------------------------------------
    // WRITE 8 DATA
    //-------------------------------------------------
    $display("\n========== WRITE PHASE ==========\n");

    for(i=0;i<DEPTH;i=i+1) begin

        @(negedge clk);

        w_en    = 1;
        data_in = $urandom;

        model_q.push_back(data_in);

        @(posedge clk);

        $display("[%0t] WRITE -> %h",$time,data_in);

    end

    @(negedge clk);
    w_en = 0;

    repeat(2) @(posedge clk);

    //-------------------------------------------------
    // READ 8 DATA
    //-------------------------------------------------
    $display("\n========== READ PHASE ==========\n");

    for(i=0;i<DEPTH;i=i+1) begin

        expected = model_q.pop_front();

        @(negedge clk);
        r_en = 1;

        @(posedge clk);

        #1;

        if(data_out===expected)
            $display("[%0t] PASS  Expected=%h Read=%h",
                     $time,expected,data_out);
        else
            $display("[%0t] FAIL  Expected=%h Read=%h",
                     $time,expected,data_out);

    end

    @(negedge clk);
    r_en = 0;

    repeat(5) @(posedge clk);

    $display("\n========== TEST DONE ==========\n");

    $finish;

end

//=====================================================
// Waveform
//=====================================================
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,tb_fifo);
end

endmodule