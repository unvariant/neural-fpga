class FPNum:
    def __init__(self, fp: "FP", bits: int):
        self.fp = fp
        self.bits = bits

    def __repr__(self):
        fraction = 0

        stuff = self.bits
        if self.sign():
            stuff = (~stuff & self.fp.MASK) + 1

        # print(f"bits = {stuff:0{FP_BITS}b}")

        bits = stuff & self.fp.FRACTION_MASK
        for i in range(self.fp.FRACTION):
            power = -1 - i
            fraction += (bits >> (self.fp.FRACTION - 1 - i) & 1) * 2 ** power

        sign_bit = self.bits >> self.fp.SIGN
        fraction = f"{fraction:.08f}"
        sign = "-" if sign_bit == 1 else ""
        integer = stuff >> self.fp.FRACTION
        return f"{sign}{integer}.{fraction[2:]}"

    def sign(self):
        return self.bits >> self.fp.SIGN

    def mul(self, other: "FPNum"):
        self_extend = self.sign() * (self.fp.MASK << self.fp.BITS)
        other_extend = other.sign() * (self.fp.MASK << self.fp.BITS)
        temp = (self.bits | self_extend) * (other.bits | other_extend) >> self.fp.FRACTION
        mask = self.fp.INTEGER_MASK + (self.fp.INTEGER_MASK << self.fp.INTEGER)

        fixup = (self.sign() ^ other.sign()) & (other.bits != 0) & (self.bits != 0)
        integer = (temp >> self.fp.FRACTION) & mask

        if ((integer ^ fixup * mask) + fixup) > self.fp.SATURATING_MAX_INTEGER_THRESHOLD + fixup:
            return self.fp.raw(self.fp.SATURATING_MAX + fixup)

        return self.fp.raw(temp & self.fp.MASK)

    def add(self, other: "FPNum"):
        self_extend = self.sign() * (self.fp.MASK << self.fp.BITS)
        other_extend = other.sign() * (self.fp.MASK << self.fp.BITS)
        temp = (self.bits | self_extend) + (other.bits | other_extend)
        mask = (self.fp.INTEGER_MASK + (0b1 << self.fp.INTEGER))

        if self.sign() == other.sign():
            fixup = temp >> (self.fp.BITS * 2 - 1)
            integer = temp >> self.fp.FRACTION
            if ((integer ^ fixup * mask) + fixup) & mask > self.fp.SATURATING_MAX_INTEGER_THRESHOLD + fixup:
                return self.fp.raw(self.fp.SATURATING_MAX + self.sign())

        return self.fp.raw(temp & self.fp.MASK)

class FP:
    def __init__(self, integer_bits: int, fractional_bits: int):
        self.INTEGER = integer_bits
        self.FRACTION = fractional_bits
        self.BITS = integer_bits + fractional_bits
        self.SIGN = self.BITS - 1
        self.INTEGER_MASK = (1 << self.INTEGER) - 1
        self.FRACTION_MASK = (1 << self.FRACTION) - 1
        self.MASK = (1 << self.BITS) - 1
        self.SATURATING_MAX_INTEGER_THRESHOLD = (1 << (self.INTEGER - 1)) - 1
        self.SATURATING_MAX = (1 << (self.BITS - 1)) - 1

    def new(self, num):
        hi = float(str(self.raw(self.SATURATING_MAX)))
        lo = float(str(self.raw(self.SATURATING_MAX + 1)))
        num = max(min(num, hi), lo)

        integer = abs(int(num))
        bits = integer << self.FRACTION

        fraction = abs(num) % 1
        for i in range(self.FRACTION):
            power = -1 - i
            part = 2 ** power
            if part <= fraction:
                bits |= 1 << (self.FRACTION - 1 - i)
                fraction -= part

        if num < 0:
            bits = (~bits & self.MASK) + 1

        return FPNum(self, bits)

    def raw(self, bits: int):
        return FPNum(self, bits & self.MASK)

    def write(self, file: str):
        with open("fixedpoint.sv.template", "r") as f:
            template = f.read()
        with open(file, "w+") as f:
            f.write(f"`define FP_INTEGER {self.INTEGER}\n")
            f.write(f"`define FP_FRACTION {self.FRACTION}\n")
            f.write(f"\n")
            f.write(template.strip())


# make sure saturation handling actually works
if __name__ == "__main__":
    fp = FP(integer_bits=8, fractional_bits=24)
    hi = float(str(fp.raw(fp.SATURATING_MAX)))
    lo = float(str(fp.raw(fp.SATURATING_MAX + 1)))
    print(hi, lo)

    for i in range(-(1 << (fp.INTEGER - 1)), 1 << (fp.INTEGER - 1)):
        for j in range(-(1 << (fp.INTEGER - 1)), 1 << (fp.INTEGER - 1)):
            a = fp.new(i)
            b = fp.new(j)
            assert float(str(a)) == float(i)
            assert float(str(b)) == float(j)

            c = a.mul(b)
            expected = max(min(float(i * j), hi), lo)
            assert float(str(c)) == expected, f"\nfailed multiply\ntest: {c} == {expected}\nintegers:\t{i}, {j}\nfixedpoint:\t{a}, {b}"

            expected = max(min(float(i + j), hi), lo)
            d = a.add(b)
            assert float(str(d)) == expected, f"failed addition\ntest: {d} == {expected}\nintegers:\t{i}, {j}\nfixedpoint:\t{a}, {b}"