


function [DATAWIDTH-1:0] fmul;
    localparam DATAWIDTH = 32;
    input [DATAWIDTH-1:0] a;
    input [DATAWIDTH-1:0] b;
    reg [DATAWIDTH*2-1:0] extended_a;
    reg [DATAWIDTH*2-1:0] extended_b;
    reg [DATAWIDTH*2-1:0] tmp;
    begin
        extended_a[DATAWIDTH-1:0] = a;
        extended_a[DATAWIDTH*2-1:DATAWIDTH-1] = {DATAWIDTH{a[DATAWIDTH-1]}};
        extended_b[DATAWIDTH-1:0] = b;
        extended_b[DATAWIDTH*2-1:DATAWIDTH-1] = {DATAWIDTH{b[DATAWIDTH-1]}};
        tmp = extended_a * extended_b;
        fmul = tmp >> `FP_FRACTION;
    end
endfunction

function [DATAWIDTH-1:0] fadd;
    input [DATAWIDTH-1:0] a;
    input [DATAWIDTH-1:0] b;

    begin
        fadd = a + b;
    end
endfunction
