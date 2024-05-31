module neuron #(
    DATAWIDTH=32,
    INPUT_NEURONS=10,
    LAYER_INDEX=0,
    NEURON_INDEX=0
) (
    input clock,
    input [DATAWIDTH-1:0] input_data[INPUT_NEURONS-1:0],
    input input_data_ready,
    output reg [DATAWIDTH-1:0] result,
    output finished
);

    `include "fixedpoint.v"

    reg [31:0] counter = 0;
    reg [DATAWIDTH-1:0] bias[0:0];
    reg [DATAWIDTH-1:0] multiplies[INPUT_NEURONS-1:0];
    reg [DATAWIDTH-1:0] weights[INPUT_NEURONS-1:0];
    
    initial begin
//        $readmemh("meow.mem", bias);
//        $readmemh($sformatf("layers/layer-%0d/neuron-%0d/weights.mem", LAYER_INDEX, NEURON_INDEX), weights);
//        $readmemh($sformatf("layers/layer-%0d/neuron-%0d/bias.mem", LAYER_INDEX, NEURON_INDEX), bias);
        $readmemh($sformatf("layer-%0d_neuron-%0d_bias.mem", LAYER_INDEX, NEURON_INDEX), bias);
    end

    genvar multi;
    generate
        for (multi = 0; multi < INPUT_NEURONS; multi = multi + 1) begin
            always @(posedge clock) begin
                multiplies[multi] = fmul(input_data[multi], weights[multi]);
            end
        end
    endgenerate
    
    integer i;
    always @(posedge clock) begin
        result = bias[0];
        for (i = 0; i < INPUT_NEURONS; i = i + 1) begin
            result = result + multiplies[i];
        end
    end
    
endmodule
