from pathlib import Path
from fixedpoint import FP
import os

class Layer:
    def __init__(self, weights, biases):
        self.weights = weights
        self.biases = biases

layers = [
    Layer(
        weights = [[ 1.3438268, 0.7844486], [-0.6944131 , 0.6218078]],
        biases = [-0.00301381, -0.11910037],
    ),
    Layer(
        weights = [[-0.98676234, -0.8495982], [0.6073692, 1.1075667], [-0.22434632, 0.4754743]],
        biases = [0.0 , 0.08753138, 0.4771235 ],
    ),
    Layer(
        weights = [[-0.09532094, 0.5391998, -1.6091115], [-0.4663906, -0.58212435, 0.14439683], [-0.9640589, 0.9315815, -0.55397123]],
        biases = [-0.20772645, 0.02957543, 0.18059736],
    ),
    Layer(
        weights = [[-2.979263 , -0.0728805,  1.0819083]],
        biases = [0.00229267],
    ),
]

root = Path("layers")
fp = FP(integer_bits=8, fractional_bits=24)
fp.write("fixedpoint.sv")

for i, layer in enumerate(layers):
    current_layer = root / f"layer-{i}"

    for j, weights in enumerate(layer.weights):
        neuron = current_layer / f"neuron-{j}"
        neuron.mkdir(exist_ok=True, parents=True)

        wfile = neuron / "weights.mem"
        weights = map(lambda w: fp.new(w), weights)
        weights = map(lambda f: f"{f.bits:08x} // {f}", weights)
        weights = "\n".join(weights)
        with open(wfile, "w+") as file:
            file.write(weights)

        bfile = neuron / "bias.mem"
        bias = fp.new(layer.biases[j])
        bias = f"{bias.bits:08x} // {bias}"
        with open(bfile, "w+") as file:
            file.write(bias)

simulation_directory = Path(".") / ".." / ".." / ".." / "neural.sim" / "sim_1" / "behav" / "xsim"
simulation_layers = simulation_directory / "layers"
current_layers = Path(".").absolute() / "layers"
if not simulation_layers.exists():
    os.symlink(current_layers, simulation_layers)
