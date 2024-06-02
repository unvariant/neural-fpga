import math

FP_BITS = 32
FP_INTEGER = 8
FP_FRACTION = FP_BITS - FP_INTEGER
FP_SIGN = FP_BITS - 1
FP_INTEGER_MASK = (1 << FP_INTEGER) - 1
FP_FRACTION_MASK = (1 << FP_FRACTION) - 1
FP_FULL_MASK = (1 << FP_BITS) - 1

FP_SATURATING_MAX_INTEGER_THRESHOLD = (1 << (FP_INTEGER - 1)) - 1
FP_SATURATING_MAX = (1 << (FP_BITS - 1)) - 1

class FP:
    def __init__(self, num: float):
        integer = abs(int(num))
        self.bits = integer << FP_FRACTION

        fraction = abs(num) % 1
        for i in range(FP_FRACTION):
            power = -1 - i
            part = 2 ** power
            if part <= fraction:
                self.bits |= 1 << (FP_FRACTION - 1 - i)
                fraction -= part

        if num < 0:
            self.bits = (~self.bits & FP_FULL_MASK) + 1

    def __repr__(self: "FP"):
        fraction = 0

        stuff = self.bits
        if self.sign():
            stuff = (~stuff & FP_FULL_MASK) + 1

        # print(f"bits = {stuff:0{FP_BITS}b}")

        bits = stuff & FP_FRACTION_MASK
        for i in range(FP_FRACTION):
            power = -1 - i
            fraction += (bits >> (FP_FRACTION - 1 - i) & 1) * 2 ** power

        sign_bit = self.bits >> FP_SIGN
        fraction = f"{fraction:.08f}"
        sign = "-" if sign_bit == 1 else ""
        integer = stuff >> FP_FRACTION
        return f"{sign}{integer}.{fraction[2:]}"

    @staticmethod
    def raw(raw: int):
        self = FP(0.0)
        self.bits = raw
        return self

    def sign(self):
        return self.bits >> FP_SIGN

    def mul(self, other: "FP"):
        self_extend = self.sign() * (FP_FULL_MASK << FP_BITS)
        other_extend = other.sign() * (FP_FULL_MASK << FP_BITS)
        temp = (self.bits | self_extend) * (other.bits | other_extend)
        temp >>= FP_FRACTION

        fixup = (self.sign() ^ other.sign()) & (other.bits != 0) & (self.bits != 0)
        integer = (temp >> FP_FRACTION) & FP_FULL_MASK

        if ((integer ^ fixup * FP_FULL_MASK) + fixup) > FP_SATURATING_MAX_INTEGER_THRESHOLD + fixup:
            return FP.raw(FP_SATURATING_MAX + fixup)

        temp %= (1 << FP_BITS)
        return FP.raw(temp)

    def add(self, other: "FP"):
        self_extend = self.sign() * (FP_FULL_MASK << FP_BITS)
        other_extend = other.sign() * (FP_FULL_MASK << FP_BITS)
        temp = (self.bits | self_extend) + (other.bits | other_extend)
        mask = (FP_INTEGER_MASK + (0b1 << FP_INTEGER))

        if self.sign() == other.sign():
            fixup = temp >> (FP_BITS * 2 - 1)
            integer = temp >> FP_FRACTION
            if ((integer ^ fixup * mask) + fixup) & mask > FP_SATURATING_MAX_INTEGER_THRESHOLD + fixup:
                return FP.raw(FP_SATURATING_MAX + self.sign())

        return FP.raw(temp & FP_FULL_MASK)

if __name__ == "__main__":
    hi = float(str(FP.raw(FP_SATURATING_MAX)))
    lo = float(str(FP.raw(FP_SATURATING_MAX + 1)))
    print(hi, lo)

    a = FP(-511)
    b = FP(-1)
    print(a, b)
    print(a.mul(b))

    for i in range(-(1 << (FP_INTEGER - 1)), 1 << (FP_INTEGER - 1)):
        for j in range(-(1 << (FP_INTEGER - 1)), 1 << (FP_INTEGER - 1)):
            a = FP(i)
            b = FP(j)
            assert float(str(a)) == float(i)
            assert float(str(b)) == float(j)

            c = a.mul(b)
            expected = float(i * j)
            if expected > hi:
                expected = hi
            if expected < lo:
                expected = lo
            assert float(str(c)) == expected, f"mul: \n{c} == {expected}\n{i}, {j}\n{a}, {b}"

            expected = float(i + j)
            if expected > hi:
                expected = hi
            if expected < lo:
                expected = lo
            d = a.add(b)
            assert float(str(d)) == expected, f"add: \n{d} == {expected}\n{i}, {j}\n{a}, {b}"
