module neuron #(
    integer INPUT_NEURONS
) (
    input clock,
    input [DATAWIDTH-1:0][INPUT_NEURONS:0] input_data,
    input input_data_ready,
    output [DATAWIDTH-1:0] result,
    output finished
);

    reg [31:0] counter = 0;
    reg [31:0] state;
    reg [DATAWIDTH-1:0] sum;

    localparam WAITING = 0;
    localparam PROCESSING = 1;

    always @(posedge clock) begin
        case (state)
            WAITING: begin
                if (input_data_ready == 1) state <= PROCESSING;
            end
            PROCESSING: begin

            end
        endcase
    end

endmodule
