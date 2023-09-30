% -*- mode: indented-text; tab-width: 2; -*-
%
% This is free and unencumbered software released into the public domain.
%
% Anyone is free to copy, modify, publish, use, compile, sell, or
% distribute this software, either in source code form or as a compiled
% binary, for any purpose, commercial or non-commercial, and by any
% means.
%
% In jurisdictions that recognize copyright laws, the author or authors
% of this software dedicate any and all copyright interest in the
% software to the public domain. We make this dedication for the benefit
% of the public at large and to the detriment of our heirs and
% successors. We intend this dedication to be an overt act of
% relinquishment in perpetuity of all present and future rights to this
% software under copyright law.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
% IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
% OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
% ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
% OTHER DEALINGS IN THE SOFTWARE.
%
% For more information, please refer to <https://unlicense.org>

\frenchspacing

@f crayton void
@f crayton_pair void
@f cray_ban void
@f event_data void
@f series_data void

@* Magically Entangled Craytons. What follows are instructions on how
to write a program that, on an ordinary computer, will
quantum-entangle two variables so that there is action at a distance
between them when they are printed out. Normally such a program would
require a quantum computer, but the program {\it you} write will be
magical.

I will myself write a magical C program that does the same thing.

That the programs we write must be magical is guaranteed to us by the
2022 Nobel Prize winners in Physics. There is not the slightest chance
in the world that Nobel Prize winners in Physics, and their
colleagues, could be people who do not follow Scientific Method. There
is no way they would not go even to the slight trouble of writing a
simple simulation to observe what happens, before publishing thousands
of papers and books, and encouraging governments to spend billions and
billions of dollars. They would not also publish voluminously about
random process analysis without ever consulting an expert. So what
occurs in our programs must be nothing less than magic.

@ We will need a way to pick arbitrary numbers between zero and one,
without showing much bias. The method need not be particularly
fancy. It will not matter whether zero or one are themselves
included. The following algorithm, consisting of a global variable and
a function returning a floating point number, will suffice on most
modern computers. (Or you could just use your programming language's
``random number'' facilities.)

@<arbitrary numbers between zero and one@>=
int a_global_variable = 12345;

double
number_between_zero_and_one ()
{
  int i = a_global_variable * 75;
  while (i > 65537) i = i - 65537;
  a_global_variable = i;
  return ((1.0 * i) / 65537.0);
}

@ Now to the magical program itself. The first thing we need is the
magical variables. These will be of a type called |crayton|, whose
value will be either |updown| or |sideways|. How to write that in your
language will vary, but here is one way to write it in C.

@<the |crayton| type@>=
typedef enum {updown, sideways} crayton;

@ We have a special source of |crayton| variables. It produces two
|crayton|, one of them |updown| and the other |sideways|. Which of the
two |crayton| is which, however, is, over time, an unbiased mixture of
both ways. This is ensured by use of |@<arbitrary numbers between zero
and one@>|.

In the C code, the two |crayton| will be returned in the C version of
a record structure. This pair of |crayton| variables will be the pair
the program magically entangles.

@<the |crayton| source@>=
typedef struct {crayton k1; crayton k2;} crayton_pair;

crayton_pair
crayton_source ()
{
  crayton_pair pair;
  if (number_between_zero_and_one () < 0.5)
    {
      pair.k1 = updown;
      pair.k2 = sideways;
    }
  else
    {
      pair.k1 = sideways;
      pair.k2 = updown;
    }
  return pair;
}

@ As with many a magic trick, we need mirrors. What we need here is
the digital equivalent of a device made from a kind of mirror that
breaks a beam of light into two beams. But this mirror is also the
digital equivalent of a polarizing filter. This all seems very
complicated, but in fact the type for the entire mess is just a
floating point number capable of representing an angle in radians. The
angle is simply how much someone has rotated the angle of the
filter. We will have a pair of them, so let us call the type a
polarized |cray_ban|.

@<the |cray_ban| type@>=
typedef double cray_ban;

@ Such a magic trick as ours also needs smoke. In this case, the smoke
comprises classical physics done, by doctors of philosophy in physics
or mathematics, so shockingly incorrectly that you go
psychosomatically blind. Once you are blinded, the doctors of
philosophy can implant illusions into your brain. However, there is
not space here for phony mathematics, so we refer you to the quantum
physics literature instead.

Having dived into the literature (or better yet {\it not\/} having
dived into the literature, but merely imagined yourself having done
so), please leave yourself a chance to recover your vision. You may
need as medicaments the following reminders: \medskip

\item{\bullet} Let $a$ and~$b$ represent propositions,
and~$a{\wedge}b$ their joint proposition. The {\it definition\/} of
their conditional probability is
$$P(a{\vert}b)=P(a{\wedge}b)\,/\,P(b) $$
This definition is {\it purely mathematical} and is complete
in itself. Nevertheless, if you have read the ``smoke'' literature,
you will have seen that none other than John Stewart Bell, Fellow of
the Royal Society, redefined the conditional probability as follows:
$$P(a{\vert}b) = \cases{P(a{\wedge}b)\,/\,P(b) &{\rm pretty\ much\ never}\cr
                        P(a) &{\rm if\ ``local\ causality,''\ beables,%
                        \ socks,\ heart\ attacks,\ $\lambda$,\ etc.}\cr} $$
Most individuals familiar with mathematics will recognize
that this is a license to declare ``proved'' any pseudo-mathematical
nonsense one wishes, such as that $1=0$ and $E=mc^{9}$.
The concussion of a Fellow of the
Royal Society proudly displaying such a license is what rendered you
psychosomatically blind.

\item{\bullet} The claim that quantum physics is ``irreducible'' to
classical physics, though usually assumed to be a claim about physics,
is actually the {\it mathematical\/} claim---and an alarming
one---that a quantum physics problem, written in logically equivalent
form but in a mathematics other than that of quantum physics, cannot
exist, cannot be solved, or will come to a different result! For, once
put in the form of a word problem, physics becomes applied
mathematics, and ``classical physics'' becomes merely the application
of any and all mathematics to the reasonable solution of such word
problems. Despite public address systems blaring pronouncements
through billows of smoke, nothing resembling a smidgen of proof of
such ``irreducibility'' has ever been produced. The literature,
however, does employ imcompetence in mathematics {\it to give the
impression\/} of such ``irreducibility.'' The practitioner of such
incompetence merely gives up short of a solution, proclaiming, ``That
is all that can {\it possibly\/} be done. Now please run experiments
showing {\it these\/} are not the results obtained empirically.'' The
encounter of scientists not even {\it trying\/} to solve problems
causes temporary shriveling of the hypothalamus, and thus blindness is
merely a portion of the psychosomatic injury.

@ A |cray_ban| does not deal with a beam of light, but instead with a
|crayton|. It decides which of two ways to send a |crayton| (we will
number the ways $+1$ and~$-1$) according to an algorithm that depends
on |@<arbitrary numbers between zero and one@>|. Students of optics
may recognize this algorithm as the {\it Law of Malus}, but here we
will call it the {\it Law of Logodaedalus}, because that sounds more
magical.

@<the Law of Logodaedalus@>=
int
law_of_logodaedalus (cray_ban angle, crayton crayton_that_will_be_sent)
{
  double x;
  int i;
  if (crayton_that_will_be_sent == updown)
    x = sin (angle);
  else
    x = cos (angle);
  if (number_between_zero_and_one () < (x * x))
    i = +1;
  else
    i = -1;
  return i;
}

@ So here is what one event of the experiment looks like. There is the
one |crayton| source and there are two |cray_ban|, set respectively to
their angles. Each |crayton| in the pair is put through a respective
|cray_ban|. Data is recorded. You can return the data in a record, as
in the following C code, or do whatever you prefer.

@<an experimental event@>=
typedef struct
{
  crayton_pair pair;
  int way_k1_was_sent;
  int way_k2_was_sent;
} event_data;

event_data
experimental_event (cray_ban angle1, cray_ban angle2)
{
  event_data data;
  data.pair = crayton_source ();
  data.way_k1_was_sent = law_of_logodaedalus (angle1, pair.k1);
  data.way_k2_was_sent = law_of_logodaedalus (angle2, pair.k2);
  return data;
}

@ One wishes to run a series of events, all with one particular pair
of |cray_ban| angles, and count the different types of
coincidence. For this there is a new record type, the |series_data|,
containing the total number of events and the number of each type of
event. (The total number of events will equal the sum of the other
fields.)

You do not have to use a record type, of course. This is just one way
to represent the information. By using records a lot, I am avoiding a
confusing C feature called ``pointers.''

@<the |series_data| type@>=
typedef struct
{
  cray_ban angle1;
  cray_ban angle2;
  int number_of_events;
  int number_of_updown_sideways_plus_plus;
  int number_of_updown_sideways_plus_minus;
  int number_of_updown_sideways_minus_plus;
  int number_of_updown_sideways_minus_minus;
  int number_of_sideways_updown_plus_plus;
  int number_of_sideways_updown_plus_minus;
  int number_of_sideways_updown_minus_plus;
  int number_of_sideways_updown_minus_minus;
} series_data;

@ Thus a series of |n| events may be run as follows. And it so happens
that the |crayton| pairs will be magically entangled!

@<a series of |n| experimental events@>=
series_data
experimental_series (cray_ban angle1, cray_ban angle2, int n)
{
  series_data sdata;
  sdata.angle1 = angle1;
  sdata.angle2 = angle2;
  sdata.number_of_events = n;
  sdata.number_of_updown_sideways_plus_plus = 0;
  sdata.number_of_updown_sideways_plus_minus = 0;
  sdata.number_of_updown_sideways_minus_plus = 0;
  sdata.number_of_updown_sideways_minus_minus = 0;
  sdata.number_of_sideways_updown_plus_plus = 0;
  sdata.number_of_sideways_updown_plus_minus = 0;
  sdata.number_of_sideways_updown_minus_plus = 0;
  sdata.number_of_sideways_updown_minus_minus = 0;
  for (int i = 0; i != n; i = i + 1) /* Do |n| times. */
    {
      event_data edata = experimental_event (angle1, angle2);
      if (edata.pair.k1 == updown)
        {
          if (edata.way_k1_was_sent == +1)
            {
              if (edata.way_k2_was_sent == +1)
                {
                  sdata.number_of_updown_sideways_plus_plus = @|
                    sdata.number_of_updown_sideways_plus_plus + 1;
                }
              else
                {
                  sdata.number_of_updown_sideways_plus_minus = @|
                    sdata.number_of_updown_sideways_plus_minus + 1;
                }
            }
          else
            {
              if (edata.way_k2_was_sent == +1)
                {
                  sdata.number_of_updown_sideways_minus_plus = @|
                    sdata.number_of_updown_sideways_minus_plus + 1;
                }
              else
                {
                  sdata.number_of_updown_sideways_minus_minus = @|
                    sdata.number_of_updown_sideways_minus_minus + 1;
                }
            }
        }
      else
        {
          if (edata.way_k1_was_sent == +1)
            {
              if (edata.way_k2_was_sent == +1)
                {
                  sdata.number_of_sideways_updown_plus_plus = @|
                    sdata.number_of_sideways_updown_plus_plus + 1;
                }
              else
                {
                  sdata.number_of_sideways_updown_plus_minus = @|
                    sdata.number_of_sideways_updown_plus_minus + 1;
                }
            }
          else
            {
              if (edata.way_k2_was_sent == +1)
                {
                  sdata.number_of_sideways_updown_minus_plus = @|
                    sdata.number_of_sideways_updown_minus_plus + 1;
                }
              else
                {
                  sdata.number_of_sideways_updown_minus_minus = @|
                    sdata.number_of_sideways_updown_minus_minus + 1;
                }
            }
        }
    }
  return sdata;
}

@* Proof of Entanglement. The ``smoke'' mentioned earlier contains
some techniques for ``showing'' {\it absence\/} of
entanglement---though actually the audience have had their
hypothalamuses temporarily withered. Really they are being
mind-controlled, as if in a Philip~K. Dick novel. However, {\it you\/} do not
practice mind-control (I hope), and {\it our\/} task is different: we must
show {\it presence\/} of entanglement. Thus we will do nothing less
than show that our experiment is empirically consistent with a formula
from quantum mechanics: the correlation coefficient for our
experimental arrangement. According to the 2022 Nobel Prize winners in
Physics, this would be impossible unless the |crayton| pairs were
entangled. The entanglement, then, {\it must\/} be so, because these exemplars of
science won the Nobel Prize for it. Thus the |crayton| pairs were
indeed entangled.

So, then, a {\it correlation coefficient\/} is what? It is a value
between $-1$ and~$+1$ that gives some idea how interrelated are two
functions or sets of data. It is a notion familiar in the field of
statistics, but also in the theory of waves, where it indicates the
capacity of two waves (if superposed) to form different interference
patterns. For this experiment, we want the correlation coefficient
comparing the ``way the |crayton| was sent'' of the two |crayton| in
the pair. Assume the two |cray_ban| settings are $\phi_1$
and~$\phi_2$. The formula from quantum mechanics is then
$$ \eqalign{{\it correlation\ coefficient} & = \cos\,\lbrace2(\phi_1-\phi_2)\rbrace \cr
        &        = \cos^2(\phi_1-\phi_2) - \sin^2(\phi_1-\phi_2) \cr} $$
or the same formula with the sign reversed, because (like, say, a
cross product) a correlation coefficient has arbitrary sense. The
formula itself makes it evident that only the size of the angle
between $\phi_1$ and~$\phi_2$ matters, not the direction of the
subtraction. It is also clear that the formula is {\it invariant with
rotations of the |cray_ban| pair}---it does not matter what the
particular angles are, but only what they are relative to each other.
Some might also notice that there is a resemblance to the Law of
Logodaedalus---this is not accidental, but let us not go into the
details.

@ What the exemplars of science tell us is that if we run four series
of the experiment, using the following settings, and get approximately
the results predicted by quantum mechanics, then we have proved that
our |crayton| pairs were entangled.

Actually they do not know about the |crayton| specifically, but only
about other objects they do not know how to test this with, so they
have invented other tests, such as shouting ``{\sc LOOK THAT WAY!}''
and running out of the room. But we do have the |crayton| and so can
run the test.

The settings and corresponding correlation coefficients are as
follows:
$$\phi_1,\phi_2=\cases{0,\, \pi/8         & {$+1/\sqrt2\approx+0.70711$} \cr
                       0,\, 3\,\pi/8      & {$-1/\sqrt2\approx-0.70711$} \cr
                       \pi/4,\, \pi/8     & {$+1/\sqrt2\approx+0.70711$} \cr
                       \pi/4,\, 3\,\pi/8  & {$+1/\sqrt2\approx+0.70711$} \cr}$$

@ Now we are going to do some clever stuff. We are going to use the
data we have collected, together with the Law of Logodaedalus, to
compute the correlation coefficient empirically. More specifically, we
are going to use {\it frequencies of the recorded events\/} to get
estimates of trigonometric functions of $\phi_1$ and~$\phi_2$, which
we will then use to compute an approximation of $\cos^2(\phi_1-\phi_2)
- \sin^2(\phi_1-\phi_2)$.

@ Obtaining the frequencies is a simple matter of computing
ratios. Given a |series_data| record |sdata|:

@<frequencies of events@>=
double freq_of_updown_sideways_plus_plus = @|
       (1.0 * sdata.number_of_updown_sideways_plus_plus)@, / sdata.number_of_events;
double freq_of_updown_sideways_plus_minus = @|
       (1.0 * sdata.number_of_updown_sideways_plus_minus)@, / sdata.number_of_events;
double freq_of_updown_sideways_minus_plus = @|
       (1.0 * sdata.number_of_updown_sideways_plus_minus)@, / sdata.number_of_events;
double freq_of_updown_sideways_minus_minus = @|
       (1.0 * sdata.number_of_updown_sideways_minus_minus)@, / sdata.number_of_events;
double freq_of_sideways_updown_plus_plus = @|
       (1.0 * sdata.number_of_sideways_updown_plus_plus)@, / sdata.number_of_events;
double freq_of_sideways_updown_plus_minus = @|
       (1.0 * sdata.number_of_sideways_updown_plus_minus)@, / sdata.number_of_events;
double freq_of_sideways_updown_minus_plus = @|
       (1.0 * sdata.number_of_sideways_updown_plus_minus)@, / sdata.number_of_events;
double freq_of_sideways_updown_minus_minus = @|
       (1.0 * sdata.number_of_sideways_updown_minus_minus)@, / sdata.number_of_events;

@ From the Law of Logodaedalus, it is possible to use these
frequencies as estimates of products of the squares of cosines and
sines of $\phi_1$ and~$\phi_2$. I leave it as an exercise for the
reader to convince themselves of this fact. (Not only do I not have
space to prove such things to lazyboneses, but also it is good
exercise for the little gray cells.) Thus:

@<estimates of certain products@>=
double estimate_of_cos2_phi1_cos2_phi2 = @|
  freq_of_updown_sideways_minus_plus + freq_of_sideways_updown_plus_minus;
double estimate_of_cos2_phi1_sin2_phi2 = @|
  freq_of_updown_sideways_minus_minus + freq_of_sideways_updown_plus_plus;
double estimate_of_sin2_phi1_cos2_phi2 = @|
  freq_of_updown_sideways_plus_plus + freq_of_sideways_updown_minus_minus;
double estimate_of_sin2_phi1_sin2_phi2 = @|
  freq_of_updown_sideways_plus_minus + freq_of_sideways_updown_minus_plus;

@ The following angle-difference identities may be found in reference books:
$$\eqalign{\cos(\alpha-\beta)&=\cos\alpha\cos\beta+\sin\alpha\sin\beta \cr
           \sin(\alpha-\beta)&=\sin\alpha\cos\beta-\cos\alpha\sin\beta \cr}$$
We can obtain estimates of the terms on the right side by taking
square roots of the results from |@<estimates of certain
products@>|. There are, of course, {\it two\/} square roots, one
positive and one negative, and so we must know which one to
use. However, all of our $\phi_1,\phi_2$ settings are for angles in
Quadrant~I, and therefore only positive square roots will be needed.
Thus:

@<estimates of the angle-difference functions@>=
  double estimate_of_cos_phi1_minus_phi2 = @|
    sqrt (estimate_of_cos2_phi1_cos2_phi2) + sqrt (estimate_of_sin2_phi1_sin2_phi2);
  double estimate_of_sin_phi1_minus_phi2 = @|
    sqrt (estimate_of_sin2_phi1_cos2_phi2) - sqrt (estimate_of_cos2_phi1_sin2_phi2);

@ Finally, then, one can estimate the correlation coefficient:

@<estimate of the correlation coefficient@>=
  double estimate_of_correlation_coefficient = @|
    (estimate_of_cos_phi1_minus_phi2 * estimate_of_cos_phi1_minus_phi2) - @|
      (estimate_of_sin_phi1_minus_phi2 * estimate_of_sin_phi1_minus_phi2);

@* Okay, I Lied. There was actually no entanglement. There is no
entanglement anywhere in the world. Entanglement is the wrongest wrong
thing that there has ever been in the history of physics. But, because
the Nobel Prize treats science as if it were the Preakness Stakes
rather than a humble pursuit of understanding, it is just as well that
some of the mistakenest mistaken individuals in the history of the
universe should receive it.

Your program demonstrates that the Nobel Prize winners are {\it just
plain wrong\/} in their reasoning. Their papers should be retracted as
worthless. The root of the matter is that license John Stewart Bell
gave quantum theorists to declare anything ``true'' that suited their
fancy. They have used that license freely. Any attempt to declare
their math illegitimate is immediately canceled by the license Bell
gave them. It will be a Gish Gallop of ``{\it Local causality,
beables, socks, heart attacks, loopholes, dichotomic variables,
imported Belgian hay,\,..., yadda, yadda, yadda,\,...\,! Did you hear
me? I said LOCAL CAUSALITY HAY SOCKS LOOPHOLES!\/}''

I had thought to say more about what has been perpetrated, but words
escape me. Papers and books promoting ``entanglement'' and
``non-locality'' are simply worthless. They have no use except as
paper pulp. Instead I will do another thing the Winner's Circle
occupants claim cannot be done: for the sake of those capable of
reading the mathematics, I will derive the correlation coefficient of
our experiment, but using classical physics instead of quantum
mechanics. How to solve such problems I know from a 1980s education in
electronic signal processing. It seems uncertain whether such teaching
will remain legal for long, in the face of local causality hay socks
loopholes.

@ What we are looking for is the correlation coefficient of the ``way
sent'' values $+1$ and~$-1$. The definition of the correlation
coefficient is the covariance over the product of the standard
deviations. That denominator is merely a normalization, to put the
correlation coefficient between $-1$ and~$+1$, and the ``way sent''
values were chosen so that no such normalization was necessary. Thus
the correlation coefficient is equal to the covariance. Call the
correlation coefficient~$\rho$ and the two ``way sent''
values~$\tau_1$ and~$\tau_2$, and let $E$ represent an {\it
expectation}---that is, an average weighted by a probability density
function (pdf). Then $$\rho=E(\tau_1\tau_2)$$ for some pdf we have to
determine. That is, the correlation coefficient is a very carefully
weighted average of the products of ``way sent'' values.

@ It happens that members of the Smoke-and-Mirrors Club do not know
how to determine the pdf, and not knowing how to do that is part of
how they, as a group, ended up with the Nobel Prize. That statement
would seem to make no sense, which is because it makes no
sense. Signal processing engineers, however, are liable in court,
blah, blah, blah\,...\,{\it Okay, let us tell the truth\/}\,...\,the
{\it real\/} story is it is a problem I looked at casually for some
20~years before finally figuring it out. Thus I {\it do\/} know how to
determine the pdf---finally, after 20~years or so.

However, the main difference between me and the Smoke-and-Mirrors
members is that they did not believe it could be done, so they did not
really {\it try} (and thus your hypothalamus was psychosomatically
withered), whereas I knew it could be done, but did not yet know how.


@* Index.

