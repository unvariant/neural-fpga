# neural

A simple feed forward neural network implementation in Verilog.

Supports both modelsim and vivado simulators, see their respective directories for more details.

# usage

`parameters.py` contains the weights and biases for the network and generates the proper files that verilog can consume. The fixedpoint format for the weights and biases can be configured to use any number of bits for the integer or fractional part, and automatically updates the fixedpoint verilog implementations to match.

After regenerating the weights and biases edit `TestLayer.v` to configure the proper number of layers and nodes to match the weights and biases.
