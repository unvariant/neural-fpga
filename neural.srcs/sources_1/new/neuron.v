module neuron (
	clock,
	input_data,
	input_data_ready,
	result,
	finished
);
	parameter DATAWIDTH = 32;
	parameter INPUT_NEURONS = 10;
	parameter LAYER_INDEX = 0;
	parameter NEURON_INDEX = 0;
	
	input clock;
	input [(INPUT_NEURONS * DATAWIDTH) - 1:0] input_data;
	input input_data_ready;
	output reg [DATAWIDTH - 1:0] result;
	output wire finished;
	
	function [DATAWIDTH - 1:0] fmul;
		input [DATAWIDTH - 1:0] a;
		input [DATAWIDTH - 1:0] b;
		reg [(DATAWIDTH * 2) - 1:0] extended_a;
		reg [(DATAWIDTH * 2) - 1:0] extended_b;
		reg [(DATAWIDTH * 2) - 1:0] tmp;
		begin
			extended_a[0+:DATAWIDTH] = a;
			extended_a[DATAWIDTH+:DATAWIDTH] = {DATAWIDTH {a[DATAWIDTH - 1]}};
			extended_b[0+:DATAWIDTH] = b;
			extended_b[DATAWIDTH+:DATAWIDTH] = {DATAWIDTH {b[DATAWIDTH - 1]}};
			tmp = extended_a * extended_b;
			fmul = tmp >> 24;
		end
	endfunction
	
	function [DATAWIDTH - 1:0] fadd;
		input [DATAWIDTH - 1:0] a;
		input [DATAWIDTH - 1:0] b;
		fadd = a + b;
	endfunction
	
	reg [DATAWIDTH - 1:0] bias [0:0];
	reg [DATAWIDTH - 1:0] multiplies [INPUT_NEURONS - 1:0];
	reg [DATAWIDTH - 1:0] weights [INPUT_NEURONS - 1:0];
	
	initial begin
		$readmemh({"./layers/layer-", $sformatf("%0d", LAYER_INDEX), "/neuron-", $sformatf("%0d", NEURON_INDEX), "/weights.mem"}, weights);
		$readmemh({"./layers/layer-", $sformatf("%0d", LAYER_INDEX), "/neuron-", $sformatf("%0d", NEURON_INDEX), "/bias.mem"}, bias);
	end
	
	genvar _gv_multi_1;
	generate
		for (_gv_multi_1 = 0; _gv_multi_1 < INPUT_NEURONS; _gv_multi_1 = _gv_multi_1 + 1) begin : genblk1
			localparam multi = _gv_multi_1;
			always @(posedge clock) multiplies[multi] = fmul(input_data[multi * DATAWIDTH+:DATAWIDTH], weights[multi]);
		end
	endgenerate
	
	integer i;
	always @(posedge clock) begin
		result = bias[0];
		for (i = 0; i < INPUT_NEURONS; i = i + 1)
			result = fadd(result, multiplies[i]);
		if (result[DATAWIDTH - 1] == 1)
			result = 0;
	end
endmodule
