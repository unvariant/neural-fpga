module neuron #(
    parameter integer DATAWIDTH = 0,
    parameter integer INPUT_NEURONS = 10,
    parameter integer LAYER_INDEX = 0,
    parameter integer NEURON_INDEX = 0
) (
    input clock,
    input [DATAWIDTH*INPUT_NEURONS-1:0] input_data,
    output reg [DATAWIDTH-1:0] result
);

    `include "fixedpoint.v"

    // bias must be an array of size 1 or $readmemh complains
    reg [DATAWIDTH-1:0] bias[0:0];
    reg [DATAWIDTH-1:0] multiplies[0:INPUT_NEURONS-1];
    reg [DATAWIDTH-1:0] weights[0:INPUT_NEURONS-1];

    initial begin
        $readmemb($sformatf("./layers/layer-%0d/neuron-%0d/weights.mem", LAYER_INDEX, NEURON_INDEX),
                  weights);
        $readmemb($sformatf("./layers/layer-%0d/neuron-%0d/bias.mem", LAYER_INDEX, NEURON_INDEX),
                  bias);
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
