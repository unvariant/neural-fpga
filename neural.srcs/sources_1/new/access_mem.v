`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/29/2024 10:55:32 AM
// Design Name: 
// Module Name: access_mem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module access_mem #( parameter numWeight=5, neuronNo=7, actType="ReLU", biasFile="b1_1.mif", weightFile="", widthAddr=11)(
    input clk,
    input rst,
    input wen, // write enable 
    input ren, // read enable 
    input[widthAddr-1:0] waddr
    

    );
    
endmodule
