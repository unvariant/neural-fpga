from pathlib import Path
from fp import FP
import os

class Layer:
    def __init__(self, weights, biases):
        self.weights = weights
        self.biases = biases

layers = [
    Layer(
        weights = [
            [1, 1],
            [-1, -1],
        ],
        biases = [ .5, -1.5, ]
    ),
    Layer(
        weights = [
            [1, 1]
        ],
        biases = [ 1.5, ],
    )
]

FP_BITS = 32
FP_INTEGER = 20
FP_FRACTION = FP_BITS - FP_INTEGER

root = Path("layers")

for i, layer in enumerate(layers):
    current_layer = root / f"layer-{i}"

    for j, weights in enumerate(layer.weights):
        neuron = current_layer / f"neuron-{j}"
        neuron.mkdir(exist_ok=True, parents=True)

        wfile = neuron / "weights.mem"
        weights = map(FP, weights)
        weights = map(lambda fp: f"{fp.bits:08x} // {fp}", weights)
        weights = "\n".join(weights)
        with open(wfile, "w+") as file:
            file.write(weights)

        bfile = neuron / "bias.mem"
        bias = FP(layer.biases[j])
        bias = f"{bias.bits:08x} // {bias}"
        with open(bfile, "w+") as file:
            file.write(bias)

os.symlink("../../../neural.sim/sim_1/behav/layers", "layers", target_is_directory=True)
