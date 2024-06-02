module BenchNeuron;
	parameter DATAWIDTH = 32;
	parameter INPUT_NEURONS = 2;
	reg clock = 0;
	always #(1) clock <= ~clock;
	reg [(INPUT_NEURONS * DATAWIDTH) - 1:0] data;
	wire ready = 1;
	wire [DATAWIDTH - 1:0] result;

	neuron #(
		.DATAWIDTH(DATAWIDTH),
		.INPUT_NEURONS(INPUT_NEURONS),
		.LAYER_INDEX(0),
		.NEURON_INDEX(0)
	) n(
		.clock(clock),
		.input_data(data),
		.input_data_ready(ready),
		.result(result)
	);
	integer dz;
	integer part;
	initial begin
		for (dz = 0; dz < INPUT_NEURONS; dz = dz + 1)
			data[dz * DATAWIDTH +: DATAWIDTH] = 0;
		data[0 +: DATAWIDTH] = 83886080;
		data[DATAWIDTH +: DATAWIDTH] = 100663296;
		#(5);
		part = result >> 24;
		$display("part = %d", part);
	end
endmodule
