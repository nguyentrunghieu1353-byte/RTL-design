//===================================================================================
// File name:	tb_crc.v
// Project:	CRC example
// Function:
// -- testbench for crc
// Author:	nguyenquan.icd@gmail.com
// Website: http://nguyenquanicd.blogspot.com
//===================================================================================
`include "crc_define.h"
module tb_crc;
`include "crc_parameter.h" 
/*AUTOREGINPUT*/
// Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
reg			clk;			// To dut of crc_4.v
reg			rst_n;			// To dut of crc_4.v
reg ctrl_en;
`ifdef CRC_CTRL_POLY
  reg [CRC_GPW_MAX-1:0] ctrl_poly_en;
`endif
`ifdef CRC_CHECKER
  reg chk_en;
`endif
// End of automatics

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire [3:0]		crc_seq;		// From dut of crc_4.v
`ifdef CRC_CHECKER
  wire crc_error;
`endif
// End of automatics

crc dut (/*AUTOINST*/
	   // Outputs
	   .crc_seq			(crc_seq[3:0]),
     `ifdef CRC_CHECKER
       .crc_error (crc_error),
     `endif
	   // Inputs
     `ifdef CRC_CTRL_POLY
       .ctrl_poly_en (ctrl_poly_en),
     `endif
     `ifdef CRC_CHECKER
       .chk_en (chk_en),
     `endif
     .ctrl_en (ctrl_en),
	   .clk				(clk),
	   .rst_n			(rst_n),
	   .data_in			(data_in));

reg [11:0] data_reg, data_tmp;

initial begin
  rst_n = 0;
  clk   = 0;
  ctrl_en = 0;
  data_tmp[11:0] = 12'b1010_0110_0000;
  `ifdef CRC_CTRL_POLY
    ctrl_poly_en = 4'b0011;
  `endif
  `ifdef CRC_CHECKER
    chk_en = 0;
  `endif
  #55
  rst_n = 1;
  #36
  ctrl_en = 1;
  #240
  ctrl_en = 0;
  #1
  `ifdef CRC_CHECKER
    data_tmp[11:0] = 12'b1010_0110_1110;
  `else
    data_tmp[11:0] = 12'b1010_0010_0000;
  `endif
  #39
  ctrl_en = 1;
  `ifdef CRC_CHECKER
    chk_en = 1;
  `endif
  #240
  ctrl_en = 0;
  `ifdef CRC_CHECKER
    chk_en = 1;
  `endif
end

always #10 clk = ~clk;

always @ (posedge clk) begin
  if (ctrl_en) data_reg[11:0] <= `DLY data_reg[11:0] << 1;
  else data_reg[11:0] <= `DLY data_tmp[11:0];
end

assign data_in = data_reg[11];

endmodule