function [DATAWIDTH-1:0] fmul;
    input [DATAWIDTH-1:0] a;
    input [DATAWIDTH-1:0] b;
    begin
        if (({'h00000000, a} * {'h00000000, b}) >> (FP_FRACTION * 2) > (1 << FP_INTEGER) - 1) begin
            fmul <= FP_SATURATING_MAX;
        end else begin
            fmul <= ({'h00000000, a} * {'h00000000, b}) >> FP_FRACTION;
        end
    end
endfunction

function [DATAWIDTH-1:0] fadd;
    input [DATAWIDTH-1:0] a;
    input [DATAWIDTH-1:0] b;
