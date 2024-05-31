import math

FP_BITS = 32
FP_INTEGER = 20
FP_FRACTION = 12
FP_SIGN = 31
FP_INTEGER_MASK = (1 << FP_INTEGER) - 1
FP_FRACTION_MASK = (1 << FP_FRACTION) - 1
FP_FULL_MASK = (1 << FP_BITS) - 1

integer_bits = 10
fraction_bits = 32-integer_bits
sign_bit_position = integer_bits + fraction_bits - 1
integer_mask = (1 << integer_bits) - 1
fraction_mask = (1 << fraction_bits) - 1
full_mask = (1 << (integer_bits + fraction_bits)) - 1

FP_SATURATING_MAX_INTEGER_THRESHOLD = (1 << (integer_bits - 1)) - 1
FP_SATURATING_MAX = (1 << (integer_bits + fraction_bits - 1)) - 1

class FP:
    def __init__(self, num: float):
        integer = int(num) & integer_mask
        self.bits = integer << FP_FRACTION

        fraction = num % 1
        for i in range(FP_FRACTION):
            power = -1 - i
            part = 2 ** power
            if part <= fraction:
                self.bits |= 1 << (FP_FRACTION - 1 - i)
                fraction -= part

    def __repr__(self: "FP"):
        fraction = 0

        bits = self.bits & FP_FRACTION_MASK
        for i in range(FP_FRACTION):
            power = -1 - i
            fraction += (bits >> (FP_FRACTION - 1 - i) & 1) * 2 ** power

        sign_bit = self.bits >> FP_SIGN
        fraction = f"{fraction:.08f}"
        sign = "-" if sign_bit == 1 else ""
        integer = ((self.bits >> FP_FRACTION) ^ (sign_bit * FP_INTEGER_MASK)) + sign_bit
        return f"{sign}{integer}.{fraction[2:]}"

    @staticmethod
    def raw(raw: int):
        self = FP(0.0)
        self.bits = raw
        return self

    def sign(self):
        return self.bits >> FP_SIGN

    def mul(self, other: "FP"):
        self_extend = self.sign() * (full_mask << FP_BITS)
        other_extend = other.sign() * (full_mask << FP_BITS)
        temp = (self.bits | self_extend) * (other.bits | other_extend)
        temp >>= fraction_bits

        fixup = (self.sign() ^ other.sign()) * (other.bits != 0) * (self.bits != 0)
        mask = FP_INTEGER_MASK | (FP_INTEGER_MASK << FP_INTEGER)
        integer = (temp >> fraction_bits) & mask
        # print(fixup)
        # print(f"integer = {integer:0{integer_bits * 2}b}")
        # thing = ((integer ^ fixup * mask) + fixup)
        # print(f"thing   = {thing:0{integer_bits*2}b}")
        # print(f"max     = {FP_SATURATING_MAX_INTEGER_THRESHOLD:0{integer_bits*2}b}")

        if ((integer ^ fixup * mask) + fixup) > FP_SATURATING_MAX_INTEGER_THRESHOLD + fixup:
            return FP.raw(FP_SATURATING_MAX + fixup)

        temp %= (1 << FP_BITS)
        return FP.raw(temp)

    def add(self, other: "FP"):
        temp = self.bits + other.bits

        if self.sign() == other.sign():
            if (temp >> FP_FRACTION) % (1 << (FP_INTEGER - 1)) > FP_SATURATING_MAX_INTEGER_THRESHOLD + self.sign():
                return FP.raw(FP_SATURATING_MAX + self.sign())
            else:
                return FP.raw((self.bits & (1 << FP_SIGN)) | (self.bits % ((1 << FP_SIGN) - 1)))

        return FP.raw(temp & full_mask)

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
            assert float(str(c)) == expected, f"\n{c} == {expected}\n{i}, {j}\n{a}, {b}"

            expected = float(i + j)
            if expected > hi:
                expected = hi
            if expected < lo:
                expected = lo
            d = a.add(b)
            assert float(str(d)) == expected, f"\n{c} == {expected}\n{i}, {j}\n{a}, {b}"
