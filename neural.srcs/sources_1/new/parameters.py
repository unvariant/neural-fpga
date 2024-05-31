from pathlib import Path
from fp import FP, FP_FULL_MASK
import fp
import os

class Layer:
    def __init__(self, weights, biases):
        self.weights = weights
        self.biases = biases

layers = [
    Layer(
        weights = [
            [0, 0], [ 0, 0 ],
        ],
        biases = [1, 1],
    ),
    Layer(
        weights = [
            [-5, 5],
        ],
        biases = [2],
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

# os.symlink(Path(".").absolute() / "layers", Path(".") / "../../../neural.sim/sim_1/behav/layers", target_is_directory=True)
# os.symlink(Path(".").absolute() / "layers", Path(".") / "../../../neural.sim/sim_1/behav/xsim/layers", target_is_directory=True)

# a = FP.raw(0x800)
# b = FP.raw(0x800)
# c = FP.raw((a.bits * b.bits >> fp.FP_FRACTION) & FP_FULL_MASK)
# print(a, b, c)

# print(FP.raw(0xe3d), FP.raw(0x570))

print("HEY")
print(FP(-0.11))
print(FP.raw(0xffffd800), FP.raw(0xffffe509), FP.raw(0xffffed54), FP.raw(0xffffe2a8))
