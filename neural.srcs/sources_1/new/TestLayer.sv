`timescale 1us / 1ns

module TestLayer #(
    int DATAWIDTH = 32
) ();

    `include "fixedpoint.sv"

    // index[0] is far right apparently???
    localparam int LayerNeurons[3:0] = '{1, 3, 3, 2};

    reg clock = 0;
    always #1 clock <= !clock;

    reg [DATAWIDTH-1:0] input_data[1:0];

    genvar i;
    generate
        for (i = 0; i < $size(LayerNeurons); i = i + 1) begin : layers
            localparam int NumberOfInputs = (i == 0) ? $size(input_data) : LayerNeurons[i-1];
            localparam int NumberOfOutputs = LayerNeurons[i];

            wire [DATAWIDTH-1:0] inputs [ NumberOfInputs-1:0];
            wire [DATAWIDTH-1:0] outputs[NumberOfOutputs-1:0];

            if (i == 0) begin
                assign inputs = input_data;
            end else begin
                assign inputs = layers[i-1].outputs;
            end

            layer #(
                .DATAWIDTH(DATAWIDTH),
                .OUTPUT_NEURONS(NumberOfOutputs),
                .INPUT_NEURONS(NumberOfInputs),
                .LAYER_INDEX(i)
            ) GeneratedLayer (
                .clock(clock),
                .input_data(inputs),
                .output_data(outputs)
            );
        end
    endgenerate

    initial begin
        input_data[0] <= 0 << `FP_FRACTION;
        input_data[1] <= 0 << `FP_FRACTION;

        #1 $display(layers[$size(LayerNeurons)-1].outputs);

        #75;

        input_data[0] <= 1 << `FP_FRACTION;
        input_data[1] <= 0 << `FP_FRACTION;

        #1 $display(layers[$size(LayerNeurons)-1].outputs);

        #75;

        input_data[0] <= 0 << `FP_FRACTION;
        input_data[1] <= 1 << `FP_FRACTION;

        #1 $display(layers[$size(LayerNeurons)-1].outputs);

        #75;

        input_data[0] <= 1 << `FP_FRACTION;
        input_data[1] <= 1 << `FP_FRACTION;

        #1 $display(layers[$size(LayerNeurons)-1].outputs);

        #75;

        $display("done");
    end

endmodule
