`define FP_INTEGER 20
`define FP_FRACTION 12

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
        extended_a = {'h00000000, a};
        extended_b = {'h00000000, b};
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
