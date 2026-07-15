
`timescale 1ns/1ps

module ArrayMultiplier4x4_tb;

    reg  [3:0] a;
    reg  [3:0] b;
    wire [7:0] z;

    integer i, j;

    ArrayMultiplier4x4 uut (
        .a(a),
        .b(b),
        .z(z)
    );

    initial begin

        for(i = 0; i < 16; i = i + 1) begin
            for(j = 0; j < 16; j = j + 1) begin

                a = i;
                b = j;

                #10;

                if(z == (i*j))
                    $display("PASS: %d x %d = %d", i, j, z);
                else
                    $display("FAIL: %d x %d -> z=%d, expected=%d",
                              i, j, z, i*j);

            end
        end

        $finish;
    end

endmodule