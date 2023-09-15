#!/bin/env python3

from enum import Enum
from random import random, seed
from math import pi, sin, cos, sqrt
import pyglet
from pyglet.shapes import Star, Arc, Line, BorderedRectangle

π     = pi
π_2   = π / 2.0
π_3   = π / 3.0
π_4   = π / 4.0
π_6   = π / 6.0
π_8   = π / 8.0
π_180 = π / 180.0
two_π = 2.0 * π

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

class Signal(Enum):
    COUNTERCLOCKWISE = 1
    CLOCKWISE = 2

class Tag(Enum):
    CIRCLED_PLUS = 1
    CIRCLED_MINUS = 2

def countData(ζ1, ζ2, runLength):

    n_ac2c2 = 0
    n_ac2s2 = 0
    n_as2c2 = 0
    n_as2s2 = 0
    n_cs2s2 = 0
    n_cs2c2 = 0
    n_cc2s2 = 0
    n_cc2c2 = 0

    for i in range(runLength):

        σ = (Signal.COUNTERCLOCKWISE if random() < 0.5 else Signal.CLOCKWISE)

        r1 = random()
        x1 = (cos(ζ1) if σ == Signal.COUNTERCLOCKWISE else sin(ζ1))
        τ1 = (Tag.CIRCLED_PLUS if r1 < x1 * x1 else Tag.CIRCLED_MINUS)

        r2 = random()
        x2 = (cos(ζ2) if σ == Signal.COUNTERCLOCKWISE else sin(ζ2))
        τ2 = (Tag.CIRCLED_PLUS if r2 < x2 * x2 else Tag.CIRCLED_MINUS)

        if σ == Signal.COUNTERCLOCKWISE:
            if τ1 == Tag.CIRCLED_PLUS:
                if τ2 == Tag.CIRCLED_PLUS:
                    n_ac2c2 += 1
                else:
                    n_ac2s2 += 1
            else:
                if τ2 == Tag.CIRCLED_PLUS:
                    n_as2c2 += 1
                else:
                    n_as2s2 += 1
        else:
            if τ1 == Tag.CIRCLED_PLUS:
                if τ2 == Tag.CIRCLED_PLUS:
                    n_cs2s2 += 1
                else:
                    n_cs2c2 += 1
            else:
                if τ2 == Tag.CIRCLED_PLUS:
                    n_cc2s2 += 1
                else:
                    n_cc2c2 += 1

    return (n_ac2c2, n_ac2s2, n_as2c2, n_as2s2,
            n_cs2s2, n_cs2c2, n_cc2s2, n_cc2c2)

def estimate_ρ(counts, φ1, φ2):

    (n_ac2c2, n_ac2s2, n_as2c2, n_as2s2,
     n_cs2s2, n_cs2c2, n_cc2s2, n_cc2c2) = counts

    n = (n_ac2c2 + n_ac2s2 + n_as2c2 + n_as2s2 +
         n_cs2s2 + n_cs2c2 + n_cc2s2 + n_cc2c2)

    ac2c2 = n_ac2c2 / n
    ac2s2 = n_ac2s2 / n
    as2c2 = n_as2c2 / n
    as2s2 = n_as2s2 / n
    cs2s2 = n_cs2s2 / n
    cs2c2 = n_cs2c2 / n
    cc2s2 = n_cc2s2 / n
    cc2c2 = n_cc2c2 / n

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


class QuantumCorrelationsVisualized(pyglet.window.Window):

    def __init__(self, Δφ):
        super().__init__(700, 500, "Quantum Correlations Visualized")
        pyglet.gl.glClearColor(1, 1, 1, 1)
        self.Δφ = Δφ
        self.t = 0.0
        self.k = 1.0
        self.batch = pyglet.graphics.Batch()

        source_color=(246, 141, 46)
        border_color=(83, 86, 90)
        dial_color=(135, 24, 157)

        (φ1, φ2) = self.angles()        
        self.source = \
            Star(x=350, y=250, num_spikes=10, color=source_color,
                 outer_radius=50, inner_radius=2,
                 batch=self.batch)
        self.channel_L_border = \
            Arc(x=220, y=250, radius=50, color=border_color,
                batch=self.batch)
        self.channel_R_border = \
            Arc(x=480, y=250, radius=50, color=border_color,
                batch=self.batch)
        self.channel_L_dial = \
            Line(x=220, y=250, x2=250+50*cos(φ1), y2=250+50*sin(φ1),
                 color=dial_color, batch=self.batch)
        self.channel_R_dial = \
            Line(x=480, y=250, x2=450+50*cos(φ2), y2=250+50*sin(φ2),
                 color=dial_color, batch=self.batch)
        self.meter_L_outline = \
            BorderedRectangle(x=50, y=50, width=70, height=400,
                              border_color=border_color,
                              batch=self.batch)
        self.meter_R_outline = \
            BorderedRectangle(x=650 - 70, y=50, width=70, height=400,
                              border_color=border_color,
                              batch=self.batch)

    def on_draw(self):
        """Clear the screen and draw the visualization."""
        self.clear()
        self.batch.draw()

    def update(self, Δt):
        """Animate the visualization."""
        self.t += Δt
        (φ1, φ2) = self.angles()
        self.channel_L_dial.x2 = 220 + 50*cos(φ1)
        self.channel_L_dial.y2 = 250 + 50*sin(φ1)
        self.channel_R_dial.x2 = 480 + 50*cos(φ2)
        self.channel_R_dial.y2 = 250 + 50*sin(φ2)
        counts = countData(φ1, φ2, 10000)
        ρ_est = estimate_ρ(counts, φ1, φ2)

    def angles(self):
        """Compute the current angles of the two channels."""
        φ1 = self.k * self.t
        φ2 = φ1 + self.Δφ
        return (φ1 % two_π, φ2 % two_π)

if __name__ == "__main__":
    seed(a = 0, version = 2)
    visualization = QuantumCorrelationsVisualized(pi/8)
    pyglet.clock.schedule_interval(visualization.update, 1/30)
    pyglet.app.run()


