#!/bin/env python3
#
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
#
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <https://unlicense.org>

from enum import Enum
from math import pi, cos, sin, sqrt
from random import random, seed

π     = pi
π_2   = π / 2.0
π_3   = π / 3.0
π_4   = π / 4.0
π_6   = π / 6.0
π_8   = π / 8.0
π_180 = π / 180.0
two_π = 2.0 * π

class Signal(Enum):
    COUNTERCLOCKWISE = 1
    CLOCKWISE = 2

class Tag(Enum):
    CIRCLED_PLUS = 1
    CIRCLED_MINUS = 2

class TaggedSignal:
    def __init__(self, τ, σ):
        assert(type(τ) is type(Tag.CIRCLED_PLUS))
        assert(type(σ) is type(Signal.COUNTERCLOCKWISE))
        self.τ = τ
        self.σ = σ

def assignTag(ζ, σ):
    assert(type(σ) is type(Signal.COUNTERCLOCKWISE))
    r = random()
    if σ == Signal.COUNTERCLOCKWISE:
        τ = (Tag.CIRCLED_PLUS if r < cos(ζ) ** 2 else Tag.CIRCLED_MINUS)
    else:
        τ = (Tag.CIRCLED_PLUS if r < sin(ζ) ** 2 else Tag.CIRCLED_MINUS)
    return TaggedSignal(τ = τ, σ = σ)

def collectData(ζ1, ζ2, runLength):
    data = []
    for i in range(runLength):
        σ = (Signal.COUNTERCLOCKWISE if random() < 0.5 else Signal.CLOCKWISE)
        σ1 = assignTag(ζ = ζ1, σ = σ)
        σ2 = assignTag(ζ = ζ2, σ = σ)
        data.append((σ1, σ2))
    return data

def count(rawData, σ, τ1, τ2):
    assert(type(σ) is type(Signal.COUNTERCLOCKWISE))
    assert(type(τ1) is type(Tag.CIRCLED_PLUS))
    assert(type(τ2) is type(Tag.CIRCLED_PLUS))
    n = 0
    for pair in rawData:
        assert(pair[0].σ == pair[1].σ)
        if pair[0].σ == σ and pair[0].τ == τ1 and pair[1].τ == τ2:
            n += 1
    return n

def frequency(rawData, σ, τ1, τ2):
    return count(rawData, σ, τ1, τ2) / len(rawData)

def cosine_sign(φ):
    return (-1.0 if cos(φ) < 0.0 else 1.0)

def sine_sign(φ):
    return (-1.0 if sin(φ) < 0.0 else 1.0)

def cc_sign(φ1, φ2):
    return cosine_sign(φ1) * cosine_sign(φ2)

def cs_sign(φ1, φ2):
    return cosine_sign(φ1) * sine_sign(φ2)

def sc_sign(φ1, φ2):
    return sine_sign(φ1) * cosine_sign(φ2)

def ss_sign(φ1, φ2):
    return sine_sign(φ1) * sine_sign(φ2)

def estimate_ρ_fromRawData(rawData, φ1, φ2):
    ac2c2 = frequency(rawData, Signal.COUNTERCLOCKWISE,
                      Tag.CIRCLED_PLUS, Tag.CIRCLED_PLUS)
    ac2s2 = frequency(rawData, Signal.COUNTERCLOCKWISE,
                      Tag.CIRCLED_PLUS, Tag.CIRCLED_MINUS)
    as2c2 = frequency(rawData, Signal.COUNTERCLOCKWISE,
                      Tag.CIRCLED_MINUS, Tag.CIRCLED_PLUS)
    as2s2 = frequency(rawData, Signal.COUNTERCLOCKWISE,
                      Tag.CIRCLED_MINUS, Tag.CIRCLED_MINUS)
    cs2s2 = frequency(rawData, Signal.CLOCKWISE,
                      Tag.CIRCLED_PLUS, Tag.CIRCLED_PLUS)
    cs2c2 = frequency(rawData, Signal.CLOCKWISE,
                      Tag.CIRCLED_PLUS, Tag.CIRCLED_MINUS)
    cc2s2 = frequency(rawData, Signal.CLOCKWISE,
                      Tag.CIRCLED_MINUS, Tag.CIRCLED_PLUS)
    cc2c2 = frequency(rawData, Signal.CLOCKWISE,
                      Tag.CIRCLED_MINUS, Tag.CIRCLED_MINUS)

    c2c2 = ac2c2 + cc2c2
    c2s2 = ac2s2 + cc2s2
    s2c2 = as2c2 + cs2c2
    s2s2 = as2s2 + cs2s2

    cc = cc_sign(φ1, φ2) * sqrt(c2c2)
    cs = cs_sign(φ1, φ2) * sqrt(c2s2)
    sc = sc_sign(φ1, φ2) * sqrt(s2c2)
    ss = ss_sign(φ1, φ2) * sqrt(s2s2)

    c12 = cc + ss
    s12 = sc - cs

    return (c12 * c12) - (s12 * s12)

def estimate_ρ(φ1, φ2, runLength):
    data = collectData(φ1, φ2, runLength)
    return estimate_ρ_fromRawData(data, φ1, φ2)

def printBellTests(delta_φ):
    runLength = 100000
    print(f'    φ₂ − φ₁ = {delta_φ / π_180 : 6.2f}°')
    for i in range(33):
        φ1 = i * π / 16.0
        φ2 = φ1 + delta_φ
        φ1_ = φ1 / π_180
        φ2_ = φ2 / π_180
        ρ_ = estimate_ρ(φ1, φ2, runLength)
        print(f'    φ₁ = {φ1_:6.2f}°  φ₂ = {φ2_:6.2f}°  ρ est. = {ρ_:7.5f}')
    return

def main():
    seed(a = 0, version = 2)
    print(f'')
    printBellTests(-π_8)
    print(f'')
    printBellTests(π_8)
    print(f'')
    printBellTests(-3 * π_8)
    print(f'')
    printBellTests(3 * π_8)
    print(f'')

if __name__ == '__main__':
    main()
