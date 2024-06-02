module layer
#(
    DATAWIDTH=0,
    OUTPUT_NEURONS=0,
    INPUT_NEURONS=0,
    LAYER_INDEX=0
)
(
    input clock,
    input [DATAWIDTH-1:0] input_data[INPUT_NEURONS-1:0],
    output [DATAWIDTH-1:0] output_data[OUTPUT_NEURONS-1:0]
);

    genvar i;
    generate
        for (i = 0; i < OUTPUT_NEURONS; i = i + 1) begin
            neuron
            #(
                .DATAWIDTH(DATAWIDTH),
                .INPUT_NEURONS(INPUT_NEURONS),
                .LAYER_INDEX(LAYER_INDEX),
                .NEURON_INDEX(i)
            )
            Neuron
            (
                .clock(clock),
                .input_data(input_data),
                .result(output_data[i])
            );
        end
    endgenerate

endmodule