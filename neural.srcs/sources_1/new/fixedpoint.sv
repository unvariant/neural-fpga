`define FP_INTEGER 8
`define FP_FRACTION 24

// TODO: handle overflow and saturate properly
// fp addition can only overflow when sign(a) != sign(b)
// fp multiplication can overflow anytime

function [DATAWIDTH-1:0] fmul;
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