//===================================================================================
// File name:	crc_define.h
// Project:	Configurated CRC
// Author:	nguyenquan.icd@gmail.com
// Website: http://nguyenquanicd.blogspot.com
//===================================================================================

//Generator polynomial maximum width
//Ex: If Generator polynomial is x^4 + x + 1, its data width is 4.
localparam CRC_GPW_MAX    = 4;
localparam CRC_POLY_VALUE = 4'b0011; //x^4 + x + 1