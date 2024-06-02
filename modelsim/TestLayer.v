`timescale 1us / 1ns

// note about naming conventions:
// my linter dictates that module parameters are all uppercase while
// local parameters are camelcase.

module TestLayer #(
    parameter integer DATAWIDTH = 32
) ();

    // make sure to include this INSIDE the module, not outside
    `include "fixedpoint.v"

    // configure the number of neurons in each layer (excluding the input layer).
    // the leftmost number represents the first hidden layer, and the rightmost
    // number is the last hidden layer
    localparam integer NumLayerNeurons = 4;
    localparam [0:32*NumLayerNeurons-1] LayerNeurons = {2, 3, 3, 1};

    reg clock = 0;
    always #1 clock <= !clock;

    // configure number of inputs
    localparam integer NumInputs = 2;
    reg [DATAWIDTH*NumInputs-1:0] input_data;

    // this block generates and connects all the layers together
    genvar i;
    generate
        // assigning the block a prefix allows the generation to
        // access instantiated variables and modules from the
        // previous iteration
        for (i = 0; i < NumLayerNeurons; i = i + 1) begin : g_layers
            localparam integer NumberOfInputs = (i == 0) ? NumInputs : LayerNeurons[(i-1)*32+:32];
            localparam integer NumberOfOutputs = LayerNeurons[i*32+:32];

            wire [ DATAWIDTH*NumberOfInputs-1:0] inputs;
            wire [DATAWIDTH*NumberOfOutputs-1:0] outputs;

            if (i == 0) begin
                assign inputs = input_data;
            end else begin
                assign inputs = g_layers[i-1].outputs;
            end

            // clock is currently useless and does nothing
            layer #(
                .DATAWIDTH(DATAWIDTH),
                .INPUT_NEURONS(NumberOfInputs),
                .OUTPUT_NEURONS(NumberOfOutputs),
                .LAYER_INDEX(i)
            ) GeneratedLayer (
                .clock(clock),
                .input_data(inputs),
                .output_data(outputs)
            );
        end
    endgenerate

    // testing all the different combination of xor inputs
    initial begin
        input_data[0+:DATAWIDTH] <= 0 << `FP_FRACTION;
        input_data[DATAWIDTH+:DATAWIDTH] <= 0 << `FP_FRACTION;

        #75;

        input_data[0+:DATAWIDTH] <= 1 << `FP_FRACTION;
        input_data[DATAWIDTH+:DATAWIDTH] <= 0 << `FP_FRACTION;

        #75;

        input_data[0+:DATAWIDTH] <= 0 << `FP_FRACTION;
        input_data[DATAWIDTH+:DATAWIDTH] <= 1 << `FP_FRACTION;

        #75;

        input_data[0+:DATAWIDTH] <= 1 << `FP_FRACTION;
        input_data[DATAWIDTH+:DATAWIDTH] <= 1 << `FP_FRACTION;

        #75;

        $display("done");
    end

endmodule
