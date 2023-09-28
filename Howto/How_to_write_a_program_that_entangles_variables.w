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
@f cray_ban void

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
a function returning a floating point number, will suffice. (Or you
could just use your programming language's ``random number''
facilities.)

@<Arbitrary numbers between zero and one@>=
double a_global_variable = 12345.0;

double
number_between_zero_and_one ()
{
  double x = a_global_variable * 75.0;
  while (x > 65537.0) x = x - 65537.0;
  a_global_variable = x;
  return (x / 65537.0);
}

@ Now to the magical program itself. The first thing we need is the
magical variables. These will be of a type called |crayton|, whose
value will be either |updown| or |sideways|. How to write that in your
language will vary, but here is one way to write it in C.

@<The |crayton| type@>=
typedef enum {updown, sideways} crayton;

@ As with many a magic trick, we need mirrors. What we need here is
the digital equivalent of a device made from a kind of mirror that
breaks a beam of light into two beams. But this mirror is also the
digital equivalent of a polarizing filter. This all seems very
complicated, but in fact the type for the entire mess is just a
floating point number capable of representing an angle in radians. The
angle is simply how much someone has rotated the angle of the
filter. Let us call the type |cray_ban|.

@<The |cray_ban| type@>=
typedef double cray_ban;

@ A |cray_ban| does not deal with a beam of light, but instead with a
|crayton|. It decides which of two ways to send a |crayton| (we will
number the ways $+1$ and~$-1$) according to an algorithm that depends
on one of those arbitrary numbers between zero and one. Students of
optics may recognize this algorithm as the {\it Law of Malus}, but
here we will call it the {\it Law of Logodaedalus}, because that
sounds more magical.

@<The Law of Logodaedalus@>=
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
