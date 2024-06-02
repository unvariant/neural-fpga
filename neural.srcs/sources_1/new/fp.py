import math

FP_BITS = 32 # total number of bits in the fixed point number
FP_INTEGER = 8 # bits assigned to the integer part of the number
FP_FRACTION = FP_BITS - FP_INTEGER # bits assigned to the fractional part of the number
FP_SIGN = FP_BITS - 1 # index of the sign bit
FP_INTEGER_MASK = (1 << FP_INTEGER) - 1 
FP_FRACTION_MASK = (1 << FP_FRACTION) - 1
FP_FULL_MASK = (1 << FP_BITS) - 1

# note that << and >> act as shift operators in python

FP_SATURATING_MAX_INTEGER_THRESHOLD = (1 << (FP_INTEGER - 1)) - 1
FP_SATURATING_MAX = (1 << (FP_BITS - 1)) - 1

class FP():
    def __init__(self, num: float):
        integer = abs(int(num))
        self.bits = integer << FP_FRACTION

        fraction = abs(num) % 1 # get the fractional part of the number ( after the decimal point)
        # the following loop will set the bits of the fractional part of the number
        for i in range(FP_FRACTION):
            power = -1 - i # the power of 2 that we are looking at (since binary system)
            part = 2 ** power # the value of the bit we are looking at 
            if part <= fraction:
                self.bits |= 1 << (FP_FRACTION - 1 - i) # if either the bit is 1 or Fraction is greater than 1, set the bit to 1
                fraction -= part 

        if num < 0:
            self.bits = (~self.bits & FP_FULL_MASK) + 1

        # print(f"bits = {self.bits:0{FP_BITS}b}") 

    def __repr__(self: "FP"): # this function is called when we print the object
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

    def mul(self, other: "FP"): # multiply two fixed point numbers
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
