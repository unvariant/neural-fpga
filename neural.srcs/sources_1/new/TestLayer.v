`timescale 1us/1ns

module TestLayer
();

    `include "fixedpoint.sv"

    localparam DATAWIDTH = 32;
    // index[0] is far right apparently???
    localparam int LAYER_NEURONS[3:0] = '{ 1, 3, 3, 2 };

    reg clock = 0;
    always #1 clock <= !clock;

    reg [DATAWIDTH-1:0] input_data[1:0];

    genvar i;
    generate
        for (i = 0; i < $size(LAYER_NEURONS); i = i + 1) begin: layers
            localparam number_of_inputs = (i == 0) ? $size(input_data) : LAYER_NEURONS[i-1];
            localparam number_of_outputs = LAYER_NEURONS[i];
            
            wire [DATAWIDTH-1:0] inputs[number_of_inputs-1:0];
            wire [DATAWIDTH-1:0] outputs[number_of_outputs-1:0];
            
            if (i == 0) begin
                assign inputs = input_data;
            end else begin
                assign inputs = layers[i-1].outputs;
            end
            
            layer
            #
            (
                .DATAWIDTH(DATAWIDTH),
                .OUTPUT_NEURONS(number_of_outputs),
                .INPUT_NEURONS(number_of_inputs),
                .LAYER_INDEX(i)
            )
            GeneratedLayer
            (
                .clock(clock),
                .input_data(inputs),
                .output_data(outputs)
            );
        end
    endgenerate

    initial begin
        input_data[0] <= 0 << `FP_FRACTION;
        input_data[1] <= 0 << `FP_FRACTION;

        #1 $display(layers[$size(LAYER_NEURONS)-1].outputs);

        #75;

        input_data[0] <= 1 << `FP_FRACTION;
        input_data[1] <= 0 << `FP_FRACTION;

        #1 $display(layers[$size(LAYER_NEURONS)-1].outputs);

        #75;

        input_data[0] <= 0 << `FP_FRACTION;
        input_data[1] <= 1 << `FP_FRACTION;

        #1 $display(layers[$size(LAYER_NEURONS)-1].outputs);

        #75;

        input_data[0] <= 1 << `FP_FRACTION;
        input_data[1] <= 1 << `FP_FRACTION;

        #1 $display(layers[$size(LAYER_NEURONS)-1].outputs);

        #75;

        $display("done");
    end

endmodule
