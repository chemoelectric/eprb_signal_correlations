Visual Simulation of a Two-Channel Quantum Bell Experiment
----------------------------------------------------------

Run the program from the command line with something like

    Quantum-Correlations-Visualized pi/8
    Quantum-Correlations-Visualized 3pi/8
    Quantum-Correlations-Visualized 33.3

or run it without an argument to get a usage message.

This program simulates in animation an experiment of a kind for which
the Nobel Prize in Physics for the year 2022 was in part awarded. A
Wikipedia article on this kind of experiment can be found at
https://en.wikipedia.org/w/index.php?title=CHSH_inequality&oldid=1173584834
See also
https://en.wikipedia.org/w/index.php?title=Bell_test&oldid=1174875317#A_typical_CHSH_(two-channel)_experiment

There is a difference, however. In the simulation, the two polarizing
beam splitters are rotated continuously on axles, in unison. Also, the
photodetectors are able to tell whether the photons they detected were
the vertically polarized ones or the horizontally polarized ones. One
might suppose this information available as a ‘hidden variable’, if by
no other means. In any case, to calculate the correlation coefficient
it is necessary to take account of whether the photon was horizontally
or vertically polarized, and thus obviously this information is
implicitly assumed by quantum mechanics itself. We need the
information, so we can estimate the correlation coefficient.

The correlation coefficient is estimated by using detection
frequencies as stand-ins for probabilities. Various conditional
probabilities in this experimental arrangement take forms such as
cos²(this)×sin²(that) and so on. Thus one can substitute detection
frequencies for these, take square roots, use some algebra and
trigonometric identities, and eventually end up calculating an
approximation of the ideal value, −cos(2×(phi_2 − phi_1)). A little
care has to be taken with quadrants and signs, because there are
actually two square roots that are negatives of each other, but
otherwise the process is straightforward, if tedious. Before being
displayed, the estimated correlation coefficients are passed through a
digital lowpass filter with a very low cutoff frequency, so they do
not change too rapidly.

As for the sense of the correlation coefficient, some will prefer
+cos(2×(phi_2 − phi_1)). The sense is arbitrary, as long as it is kept
consistent, and then only if one cares about more than just the
magnitude of the coefficient.

Incidentally, a better way to write the coefficient is

     −(cos²(phi_2 − phi_1) − sin²(phi_2 − phi_1))

which expresses it in relative intensities of the two polarizing beam
splitters, according to the Law of Malus. The correlation coefficient
written in this form thus applies almost intuitively to
plane-polarized electromagnetic waves. And it is the formula actually
used in the program. It is equivalent to the other form via one of the
trigonometric double-angle identities found in CRC handbooks and
Wikipedia.
