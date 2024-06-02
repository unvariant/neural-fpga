module layer (
	clock,
	input_data,
	output_data
);
	parameter DATAWIDTH = 0;
	parameter OUTPUT_NEURONS = 0;
	parameter INPUT_NEURONS = 0;
	parameter LAYER_INDEX = 0;
	
	input clock;
	input [(INPUT_NEURONS * DATAWIDTH) - 1:0] input_data;
	output wire [(OUTPUT_NEURONS * DATAWIDTH) - 1:0] output_data;
	
	genvar _gv_i_2;
	
	generate
		for (_gv_i_2 = 0; _gv_i_2 < OUTPUT_NEURONS; _gv_i_2 = _gv_i_2 + 1) begin : genblk1
			localparam i = _gv_i_2;
			
			neuron #(
				.DATAWIDTH(DATAWIDTH),
				.INPUT_NEURONS(INPUT_NEURONS),
				.LAYER_INDEX(LAYER_INDEX),
				.NEURON_INDEX(i)
			) Neuron(
				.clock(clock),
				.input_data(input_data),
				.result(output_data[i * DATAWIDTH +: DATAWIDTH])
			);
		end
	endgenerate
endmodule
