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
filter. Let us call the type |cray_ban|.

@<the |cray_ban| type@>=
typedef double cray_ban;

@ Such a magic trick also needs smoke. In this case, the smoke
comprises classical physics done, by doctors of philosophy in physics
or mathematics, so shockingly incorrectly that you go
psychosomatically blind. However, there is not space here for phony
mathematics, so we refer you to the quantum physics literature
instead.

Please leave yourself a chance to recover. You may need as smelling
salts the following reminders:
\medskip

\item{\bullet} The {\it definition\/} of a conditional probability $
P(A\,\vert{}B) $, in terms of a joint probability $ P(A\cap{}B) $ and
a probability $ P(B) $, is $ P(A\,\vert{}B)=P(A\cap{}B)\,/\,P(B) $,
and this definition is {\it purely mathematical}, having {\it
nothing\/} to do with ``causality'' or ``controlled variables.'' When
new definitions are introduced, employing such terms taken from
physics, the resulting ``mathematics'' is phony and internally
inconsistent. For instance, given the ``mathematics'' of the most
famous smoke in all of the literature, one may easily prove that~$ 1 =
0 $. This proof is not a ``loophole,'' as some thaumaturge may try to
convince you it be, thereby giving you vertigo. It is demonstration
that the author of the literature had not the vaguest clue what he was
doing. The concussion of such incompetence, in a Fellow of the Royal
Society, is what rendered you psychosomatically blind.

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
such ``irreducibility'' has ever been provided. The literature,
however, does employ incompetence in techniques besides quantum
mechanics {\it to give the impression\/} of such ``irreducibility.''
The encounter of scientists not even {\it trying\/} to solve problems
causes temporarily shriveling of the hypothalamus.  \medskip

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
  int way_pair_k1_was_sent;
  int way_pair_k2_was_sent;
} event_data;

event_data
experimental_event (cray_ban angle1, cray_ban angle2)
{
  event_data data;
  data.pair = crayton_source ();
  data.way_pair_k1_was_sent = law_of_logodaedalus (angle1, pair.k1);
  data.way_pair_k2_was_sent = law_of_logodaedalus (angle2, pair.k2);
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
          if (edata.way_pair_k1_was_sent == +1)
            {
              if (edata.way_pair_k2_was_sent == +1)
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
              if (edata.way_pair_k2_was_sent == +1)
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
          if (edata.way_pair_k1_was_sent == +1)
            {
              if (edata.way_pair_k2_was_sent == +1)
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
              if (edata.way_pair_k2_was_sent == +1)
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
some techniques for pretending one has shown {\it absence\/} of
entanglement---which work by causing psychosomatic blindness---but our
task is to show {\it presence\/} of entanglement. Thus we will use
nothing less than a formula from quantum mechanics: the correlation
coefficient for our experimental arrangement.

A {\it correlation coefficient\/} is a value between $-1$ and~$+1$
that gives some idea how interrelated are two functions or sets of
data. It is a notion familiar in the field of statistics, but also in
the theory of waves, where it indicates the capacity of two waves (if
superposed) to form different interference patterns.
