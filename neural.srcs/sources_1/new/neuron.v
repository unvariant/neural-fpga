module neuron #(
    integer DATAWIDTH = 0,
    integer INPUT_NEURONS = 10,
    integer LAYER_INDEX = 0,
    integer NEURON_INDEX = 0
) (
    input clock,
    // classic verilog doesnt support 2d input data
    // (system verilog accepts 2d input data fine).
    input [DATAWIDTH*INPUT_NEURONS-1:0] input_data,
    output reg [DATAWIDTH-1:0] result
);

    `include "fixedpoint.v"

    // bias must be an array of size 1 or $readmemh complains
    reg [DATAWIDTH-1:0] bias[0:0];
    // classic verilog, for whatever reason disallows 2d inputs and
    // 2d parameters, but allows 2d regiters???
    // (system verilog supports 2d inputs, parameters, registers, etc)
    reg [DATAWIDTH-1:0] multiplies[0:INPUT_NEURONS-1];
    reg [DATAWIDTH-1:0] weights[0:INPUT_NEURONS-1];

    // classic verilog doesnt support $sformatf
    // instead we have this hack to convert integers to strings
    // (system verilog supports $sformatf which is much better).
    function [32*8-1:0] itoa;
        input integer n;
        integer i;
        begin
            i = 0;
            itoa = 128'b0;
            for (i = 0; i < 32; i = i + 1, n = n / 10) begin
                itoa[i*8+:8] = (n % 10) + 'h30;
                if (n == 0 && i > 0) begin
                    itoa[i*8+:8] = 0;
                end
            end
        end
    endfunction

    // when simulating make sure these files are located in the
    // [project name].sim/sim_1/behav/xsim directory
    initial begin
        $readmemb({"./layers/layer-", itoa(LAYER_INDEX), "/neuron-", itoa(NEURON_INDEX),
                   "/weights.mem"}, weights);
        $readmemb({"./layers/layer-", itoa(LAYER_INDEX), "/neuron-", itoa(NEURON_INDEX), "/bias.mem"
                      }, bias);
    end

    genvar multi;
    generate
        for (multi = 0; multi < INPUT_NEURONS; multi = multi + 1) begin
            always @(posedge clock) begin
                multiplies[multi] = fmul(input_data[DATAWIDTH*multi+:DATAWIDTH], weights[multi]);
            end
        end
    endgenerate

    integer i;
    always @(posedge clock) begin
        result = bias[0];
        for (i = 0; i < INPUT_NEURONS; i = i + 1) begin
            result = fadd(result, multiplies[i]);
        end
        // hardcoded unconfigurable RELU lets go!!!
        // (sarcasm)
        if (result[DATAWIDTH-1] == 1) result = 0;
    end

endmodule
