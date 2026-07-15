module HA (
    input a,
    input b,
    output Sum,
    output Cout
);
 assign Sum = a ^ b ; 
 assign Cout = a & b ; 
endmodule 

module FA (
    input a,
    input b,
    input Cin,
    output Sum,
    output Cout
);
    assign Sum = a ^ b ^Cin  ; 
    assign Cout = (a&b)|(Cin &(a^b)) ; 
endmodule 

module ArrayMultiplier4x4 (
    input [3:0] a ,
    input [3:0] b ,
    output [7:0] z 
);
wire p00 = a[0] & b[0] ; 
wire p10 = a[1] & b[0] ; 
wire p20 = a[2] & b[0] ;                                                                                                                                                                                                                                                                                                                                   
wire p30 = a[3] & b[0] ; 
wire p40 = 1'b0 ; 
wire p50 = 1'b0 ; 
wire p60 = 1'b0 ;  
wire p70 = 1'b0 ; 

wire p01 = a[0] & b[1] ; 
wire p11 = a[1] & b[1] ; 
wire p21 = a[2] & b[1] ;                                                                                                                                                                                                                                                                                                                                   
wire p31 = a[3] & b[1] ; 
wire p41 = 1'b0 ; 
wire p51 = 1'b0 ; 
wire p61 = 1'b0 ;  

wire p02 = a[0] & b[2] ; 
wire p12 = a[1] & b[2] ; 
wire p22 = a[2] & b[2] ;                                                                                                                                                                                                                                                                                                                                   
wire p32 = a[3] & b[2] ; 
wire p42 = 1'b0 ; 
wire p52 = 1'b0 ; 

wire p03 = a[0] & b[3] ; 
wire p13 = a[1] & b[3] ; 
wire p23 = a[2] & b[3] ;                                                                                                                                                                                                                                                                                                                                   
wire p33 = a[3] & b[3] ; 
wire p43 = 1'b0 ; 

wire s0 , s1 ,s2 ,s3 ,s4 ,s5 ,s6 ,s7 ,s8 ,s9 ,s10 ; 
wire c0 , c1 ,c2 ,c3 ,c4 ,c5 ,c6 ,c7 ,c8 ,c9 ,c10 ,c11 ,c12 ,c13 ,c14 ,c15 ,c16 ,c17 ; 

HA hatang1 (.a(p02), .b(p11 ), .Cout(c0), .Sum(s0) ) ; 
FA fatang1_t1 (.a(p03), .b(p12), .Cin(p21), .Sum(s1), .Cout(c1));
FA fatang1_t2 (.a(p13), .b(p22), .Cin(p31), .Sum(s2), .Cout(c2));
FA fatang1_t3 (.a(p23), .b(p32), .Cin(p41), .Sum(s3), .Cout(c3));
FA fatang1_t4 (.a(p33), .b(p42), .Cin(p51), .Sum(s4), .Cout(c4));
FA fatang1_t5 (.a(p43), .b(p52), .Cin(p61), .Sum(s5), .Cout(c5));

HA hatang2 (.a(s1), .b(p30 ), .Cout(c6), .Sum(s6) ) ; 
FA fatang2_t1 (.a(s2), .b(p40), .Cin(c1), .Sum(s7), .Cout(c7));
FA fatang2_t2 (.a(s3), .b(p50), .Cin(c2), .Sum(s8), .Cout(c8));
FA fatang2_t3 (.a(s4), .b(p60), .Cin(c3), .Sum(s9), .Cout(c9));
FA fatang2_t4 (.a(s5), .b(p70), .Cin(c4), .Sum(s10), .Cout(c10));

assign z[0] = p00 ; 

HA hatang3 (.a(p01), .b(p10 ), .Cout(c11), .Sum(z[1]) ) ; 
FA fatang3_t1 (.a(s0), .b(p20), .Cin(c11), .Sum(z[2]), .Cout(c12));
FA fatang3_t2 (.a(s6), .b(c0), .Cin(c12), .Sum(z[3]), .Cout(c13));
FA fatang3_t3 (.a(s7), .b(c6), .Cin(c13), .Sum(z[4]), .Cout(c14));
FA fatang3_t4 (.a(s8), .b(c7), .Cin(c14), .Sum(z[5]), .Cout(c15));
FA fatang3_t5 (.a(s9), .b(c8), .Cin(c15), .Sum(z[6]), .Cout(c16));
FA fatang3_t6 (.a(s10), .b(c9), .Cin(c16), .Sum(z[7]), .Cout(c17));

endmodule 
// iverilog -o simv ArrayMultiplier4x4_tb.v
//vvp simv