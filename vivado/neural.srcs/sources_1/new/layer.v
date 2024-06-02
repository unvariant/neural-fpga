module layer #(
    integer DATAWIDTH = 0,
    integer INPUT_NEURONS = 0,
    integer OUTPUT_NEURONS = 0,
    integer LAYER_INDEX = 0
) (
    input clock,
    // i miss 2d input arrays...
    input [DATAWIDTH*INPUT_NEURONS-1:0] input_data,
    output [DATAWIDTH*OUTPUT_NEURONS-1:0] output_data
);

    // use the configurable OUTPUT_NEURONS parameter to
    // generate a variable number of neurons all hooked
    // up to their appropriate outputs
    genvar i;
    generate
        for (i = 0; i < OUTPUT_NEURONS; i = i + 1) begin
            neuron #(
                .DATAWIDTH(DATAWIDTH),
                .INPUT_NEURONS(INPUT_NEURONS),
                .LAYER_INDEX(LAYER_INDEX),
                .NEURON_INDEX(i)
            ) Neuron (
                .clock(clock),
                .input_data(input_data),
                .result(output_data[i*DATAWIDTH+:DATAWIDTH])
            );
        end
    endgenerate

endmodule
