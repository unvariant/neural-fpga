module TestLayer;
	parameter signed [31:0] DATAWIDTH = 32;
	
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
	
	localparam signed [127:0] LayerNeurons = 128'h00000001000000030000000300000002;
	reg clock = 0;
	
	always #(1) clock <= !clock;
	
	reg [(2 * DATAWIDTH) - 1:0] input_data;
	
	genvar _gv_i_1;
	
	generate
		for (_gv_i_1 = 0; _gv_i_1 < 4; _gv_i_1 = _gv_i_1 + 1) begin : layers
			localparam i = _gv_i_1;
			localparam signed [31:0] NumberOfInputs = (i == 0 ? 2 : LayerNeurons[(i - 1) * 32+:32]);
			localparam signed [31:0] NumberOfOutputs = LayerNeurons[i * 32+:32];
			wire [(NumberOfInputs * DATAWIDTH) - 1:0] inputs;
			wire [(NumberOfOutputs * DATAWIDTH) - 1:0] outputs;
			
			if (i == 0) begin : genblk1
				assign inputs = input_data;
			end
			else begin : genblk1
				assign inputs = layers[i - 1].outputs;
			end
			
			layer #(
				.DATAWIDTH(DATAWIDTH),
				.OUTPUT_NEURONS(NumberOfOutputs),
				.INPUT_NEURONS(NumberOfInputs),
				.LAYER_INDEX(i)
			) GeneratedLayer(
				.clock(clock),
				.input_data(inputs),
				.output_data(outputs)
			);
		end
	endgenerate
	
	initial begin
		input_data[0+:DATAWIDTH] <= 0;
		input_data[DATAWIDTH+:DATAWIDTH] <= 0;
		#(1)
			$display(layers[3].outputs);
		#(75)
			;
		input_data[0+:DATAWIDTH] <= 16777216;
		input_data[DATAWIDTH+:DATAWIDTH] <= 0;
		#(1)
			$display(layers[3].outputs);
		#(75)
			;
		input_data[0+:DATAWIDTH] <= 0;
		input_data[DATAWIDTH+:DATAWIDTH] <= 16777216;
		#(1)
			$display(layers[3].outputs);
		#(75)
			;
		input_data[0+:DATAWIDTH] <= 16777216;
		input_data[DATAWIDTH+:DATAWIDTH] <= 16777216;
		#(1)
			$display(layers[3].outputs);
		#(75)
			;
		$display("done");
	end
endmodule
