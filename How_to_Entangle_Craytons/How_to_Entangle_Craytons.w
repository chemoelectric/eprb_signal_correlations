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

@f crayton void
@f crayton_pair void
@f cray_ban void
@f event_data void
@f series_data void

\frenchspacing
\def\SAM/{{\sc{SMOKE-\AM-MIRRORS}}}
\def\SAMCLUB/{{\sc{SMOKE-\AM-MIRRORS CLUB}}}

\def\covernote{\vbox{%
\centerline{A tutorial by}%
\smallskip
\centerline{{\sc BARRY} SCHWARTZ,}%
\smallskip
\centerline{prepared in the year 2023,}%
\centerline{and last revised}%
\centerline{\input{How_to_Entangle_Craytons_revision.txt}}%
\bigskip
\centerline{Containing also a}%
\smallskip
\centerline{\sc PROOF}%
\smallskip
\centerline{without recourse to quantum mechanics}%
\centerline{of the correlation coefficient}%
\centerline{of a two-channel Bell test experiment.}%
\bigskip
\centerline{With many thanks to an anonymous person}%
\centerline{for their scientific curiosity.}%
\centerline{In our times, scientific method}%
\centerline{has been displaced by scientific authority,}%
\centerline{and to encounter actual curiosity is rare.}%
}}

@* Magically Entangled Craytons. What follows are instructions on how
to write a program that, on an ordinary computer, will
quantum-entangle two variables so that there is action at a distance
between them when they are printed out. Normally such a program would
require a quantum computer, but the program {\it you} write will be
magical.

I will myself, in the process of instructing you, write a magical
\CEE/ program that does the same thing. That is part of the magic of
using CWEB to write instructions.

That the programs we write must be magical is guaranteed to us by no
less than the 2022 Nobel Prize winners in Physics. Thousands of papers
have been published and thousands of volumes printed. Jillions of
public dollars have been spent. Experiment after experiment after
experiment has been conducted. So what occurs in our programs {\it
must\/} be nothing less than magic.

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
language will vary, but here is one way to write it in \CEE/.

@<the |crayton| type@>=
typedef enum {updown, sideways} crayton;

@ We have a special source of |crayton| variables. It produces two
|crayton|, one of them |updown| and the other |sideways|. Which of the
two |crayton| is which, however, is, over time, an unbiased mixture of
both ways. This is ensured by use of |@<arbitrary numbers between zero
and one@>|.

In the \CEE/ code, the two |crayton| will be returned in the \CEE/
version of a record structure. This pair of |crayton| variables will
be the pair the program magically entangles.

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

\item{$\bullet$} Let $a$ and~$b$ represent propositions,
and~$a{\wedge}b$ their logical conjunction. The {\it definition\/} of
their conditional probability is
$$P(a{\vert}b)=P(a{\wedge}b)\,/\,P(b) $$
This definition is {\it purely mathematical} and is complete
in itself. Nevertheless, if you have read the ``smoke'' literature,
you will have seen that none other than John Stewart Bell, Fellow of
the Royal Society, redefined the conditional probability as follows:
$$P(a{\vert}b) = \cases{P(a{\wedge}b)\,/\,P(b) &{\rm pretty\ much\ never}\cr
                        P(a) &{\rm if\ local\ causality,\ beables,%
                        \ socks,\ heart\ attacks,\ $\lambda$,\ etc.}\cr} $$
Most individuals familiar with mathematics will recognize
that this is a license to declare ``proved'' any pseudo-mathematical
nonsense one wishes, such as that $1=0$ and $E=mc^{9}$.
The concussion of a Fellow of the
Royal Society proudly displaying such a license is what rendered you
psychosomatically blind.

\item{$\bullet$} The claim that quantum physics is ``irreducible'' to
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
  if (number_between_zero_and_one () < x * x)
    i = +1;
  else
    i = -1;
  return i;
}

@ So here is what one event of the experiment looks like. There is the
one |crayton| source and there are two |cray_ban|, set respectively to
their angles. Each |crayton| in the pair is put through a respective
|cray_ban|. Data is recorded. You can return the data in a record, as
in the following \CEE/ code, or do whatever you prefer.

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
  data.way_k1_was_sent = law_of_logodaedalus (angle1, data.pair.k1);
  data.way_k2_was_sent = law_of_logodaedalus (angle2, data.pair.k2);
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
confusing \CEE/ feature called ``pointers.''

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
$$ \eqalign{{\it correlation\ coefficient}
        &= -\cos\,\{2(\phi_1-\phi_2)\} \cr
        &= -\{\cos^2(\phi_1-\phi_2) - \sin^2(\phi_1-\phi_2)\} \cr} $$
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
$$\phi_1,\phi_2=\cases{0,\, \pi/8         & {$-1/\sqrt2\approx-0.70711$} \cr
                       0,\, 3\,\pi/8      & {$+1/\sqrt2\approx+0.70711$} \cr
                       \pi/4,\, \pi/8     & {$-1/\sqrt2\approx-0.70711$} \cr
                       \pi/4,\, 3\,\pi/8  & {$-1/\sqrt2\approx-0.70711$} \cr}$$

@ Now we are going to do some clever stuff. We are going to use the
data we have collected, together with the Law of Logodaedalus, to
compute the correlation coefficient empirically. More specifically, we
are going to use {\it frequencies of the recorded events\/} to get
estimates of trigonometric functions of $\phi_1$ and~$\phi_2$, which
we will then use to compute an approximation of $-\{\cos^2(\phi_1-\phi_2)
- \sin^2(\phi_1-\phi_2)\}$.

@ Obtaining the frequencies is a simple matter of computing
ratios. Given a |series_data| record |sdata|:

@<frequencies of events@>=
double freq_of_updown_sideways_plus_plus = @|
       (1.0 * sdata.number_of_updown_sideways_plus_plus)@, / sdata.number_of_events;
double freq_of_updown_sideways_plus_minus = @|
       (1.0 * sdata.number_of_updown_sideways_plus_minus)@, / sdata.number_of_events;
double freq_of_updown_sideways_minus_plus = @|
       (1.0 * sdata.number_of_updown_sideways_minus_plus)@, / sdata.number_of_events;
double freq_of_updown_sideways_minus_minus = @|
       (1.0 * sdata.number_of_updown_sideways_minus_minus)@, / sdata.number_of_events;
double freq_of_sideways_updown_plus_plus = @|
       (1.0 * sdata.number_of_sideways_updown_plus_plus)@, / sdata.number_of_events;
double freq_of_sideways_updown_plus_minus = @|
       (1.0 * sdata.number_of_sideways_updown_plus_minus)@, / sdata.number_of_events;
double freq_of_sideways_updown_minus_plus = @|
       (1.0 * sdata.number_of_sideways_updown_minus_plus)@, / sdata.number_of_events;
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
  -((estimate_of_cos_phi1_minus_phi2 * estimate_of_cos_phi1_minus_phi2) -
    (estimate_of_sin_phi1_minus_phi2 * estimate_of_sin_phi1_minus_phi2));

@ Here is a \CEE/ function that puts together these calculations and
turns a |series_data| record into an estimate of a correlation
coefficient. Put the operations together similarly, in whatever
language you are using.

@<correlation coefficient estimate function@>=
double
correlation_coefficient_estimate (series_data sdata)
{
  @<frequencies of events@> @;
  @<estimates of certain products@> @;
  @<estimates of the angle-difference functions@> @;
  @<estimate of the correlation coefficient@> @;
  return estimate_of_correlation_coefficient;
}

@ Here is a procedure that will print out the estimate, along with the
nominal value. You will want something similar, but how to print out
data varies greatly from one programming language to another.

@<printing out the correlation coefficient estimate@>=
void
print_correlation_coefficient_estimate (series_data sdata)
{
  printf ("cray_ban angle1      %4.1f deg\n",
          sdata.angle1 * 180.0 / M_PI);
  printf ("cray_ban angle2      %4.1f deg\n",
          sdata.angle2 * 180.0 / M_PI);
  printf ("nominal corr coef    %+8.5f\n",
          -cos (2.0 * (sdata.angle1 - sdata.angle2)));
  printf ("measured corr coef   %+8.5f\n",
          correlation_coefficient_estimate (sdata));
}

@ Finally I will put together my \CEE/ program, and you can put
together your program.

@c
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <float.h>

@<arbitrary numbers between zero and one@> @;
@<the |crayton| type@> @;
@<the |crayton| source@> @;
@<the |cray_ban| type@> @;
@<the Law of Logodaedalus@> @;
@<an experimental event@> @;
@<the |series_data| type@> @;
@<a series of |n| experimental events@> @;
@<correlation coefficient estimate function@> @;
@<printing out the correlation coefficient estimate@> @;

int
main ()
{
  int n = 10000;
  series_data sdata1 = experimental_series (0.0, M_PI / 8.0, n);
  series_data sdata2 = experimental_series (0.0, 3.0 * M_PI / 8.0, n);
  series_data sdata3 = experimental_series (M_PI / 4.0, M_PI / 8.0, n);
  series_data sdata4 = experimental_series (M_PI / 4.0, 3.0 * M_PI / 8.0, n);
  printf ("\n");
  print_correlation_coefficient_estimate (sdata1);
  printf ("\n");
  print_correlation_coefficient_estimate (sdata2);
  printf ("\n");
  print_correlation_coefficient_estimate (sdata3);
  printf ("\n");
  print_correlation_coefficient_estimate (sdata4);
  printf ("\n");
  return 0;
}

@ When I compile and run my program, I obtain the following as my output:
{\raggedright\parindent=5em\tentt
\medskip
cray{\UL}ban{\SP}angle1{\SP}{\SP}{\SP}{\SP}{\SP}{\SP}{\SP}0.0{\SP}deg\par
cray{\UL}ban{\SP}angle2{\SP}{\SP}{\SP}{\SP}{\SP}{\SP}22.5{\SP}deg\par
nominal{\SP}corr{\SP}coef{\SP}{\SP}{\SP}{\SP}-0.70711\par
measured{\SP}corr{\SP}coef{\SP}{\SP}{\SP}-0.71180\par
\medskip
cray{\UL}ban{\SP}angle1{\SP}{\SP}{\SP}{\SP}{\SP}{\SP}{\SP}0.0{\SP}deg\par
cray{\UL}ban{\SP}angle2{\SP}{\SP}{\SP}{\SP}{\SP}{\SP}67.5{\SP}deg\par
nominal{\SP}corr{\SP}coef{\SP}{\SP}{\SP}{\SP}+0.70711\par
measured{\SP}corr{\SP}coef{\SP}{\SP}{\SP}+0.70980\par
\medskip
cray{\UL}ban{\SP}angle1{\SP}{\SP}{\SP}{\SP}{\SP}{\SP}45.0{\SP}deg\par
cray{\UL}ban{\SP}angle2{\SP}{\SP}{\SP}{\SP}{\SP}{\SP}22.5{\SP}deg\par
nominal{\SP}corr{\SP}coef{\SP}{\SP}{\SP}{\SP}-0.70711\par
measured{\SP}corr{\SP}coef{\SP}{\SP}{\SP}-0.70859\par
\medskip
cray{\UL}ban{\SP}angle1{\SP}{\SP}{\SP}{\SP}{\SP}{\SP}45.0{\SP}deg\par
cray{\UL}ban{\SP}angle2{\SP}{\SP}{\SP}{\SP}{\SP}{\SP}67.5{\SP}deg\par
nominal{\SP}corr{\SP}coef{\SP}{\SP}{\SP}{\SP}-0.70711\par
measured{\SP}corr{\SP}coef{\SP}{\SP}{\SP}-0.70148\par
\medskip}

\noindent Thus is entanglement proven! I have entangled |crayton|
pairs on ordinary computer hardware. No quantum computer was
necessary. Each |crayton| in a pair settled into its individual state
non-locally upon measurement of the other.

@* Okay, I Lied. There was actually no entanglement. There is no
entanglement anywhere in the world. Entanglement is the wrongest wrong
thing that there has ever been in the history of physics.

Your program demonstrates that quantum theorists have been {\it just
plain wrong\/} in their reasoning. One of the root causes is that
license John Stewart Bell gave theorists to declare anything ``true''
that suited their fancy. They have used that license freely. Any
attempt to declare their math illegitimate is immediately canceled by
the license Bell gave them. One will be slammed with a {\sc GISH
GALLOP} of ``{\it Local causality, beables, socks, heart attacks,
loopholes, dichotomic variables, imported hay, Fantastic Voyage, Final
Four,\,...\,!  Did you hear me? Tick, tick, tick. I said {\sc LOCAL
CAUSALITY HAY SOCKS LOOPHOLES!}}''

I had thought to say more about what has been perpetrated, but words
escape me. Papers and books promoting ``entanglement'' and
``non-locality'' are simply worthless. They have no use except as
paper pulp. Instead I will do another thing the \SAM/
magicians claim cannot be done: for the sake of those capable of
reading the mathematics, I will derive the correlation coefficient of
our experiment, but using classical physics instead of quantum
mechanics.

@ Actually the correlation coefficients for experiments such as this
one were derived long ago using the classical theory of wave
mechanics! If you assume waves are assemblages of particles, then some
``quantum'' phenomena are explained classically. There are also other
ways in which some ``quantum'' phenomena can be explained classically
as wave phenomena, where the waves may be continuous
substance. However, in counterargument, ``{\sc LOCAL CAUSALITY HAY
SOCKS LOOPHOLES!}''

If you see what I mean.

The same counterargument will apply to the derivation below. However,
at least the derivation will not depend upon wave theory. It will
employ more fundamental mathematics.

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

@ I studied the problem casually for some 20~years before finally
figuring out how to determine the pdf. But then I decided that
determining the pdf was not necessary, after all!

Yes, I had a derived the correlation coefficient by determining a pdf,
but I shall not reproduce that derivation for you, because it is too
complicated. You need an education in digital signal processing theory
to understand it, and even then it makes one's head feel as if it were
a muddled fruit at the bottom of a cocktail shaker. (Which a
university education does in any case.) The derivation probably still
has bugs in it, the way a computer program that is too complicated
seems never to have all the bugs cleaned out. They can be cleaned out,
certainly, but the effort is not worth it. It is better to find a new
approach.

@ The following much simpler derivation starts by deriving what the
\SAMCLUB/ seems to believe is all classical physics is capable of
deriving: a particular function of the two |cray_ban| settings that is
{\it not\/} a function of their difference. {\it That\/} derivation is
tedious but straightforward.

Let~$k_1$ and~$k_2$ represent the |crayton| pair, and~$\phi_{01}$
and~$\phi_{02}$ the |cray_ban| settings. Then the Law of Logodaedalus
is
$$\eqalignno{
P(\tau_1=+1{\,\vert\,} k_1={\it updown})&=\sin^2(\phi_{01}) \cr
P(\tau_1=-1{\,\vert\,} k_1={\it updown})&=\cos^2(\phi_{01}) \cr
P(\tau_2=+1{\,\vert\,} k_2={\it updown})&=\sin^2(\phi_{02}) \cr
P(\tau_2=-1{\,\vert\,} k_2={\it updown})&=\cos^2(\phi_{02}) \cr
P(\tau_1=+1{\,\vert\,} k_1={\it sideways})&=\cos^2(\phi_{01}) \cr
P(\tau_1=-1{\,\vert\,} k_1={\it sideways})&=\sin^2(\phi_{01}) \cr
P(\tau_2=+1{\,\vert\,} k_2={\it sideways})&=\cos^2(\phi_{02}) \cr
P(\tau_2=-1{\,\vert\,} k_2={\it sideways})&=\sin^2(\phi_{02}) \cr
}$$
The Law of Logodaedalus is obviously consistent, in that
$$\eqalign{
P(\tau_1=+1{\,\vert\,} k_1={\it updown}) + P(\tau_1=-1{\,\vert\,} k_1={\it updown})
           &= \sin^2(\phi_{01}) + \cos^2(\phi_{01}) = 1 \cr
P(\tau_2=+1{\,\vert\,} k_2={\it updown}) + P(\tau_2=-1{\,\vert\,} k_2={\it updown})
           &= \sin^2(\phi_{02}) + \cos^2(\phi_{02}) = 1 \cr
P(\tau_1=-1{\,\vert\,} k_1={\it sideways}) + P(\tau_1=+1{\,\vert\,} k_1={\it sideways})
           &= \sin^2(\phi_{01}) + \cos^2(\phi_{01}) = 1 \cr
P(\tau_2=-1{\,\vert\,} k_2={\it sideways}) + P(\tau_2=+1{\,\vert\,} k_2={\it sideways})
           &= \sin^2(\phi_{02}) + \cos^2(\phi_{02}) = 1 \cr
}$$
This smidgen of mathematical consistency is present even in the
\SAM/ literature.

@ The |crayton| source also gives us opportunity to define some
probabilities:
$$\eqalign{P(k_1={\it updown}{\,\wedge\,}k_2={\it sideways}) &=
           P(k_1={\it sideways}{\,\wedge\,}k_2={\it updown}) = 1/2 \cr
           P(k_1={\it updown}{\,\wedge\,}k_2={\it updown}) &=
           P(k_1={\it sideways}{\,\wedge\,}k_2={\it sideways}) = 0 \cr}$$
These add up to one and so also are consistent.
For simplicity, from now on we will write down only~$k_1$, given that the
value of~$k_2$ is immediately deducible. Including it in the calculations
merely adds tedium. Thus the equations above become simply
$$P(k_1={\it updown}) = P(k_1={\it sideways}) = 1/2$$

@ Suppose we want to calculate the joint probability $P_1 = P(k_1={\it
updown}{\,\wedge\,}\tau_1=+1{\,\wedge\,}\tau_2=+1)$. One does it by
using the definition of the conditional probability---the actual
definition, not the John~Stewart Bell definition:
$$\eqalign{P_1 &= P(k_1={\it updown}{\,\wedge\,}\tau_1=+1{\,\wedge\,}\tau_2=+1) \cr
&= P(k_1={\it updown})\,P(\tau_1=+1{\,\wedge\,}\tau_2=+1{\,\vert\,}k_1={\it updown}) \cr
&= P(k_1={\it updown})\,P(\tau_1=+1{\,\vert\,}k_1={\it updown})
\,P(\tau_2=+1{\,\vert\,}k_1={\it updown}) \cr
&= P(k_1={\it updown})\,P(\tau_1=+1{\,\vert\,}k_1={\it updown})
\,P(\tau_2=+1{\,\vert\,}k_2={\it sideways}) \cr
&={1\over2} \sin^2(\phi_{01}) \cos^2(\phi_{02}) \cr
}$$
A person might notice I assumed
$$P(\tau_1=+1{\,\wedge\,}\tau_2=+1{\,\vert\,}k_1={\it updown})
= P(\tau_1=+1{\,\vert\,}k_1={\it updown})\,P(\tau_2=+1{\,\vert\,}k_1={\it updown})$$
without proof, but this was because I am old and tired and get senior
discounts.  I did not invoke ``{\sc LOCAL CAUSALITY HAY SOCKS
LOOPHOLES!}'' Seriously, though, the two |cray_ban| operate
independently and that is the intuition here. This is entirely
different from what John~Bell was attempting, which was to construct
an explicit causal chain (by abusing conditional probability
notation), whack the audience with a stun weapon, blinding them, then
impress the illusion an explicit causal chain was the {\it only\/}
form in which classical physics could be expressed.

If John~Bell had been correct about that, then Johannes~Kepler was not
doing classical physics when he observed that planets moved in
ellipses, nor was Isaac~Newton when he formulated his Law of Universal
Gravitation. But really that is beside the point, because those are
{\it empirical laws}, not derived theories. As I said earlier, the
\SAM/ crowd are actually distracting you from {\it this\/}
fact: in the context at hand, ``classical physics'' means {\it any\/}
mathematics that is not quantum mechanics, {\it if\/} employed to
reach the same result as quantum mechanics. Their actual claim, {\it
sotto voce}, is that no mathematics but quantum mechanics can get the
job done.

It is a ludicrous claim. It would have been laughed out of the room so
long ago that the Tortoise had not yet caught up with the Hare, had
the claim been voiced out loud. It is so ridiculous a claim that it
could not have been kept secret. Thus, indeed, it is not so much that
the claim is kept {\it sotto voce\/} as that its believers do not, in
fact, see that it is what they believe. Their cortexes are screaming
and their hypothalamuses are pulsating. They {\it think\/} they are
saying things that make sense. They spend too much time amidst their
own psychosomatic barrages.

Part of the reason for me writing this program as {\it instructions\/}
on how to write a program, rather than as merely a program for others
to compile and run, is so \SAMCLUB/ members can sooth their throbbing
brains by writing {\it their own programs}. They can experience the
truth firsthand, and as recreation rather than hard work. I encourage
them to pick up computer and bow, and play a soothing |crayton|
lullaby, according to this sheet music, but each in their unique
style.

@ By the previous calculation, and then by similar ones (though
actually by symmetry considerations), a table can be constructed:
$$\eqalignno{
P(k_1={\it updown}{\,\wedge\,}\tau_1=+1{\,\wedge\,}\tau_2=+1)
  &= {1\over2} \sin^2(\phi_{01}) \cos^2(\phi_{02}) \cr
P(k_1={\it updown}{\,\wedge\,}\tau_1=+1{\,\wedge\,}\tau_2=-1)
  &= {1\over2} \sin^2(\phi_{01}) \sin^2(\phi_{02}) \cr
P(k_1={\it updown}{\,\wedge\,}\tau_1=-1{\,\wedge\,}\tau_2=+1)
  &= {1\over2} \cos^2(\phi_{01}) \cos^2(\phi_{02}) \cr
P(k_1={\it updown}{\,\wedge\,}\tau_1=-1{\,\wedge\,}\tau_2=-1)
  &= {1\over2} \cos^2(\phi_{01}) \sin^2(\phi_{02}) \cr
P(k_1={\it sideways}{\,\wedge\,}\tau_1=+1{\,\wedge\,}\tau_2=+1)
  &= {1\over2} \cos^2(\phi_{01}) \sin^2(\phi_{02}) \cr
P(k_1={\it sideways}{\,\wedge\,}\tau_1=+1{\,\wedge\,}\tau_2=-1)
  &= {1\over2} \cos^2(\phi_{01}) \cos^2(\phi_{02}) \cr
P(k_1={\it sideways}{\,\wedge\,}\tau_1=-1{\,\wedge\,}\tau_2=+1)
  &= {1\over2} \sin^2(\phi_{01}) \sin^2(\phi_{02}) \cr
P(k_1={\it sideways}{\,\wedge\,}\tau_1=-1{\,\wedge\,}\tau_2=-1)
  &= {1\over2} \sin^2(\phi_{01}) \cos^2(\phi_{02}) \cr
}$$

@ By adding the probabilities of mutually exclusive propositions in
that table, one deduces
$$\eqalign{P(&\tau_1=+1{\,\wedge\,}\tau_2=+1) \cr
  &= P(\tau_1=-1{\,\wedge\,}\tau_2=-1) \cr
  &= {1\over2} \sin^2(\phi_{01}) \cos^2(\phi_{02})
      + {1\over2} \cos^2(\phi_{01}) \sin^2(\phi_{02}) \cr}$$
$$\eqalign{P(&\tau_1=+1{\,\wedge\,}\tau_2=-1) \cr
  &= P(\tau_1=-1{\,\wedge\,}\tau_2=+1) \cr
  &= {1\over2} \sin^2(\phi_{01}) \sin^2(\phi_{02})
      + {1\over2} \cos^2(\phi_{01}) \cos^2(\phi_{02}) \cr}$$

@ Now suppose we want to find an ``expectation'' $E'(\tau_1\tau_2)$
{\it not\/} as a function of a difference, such
as~$\phi_{01}-\phi_{02}$, but {\it instead\/} as a function of
particular given values~$\phi_{01}$ and~$\phi_{02}$. This, I believe,
is a problem the \SAMCLUB/ has mistaken for the real
one. But its solution will lead {\it so quickly\/} to the real answer
(in terms of a difference between angles) that\,...\,you have to see
it to believe it. One wonders not so much {\it how\/} they missed the
solution, but whether some of them {\it saw\/} it but dismissed it as
unpublishable, because ``{\sc LOCAL CAUSALITY HAY SOCKS LOOPHOLES!}''
That is, they knew if they submitted a paper they would be bombarded
with psychic energy weapons. Once they recovered they would have to
publish in obscure journals, at engineering conferences, etc., or not
at all, and the whole affair would have harmed their careers.

@ To write this new ``expectation'' $E'(\tau_1\tau_2)$ (call it $\rho'$)
as an integral weighted by a pdf would be excessive.
It can be written as a sum:
$$\eqalign{\rho' &= E'(\tau_1\tau_2) \cr
 &= (+1)(+1) P^{++}
 + (+1)(-1) P^{+-}
 + (-1)(+1) P^{-+}
 + (-1)(-1) P^{--} \cr
 &= P^{++} - P^{+-} - P^{-+} + P^{--} \cr
}$$
where
$$\eqalign{
P^{++} &= P(\tau_1=+1{\,\wedge\,}\tau_2=+1) \cr
P^{+-} &= P(\tau_1=+1{\,\wedge\,}\tau_2=-1) \cr
P^{-+} &= P(\tau_1=-1{\,\wedge\,}\tau_2=+1) \cr
P^{--} &= P(\tau_1=-1{\,\wedge\,}\tau_2=-1) \cr
}$$
Substituting the calculated expressions for the probabilities gives
$$\eqalign{
\rho'&= -\{
\cos^2(\phi_{01})\cos^2(\phi_{02})
- \cos^2(\phi_{01})\sin^2(\phi_{02})
- \sin^2(\phi_{01})\cos^2(\phi_{02})
+ \sin^2(\phi_{01})\sin^2(\phi_{02})
\}\cr
&=-\{\cos^2(\phi_{01})-\sin^2(\phi_{01})\}
   \{\cos^2(\phi_{02})-\sin^2(\phi_{02})\} \cr
&=-\cos(2\phi_{01})\cos(2\phi_{02}) \cr
}$$
where the last step is by a double-angle identity found in reference
books. This result is, I believe, what \SAM/ members
commonly believe is the best classical physics can achieve.

@ This result has the wrong form, so it simply {\it cannot\/} be the
correct solution! And, indeed, it gives incorrect results. If you plug
in the angles $\phi_{01}=\pi/4$ and~$\phi_{02}=\pi/8$, for instance,
you will get zero instead of the correct value,~$-1/\sqrt2$. But now,
with this result that obviously, at a glance, cannot be correct, you
can derive an ``inequality'' and win a Nobel Prize. This is one route,
at least, by which the so-called ``{\sc CHSH} inequality'' can be
derived.

@ But suppose that, instead of publishing an ``inequality'' and
winning a Nobel Prize, we consider only the special
case~$\phi_{02}=0$. Then $$\rho' = -\cos(2\phi_{01}) =
-\cos\{2(\phi_{01}-\phi_{02})\}$$ and it {\it does\/} have the correct
form.

And now let us give the name~$\Delta\phi$ to any angle whatsoever, and
add~$0=\Delta\phi - \Delta\phi$ to~$\phi_{01}-\phi_{02}$:
$$\rho' = -\cos(2\{(\phi_{01} + \Delta\phi) - (\phi_{02} + \Delta\phi)\})$$

And then let us call~$\phi_{01} + \Delta\phi$ by the name~$\phi_1$,
and~$\phi_{02} + \Delta\phi$ by the name~$\phi_2$, and also (because
it has the correct form) rename~$\rho'$ as simply~$\rho$:
$$\eqalign{\rho &= -\cos\{2(\phi_1 - \phi_2)\} \cr
 &= -\{\cos^2(\phi_1 - \phi_2) - \sin^2(\phi_1 - \phi_2)\}\cr}$$

Having done these things, we have derived, using only classical
physics, the same correlation coefficient quantum mechanics
gives. Thus there is no entanglement, no non-locality, no quantum
weirdness whatsoever. Einstein, Podolsky, and Rosen were correct. The
2022 Nobel Prize in Physics was awarded for physics done so badly it
ought to be regarded as {\it pseudoscience}. This ``science'' was
worse than cold fusion, for instance. A perpetual motion machine would
be no worse than what this prize was given for.

The number of paper retractions due is staggering. Nevertheless,
expect instead professors occupying university administration offices,
standing on the roofs shouting ``{\sc LOCAL CAUSALITY HAY SOCKS
LOOPHOLES!}'' into megaphones.

@ There is a simple interpretation for this classical derivation, an
interpretation I worked into simulations slightly more complicated
than the one this tutorial describes. Actually, the simulations
existed many weeks before the derivation, so served as immediate
evidence of the proof's validity.  In these simulations, instead of
testing with a few angles, the equivalents of a |cray_ban| are
constantly rotating on axles, in unison. This is as if~$\Delta\phi$
were allowed to increase freely over time. Although the proportions of
``who gets sent which way'' change as~$\Delta\phi$ changes, the
correlation coefficient stays fixed with the relative angle. There is
no entanglement, there is no non-locality, there is nothing weird
whatsoever. Members of the \SAMCLUB/ were always deploying
psychosomatic weaponry rather than presenting facts.

@ However, there is also a much deeper interpretation: {\it any\/}
angle may be labeled zero, as long as it is {\it the same\/} angle on
both |cray_ban| in the pair.

To make this so was the main goal of the pdf in my original proof,
where I achieved the goal by making the probability density uniform
with respect to one of the two angular settings. This approach might
seem obvious to we who do not confuse probability with ``randomness''
or with physical substance. Nevertheless, that approach is
overcomplicated. Instead, simply set the angle, once and for all time,
to zero. Then introduce~$\Delta\phi$ as a translation of angular
coordinate system.

@* Index.
