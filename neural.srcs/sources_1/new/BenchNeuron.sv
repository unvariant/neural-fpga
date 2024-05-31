`timescale 1us/1ns

module BenchNeuron
#(
    DATAWIDTH=32,
    INPUT_NEURONS=2
)
();

    reg clock = 0;
    always #1 clock <= !clock;
    
    reg [DATAWIDTH-1:0] data[INPUT_NEURONS-1:0];
    
    wire ready = 1;
    wire [DATAWIDTH-1:0] result;
    
    neuron
    #(
        .DATAWIDTH(DATAWIDTH),
        .INPUT_NEURONS(INPUT_NEURONS),
        .LAYER_INDEX(0),
        .NEURON_INDEX(0)
    )
    n
    (
        .clock(clock),
        .input_data(data),
        .input_data_ready(ready),
        .result(result)
    );
    
    integer dz;
    integer part;
    initial begin
        for (dz = 0; dz < INPUT_NEURONS; dz = dz + 1) begin
            data[dz] = 0;
        end
        
        data[0] = 5 << `FP_FRACTION;
        data[1] = 6 << `FP_FRACTION;
        
        #5;
        
        part = result >> `FP_FRACTION;
        $display("part = %d", part);
    end
    
endmodule