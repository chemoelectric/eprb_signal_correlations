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

#---------------------------------------------------------------------
#
# This program has a subversive purpose. There is actually nothing
# ‘quantum’ about it. There is no ‘entanglement’ or anything of the
# kind. The quantum physics orthodoxy is simply WRONG about what is
# going on. You are seeing what actually happens in a Bell test,
# generated by fully local, causal program activity, in which the
# correlations are there simply because the experiment was arranged
# that way.
#
# In mathematics, all methods must reach the same
# conclusion. Therefore there is no correct solution to the Bell test
# arrangement that reaches a conclusion different from that of quantum
# mechanics. All Bell inequalities, therefore, must simply be
# incorrect mathematical solutions to the experimental arrangement!
#
# Scientists have simply done their math incorrectly. Correct math
# requires a more sophisticated analysis that is taught to signal
# processing engineers but not to physicists. One needs such things as
# ‘joint probability density functions’ and multiple integration, and
# THEN one really does get THE SAME ANSWER as quantum mechanics. As
# you can see here, it really is so, even though physicists had
# thought it impossible. There is no ‘entanglement’, and yet there is
# obvious correlation.
#
# A Wikipedia article on this kind of experiment can be found at
# https://en.wikipedia.org/w/index.php?title=CHSH_inequality&oldid=1173584834
# See also
# https://en.wikipedia.org/w/index.php?title=Bell_test&oldid=1174875317#A_typical_CHSH_(two-channel)_experiment
#
#---------------------------------------------------------------------

import sys
from enum import Enum
from random import random, seed
from math import pi, sin, cos, sqrt, exp
import pyglet
from pyglet.shapes import *
from pyglet.text import Label

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

class Photon(Enum):
    HORIZONTAL = 1
    VERTICAL = 2

class Detector(Enum):
    PLUS = 1
    MINUS = 2

def countData(ζ1, ζ2, runLength):

    n_hpp = 0
    n_hpm = 0
    n_hmp = 0
    n_hmm = 0
    n_vpp = 0
    n_vpm = 0
    n_vmp = 0
    n_vmm = 0

    for i in range(runLength):

        σ1 = (Photon.HORIZONTAL if random() < 0.5
              else Photon.VERTICAL)
        σ2 = (Photon.VERTICAL if σ1 == Photon.HORIZONTAL
              else Photon.HORIZONTAL)

        r1 = random()
        x1 = (cos(ζ1) if σ1 == Photon.HORIZONTAL else sin(ζ1))
        τ1 = (Detector.PLUS if r1 < x1 * x1 else Detector.MINUS)

        r2 = random()
        x2 = (cos(ζ2) if σ2 == Photon.HORIZONTAL else sin(ζ2))
        τ2 = (Detector.PLUS if r2 < x2 * x2 else Detector.MINUS)

        if σ1 == Photon.HORIZONTAL:
            if τ1 == Detector.PLUS:
                if τ2 == Detector.PLUS:
                    n_hpp += 1
                else:
                    n_hpm += 1
            else:
                if τ2 == Detector.PLUS:
                    n_hmp += 1
                else:
                    n_hmm += 1
        else:
            if τ1 == Detector.PLUS:
                if τ2 == Detector.PLUS:
                    n_vpp += 1
                else:
                    n_vpm += 1
            else:
                if τ2 == Detector.PLUS:
                    n_vmp += 1
                else:
                    n_vmm += 1

    return (n_hpp, n_hpm, n_hmp, n_hmm,
            n_vpp, n_vpm, n_vmp, n_vmm)

def detector_dial_settings(counts):

    (n_hpp, n_hpm, n_hmp, n_hmm,
     n_vpp, n_vpm, n_vmp, n_vmm) = counts

    n_hp1 = n_hpp + n_hpm
    n_hm1 = n_hmp + n_hmm

    n_hp2 = n_hpp + n_hmp
    n_hm2 = n_hpm + n_hmm

    n_vp1 = n_vpp + n_vpm
    n_vm1 = n_vmp + n_vmm

    n_vp2 = n_vpp + n_vmp
    n_vm2 = n_vpm + n_vmm

    return (n_hp1 / (n_hp1 + n_hm1),
            n_hp2 / (n_hp2 + n_hm2),
            n_vp1 / (n_vp1 + n_vm1),
            n_vp2 / (n_vp2 + n_vm2))

def estimate_ρ(counts, φ1, φ2):

    (n_hpp, n_hpm, n_hmp, n_hmm,
     n_vpp, n_vpm, n_vmp, n_vmm) = counts

    n = (n_hpp + n_hpm + n_hmp + n_hmm +
         n_vpp + n_vpm + n_vmp + n_vmm)

    # Compute frequencies.
    hpp = n_hpp / n
    hpm = n_hpm / n
    hmp = n_hmp / n
    hmm = n_hmm / n
    vpp = n_vpp / n
    vpm = n_vpm / n
    vmp = n_vmp / n
    vmm = n_vmm / n

    # Estimate cos²(φ₁)cos²(φ₂), etc., using measured frequencies in
    # lieu of the probabilities.
    c2c2 = hpm + vmp
    c2s2 = hpp + vmm
    s2c2 = hmm + vpp
    s2s2 = hmp + vpm

    # Take square roots. Correct the signs for quadrants.
    cc = cc_sign(φ1, φ2) * sqrt(c2c2)
    cs = cs_sign(φ1, φ2) * sqrt(c2s2)
    sc = sc_sign(φ1, φ2) * sqrt(s2c2)
    ss = ss_sign(φ1, φ2) * sqrt(s2s2)

    # Use angle-difference identities to get cos(φ1-φ2) and
    # sin(φ1-φ2).
    c12 = cc + ss
    s12 = sc - cs

    # Return cos²(φ1-φ2)-sin²(φ1-φ2)=cos(2(φ1-φ2)).
    return (c12 * c12) - (s12 * s12)

xcenter = 350
ycenter = 250

xpbs_L = 220
ypbs_L = ycenter

xpbs_R = 480
ypbs_R = ycenter

meter_height = 300
ymeter = 100

xmeter_L_horiz = 50
xmeter_L_axis = 70
xmeter_L_vert = 80

xmeter_R_horiz = 620
xmeter_R_axis = 640
xmeter_R_vert = 650

font_name = "times new roman"
font_size = 10
font_color = (0, 0, 0, 255)

rho_text = 'correlation coefficient (lowpass filtered) = '
rho_subtext = \
    '(The formula used can be derived from quantum mechanics.)'
xrho = xcenter - 60
yrho = ycenter - 150
yrhosub = yrho - 20

class QuantumCorrelationsVisualized(pyglet.window.Window):

    def __init__(self, Δφ_string, Δφ):
        super().__init__(700, 500, "Quantum Correlations Visualized")
        pyglet.gl.glClearColor(1, 1, 1, 1)
        self.Δφ = Δφ
        self.t = 0.0
        self.k = 1.0
        self.batch = pyglet.graphics.Batch()

        self.ρ_filtered = 0.0

        border_color=(83, 86, 90)
        dial_color=(135, 24, 157)
        light_color=(246, 141, 46)
        join12_color=(244, 205, 212)
        join34_color=(229, 225, 230)

        self.bell_test = \
            Label('Two-channel Bell test without ‘entanglement’',
                  font_name=font_name, font_size=font_size*1.5,
                  x=xcenter, y=490, anchor_x='center', anchor_y='top',
                  color=font_color, batch=self.batch)

        self.math_wrong = \
            Label('(Theorists who have thought this impossible did ' +
                  'the math incorrectly.)', font_name=font_name,
                  font_size=font_size, x=xcenter, y=465,
                  anchor_x='center', anchor_y='top', color=font_color,
                  batch=self.batch)

        self.escape = \
            Label('Press ESC to exit.', font_name=font_name,
                  font_size=font_size, x=xcenter+200, y=10,
                  anchor_x='center', anchor_y='bottom',
                  color=font_color, batch=self.batch)

        (φ1, φ2) = self.angles()

        self.source1 = \
            Star(x=xcenter, y=ycenter, num_spikes=80,
                 color=light_color, outer_radius=20, inner_radius=2,
                 batch=self.batch)
        self.source2 = \
            Rectangle(x=xcenter-10, y=ycenter-2, width=20, height=4,
                      color=light_color, batch=self.batch)
        self.source3 = \
            Rectangle(x=xcenter-2, y=ycenter-10, width=4, height=20,
                      color=light_color, batch=self.batch)
        self.source_label = \
            Label('h/v polarized photons', font_name=font_name,
                  font_size=font_size, x=xcenter, y=ycenter+30,
                  anchor_x='center', anchor_y='center',
                  color=font_color, batch=self.batch)

        self.channel_L_border = \
            Arc(x=xpbs_L, y=ypbs_L, radius=50, color=border_color,
                batch=self.batch)
        self.channel_L_dial = \
            Line(x=xpbs_L, y=ypbs_L, x2=250+50*cos(φ1),
                 y2=250+50*sin(φ1), color=dial_color,
                 batch=self.batch)
        self.channel_L_label = \
            Label('PBS rotating on axle', font_name=font_name,
                  font_size=font_size, x=xpbs_L, y=ypbs_L+70,
                  anchor_x='center', anchor_y='center',
                  color=font_color, batch=self.batch)
        self.channel_L_phi = \
            Label('phi_1', font_name=font_name,
                  font_size=font_size, x=xpbs_L, y=ypbs_L-70,
                  anchor_x='center', anchor_y='center',
                  color=font_color, batch=self.batch)

        self.channel_R_border = \
            Arc(x=xpbs_R, y=ypbs_R, radius=50, color=border_color,
                batch=self.batch)
        self.channel_R_dial = \
            Line(x=xpbs_R, y=ypbs_R, x2=450+50*cos(φ2),
                 y2=250+50*sin(φ2), color=dial_color,
                 batch=self.batch)
        self.channel_R_label = \
            Label('PBS rotating on axle', font_name=font_name,
                  font_size=font_size, x=xpbs_R, y=ypbs_R+70,
                  anchor_x='center', anchor_y='center',
                  color=font_color, batch=self.batch)
        self.channel_R_phi = \
            Label('phi_2 = phi_1 + ' + Δφ_string, font_name=font_name,
                  font_size=font_size, x=xpbs_R, y=ypbs_R-70,
                  anchor_x='center', anchor_y='center',
                  color=font_color, batch=self.batch)

        self.meter_L_horizontal = \
            Rectangle(x=xmeter_L_horiz-10, y=ymeter, width=20,
                      height=4, color=light_color, batch=self.batch)
        self.meter_L_vertical = \
            Rectangle(x=xmeter_L_vert-2, y=ymeter, width=4, height=20,
                      color=light_color, batch=self.batch)
        self.meter_L_axis = \
            Line(x=xmeter_L_axis, y=ymeter, x2=xmeter_L_axis,
                 y2=ymeter + meter_height, color=border_color,
                 batch=self.batch)
        self.meter_L_tics = \
            [Line(x=xmeter_L_axis-3, y=ymeter+(i*meter_height/10),
                  x2=xmeter_L_axis+2, y2=ymeter+(i*meter_height/10),
                  color=border_color, batch=self.batch)
             for i in range(11)]
        self.meter_L_label = \
            Label('Detector predominance', font_name=font_name,
                  font_size=font_size, x=xmeter_L_axis+10,
                  y=ymeter+meter_height+15, anchor_x='center',
                  anchor_y='bottom', color=font_color,
                  batch=self.batch)
        self.meter_L_plus = \
            Label('+', font_name=font_name, font_size=font_size*2,
                  x=xmeter_L_axis-50, y=ymeter+meter_height,
                  anchor_x='center', anchor_y='top', color=font_color,
                  batch=self.batch)
        self.meter_L_minus = \
            Label('-', font_name=font_name, font_size=font_size*2,
                  x=xmeter_L_axis-50, y=ymeter, anchor_x='center',
                  anchor_y='bottom', color=font_color,
                  batch=self.batch)

        self.meter_R_horizontal = \
            Rectangle(x=xmeter_R_horiz-10, y=ymeter, width=20,
                      height=4, color=light_color, batch=self.batch)
        self.meter_R_vertical = \
            Rectangle(x=xmeter_R_vert-2, y=ymeter, width=4, height=20,
                      color=light_color, batch=self.batch)
        self.meter_R_axis = \
            Line(x=xmeter_R_axis, y=ymeter, x2=xmeter_R_axis,
                 y2=ymeter + meter_height, color=border_color,
                 batch=self.batch)
        self.meter_R_tics = \
            [Line(x=xmeter_R_axis-3, y=ymeter+(i*meter_height/10),
                  x2=xmeter_R_axis+2, y2=ymeter+(i*meter_height/10),
                  color=border_color, batch=self.batch)
             for i in range(11)]
        self.meter_R_label = \
            Label('Detector predominance', font_name=font_name,
                  font_size=font_size, x=xmeter_R_axis-20,
                  y=ymeter+meter_height+15, anchor_x='center',
                  anchor_y='bottom', color=font_color,
                  batch=self.batch)
        self.meter_R_plus = \
            Label('+', font_name=font_name, font_size=font_size*2,
                  x=xmeter_R_axis+35, y=ymeter+meter_height,
                  anchor_x='center', anchor_y='top', color=font_color,
                  batch=self.batch)
        self.meter_R_minus = \
            Label('-', font_name=font_name, font_size=font_size*2,
                  x=xmeter_R_axis+35, y=ymeter, anchor_x='center',
                  anchor_y='bottom', color=font_color,
                  batch=self.batch)

        self.join1 = \
            Line(x=xmeter_L_horiz+10, y=ymeter, x2=xmeter_R_vert-2,
                 y2=ymeter, color=join12_color, batch=self.batch)
        self.join2 = \
            Line(x=xmeter_L_vert+2, y=ymeter, x2=xmeter_R_horiz-10,
                 y2=ymeter, color=join12_color, batch=self.batch)
        self.join3 = \
            Line(x=xmeter_L_horiz+10, y=ymeter, x2=xmeter_R_horiz-10,
                 y2=ymeter, color=join34_color, batch=self.batch)
        self.join4 = \
            Line(x=xmeter_L_vert+2, y=ymeter, x2=xmeter_R_vert-2,
                 y2=ymeter, color=join34_color, batch=self.batch)

        self.correlation_coef = \
            Label(text=rho_text, font_name=font_name,
                  font_size=font_size, x=xrho, y=yrho,
                  anchor_x='left', anchor_y='top', color=font_color,
                  batch=self.batch)
        self.correlation_coef_sub = \
            Label(text=rho_subtext, font_name=font_name,
                  font_size=font_size*0.9, x=xrho+10, y=yrhosub,
                  anchor_x='left', anchor_y='top', color=font_color,
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

        (detL_horiz, detR_horiz, detL_vert, detR_vert) = \
            detector_dial_settings(counts)

        self.meter_L_horizontal.y = \
            ymeter - 2 + meter_height*(1.0 - detL_horiz)
        self.meter_L_vertical.y = \
            ymeter - 10 + meter_height*(1.0 - detL_vert)

        self.meter_R_horizontal.y = \
            ymeter - 2 + meter_height*(1.0 - detR_horiz)
        self.meter_R_vertical.y = \
            ymeter - 10 + meter_height*(1.0 - detR_vert)

        self.join1.y = self.meter_L_horizontal.y + 2
        self.join1.y2 = self.meter_R_vertical.y + 10

        self.join2.y = self.meter_L_vertical.y + 10
        self.join2.y2 = self.meter_R_horizontal.y + 2

        self.join3.y = self.meter_L_horizontal.y + 2
        self.join3.y2 = self.meter_R_horizontal.y + 2

        self.join4.y = self.meter_L_vertical.y + 10
        self.join4.y2 = self.meter_R_vertical.y + 10

        ρ_est = estimate_ρ(counts, φ1, φ2)

        # Single-pole IIR lowpass filter, cutoff freq. 0.01 Hz.
        self.ρ_filtered += \
            (1.0 - exp (-0.01 * two_π)) * (ρ_est - self.ρ_filtered)
        self.correlation_coef.text = \
            rho_text + f'{self.ρ_filtered:.5}'

    def angles(self):
        """Compute the current angles of the two channels."""
        φ1 = self.k * self.t
        φ2 = φ1 + self.Δφ
        return (φ1 % two_π, φ2 % two_π)

def quantum_correlations_visualized():

    def print_usage():
        print("Usage: python3 " + sys.argv[0] + " ANGLE")
        print("  where ANGLE is '0', 'pi/8', 'pi/4', '3pi/8', 'pi/2',")
        print("  or a number specifying an angle in degrees.")

    seed(a = 0, version = 2)
    if len(sys.argv) != 2:
        print_usage()
        exit(1)
    Δφ_string = sys.argv[1]
    if Δφ_string == "0":
        Δφ = 0
    elif Δφ_string == "pi/8":
        Δφ = π_8
    elif Δφ_string == "pi/4":
        Δφ = π_4
    elif Δφ_string == "3pi/8":
        Δφ = 3 * π_8
    elif Δφ_string == "pi/2":
        Δφ = π_2
    else:
        try:
            Δφ = int(Δφ_string) * π_180
            Δφ_string = Δφ_string + " deg"
        except:
            print_usage()
            exit(1)
    visualization = QuantumCorrelationsVisualized(Δφ_string, Δφ)
    pyglet.clock.schedule_interval(visualization.update, 0.05)
    pyglet.app.run()

if __name__ == "__main__":
    quantum_correlations_visualized()
