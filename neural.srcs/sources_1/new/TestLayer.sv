`timescale 1us/1ns

module TestLayer
();

    localparam DATAWIDTH = 32;
    localparam LAYER0_NEURONS = 3;
    localparam LAYER1_NEURONS = 1;
    
    reg clock = 0;
    always #1 clock <= !clock;
    
    reg [DATAWIDTH-1:0] input_data[1:0];

    wire [DATAWIDTH-1:0] layer0_outputs[LAYER0_NEURONS-1:0];
    layer
    #(
        .DATAWIDTH(DATAWIDTH), 
        .OUTPUT_NEURONS(LAYER0_NEURONS),
        .INPUT_NEURONS(2),
        .LAYER_INDEX(0)
    )
    Layer0
    (
        .clock(clock),
        .input_data(input_data),
        .output_data(layer0_outputs)
    );
    
    wire [DATAWIDTH-1:0] layer1_outputs[LAYER1_NEURONS-1:0];
    layer
    #(
        .DATAWIDTH(DATAWIDTH),
        .OUTPUT_NEURONS(LAYER1_NEURONS),
        .INPUT_NEURONS(LAYER0_NEURONS),
        .LAYER_INDEX(1)
    )
    Layer1
    (
        .clock(clock),
        .input_data(layer0_outputs),
        .output_data(layer1_outputs)
    );
    
    initial begin
        input_data[0] <= 1 << `FP_FRACTION;
        input_data[1] <= 1 << `FP_FRACTION;
        
        #5;
        
        $display("done");
    end

endmodule