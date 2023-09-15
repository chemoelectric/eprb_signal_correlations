#!/bin/env python3

from math import pi, sin, cos
import pyglet
from pyglet.shapes import Star, Arc, Line, BorderedRectangle

class QuantumCorrelationsVisualized(pyglet.window.Window):

    def __init__(self, Δφ):
        super().__init__(700, 500, "Quantum Correlations Visualized")
        pyglet.gl.glClearColor(1, 1, 1, 1)
        self.Δφ = Δφ
        self.t = 0.0
        self.k = 1.0
        self.batch = pyglet.graphics.Batch()

#        source_color=(255, 205, 0)
        source_color=(255, 143, 28)
        border_color=(83, 86, 90)
#        dial_color=(80, 7, 120)
        dial_color=(191, 13, 62)

        (φ1, φ2) = self.angles()        
        self.source = \
            Star(x=350, y=250, num_spikes=20, color=(255, 205, 0),
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
        self.channel_L_dial.x2 = 220+50*cos(φ1)
        self.channel_L_dial.y2 = 250+50*sin(φ1)
        self.channel_R_dial.x2 = 480+50*cos(φ2)
        self.channel_R_dial.y2 = 250+50*sin(φ2)

    def angles(self):
        """Compute the current angles of the two channels."""
        φ1 = self.k * self.t
        φ2 = φ1 + self.Δφ
        return (φ1 % (2 * pi), φ2 % (2 * pi))

if __name__ == "__main__":
    visualization = QuantumCorrelationsVisualized(pi/8)
    pyglet.clock.schedule_interval(visualization.update, 1/30)
    pyglet.app.run()


