/*
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <https://unlicense.org>
*/

/*------------------------------------------------------------------*/
/*

This program may be compiled as either one of C or C++

*/

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>
#include <math.h>
#include <float.h>

/*------------------------------------------------------------------*/

typedef double scalar;

#define π      ((scalar) M_PI)
#define π_2    ((scalar) M_PI_2)
#define π_3    ((scalar) (M_PI / 3.0))
#define π_4    ((scalar) M_PI_4)
#define π_6    ((scalar) (M_PI / 6.0))
#define π_8    ((scalar) (M_PI_4 / 2.0))
#define π_180  ((scalar) (M_PI_4 / 45.0))
#define two_π  ((scalar) (M_PI * 2.0))

typedef enum { COUNTERCLOCKWISE, CLOCKWISE } signal;
typedef enum { CIRCLED_PLUS, CIRCLED_MINUS } tag;
typedef struct { tag τ; signal σ; } tagged_signal;
typedef struct { tagged_signal pair[2]; } tagged_signal_pair;

/*------------------------------------------------------------------*/
/* The same random number generator as in the Ada program. */

#define LCG_A UINT64_C(0xF1357AEA2E62A9C5)
#define LCG_C UINT64_C(0x0000000000000001)

uint64_t seed = 0;

scalar
random_scalar (void)
{
  /* Take the high 48 bits of the seed and divide it by 2**48. */
  scalar randval = (seed >> 16) / 281474976710656.0;
  assert (0.0 <= randval && randval < 1.0);

  /* Update the seed. */
  seed = (LCG_A * seed) + LCG_C;

  return randval;
}

/*------------------------------------------------------------------*/

#define RUN_LENGTH 1000000

tagged_signal
assign_tag (scalar ζ, signal σ)
{
  scalar r = random_scalar ();
  scalar x = (σ == COUNTERCLOCKWISE) ? cos (ζ) : sin (ζ);
  tagged_signal taggedsig;
  taggedsig.τ = (r < x * x) ? CIRCLED_PLUS : CIRCLED_MINUS;
  taggedsig.σ = σ;
  return taggedsig;
}

void
collect_data (scalar ζ1, scalar ζ2,
              tagged_signal_pair raw_data[RUN_LENGTH])
{
  for (size_t i = 0; i != RUN_LENGTH; i += 1)
    {
      signal σ =
        (random_scalar () < 0.5) ? COUNTERCLOCKWISE : CLOCKWISE;
      raw_data[i].pair[0] = assign_tag (ζ1, σ);
      raw_data[i].pair[1] = assign_tag (ζ2, σ);
    }
}

size_t
count (tagged_signal_pair raw_data[RUN_LENGTH],
       signal σ, tag τ1, tag τ2)
{
  size_t n = 0;
  for (size_t i = 0; i != RUN_LENGTH; i += 1)
    {
      assert (raw_data[i].pair[0].σ == raw_data[i].pair[1].σ);
      n += (raw_data[i].pair[0].σ == σ &&
            raw_data[i].pair[0].τ == τ1 &&
            raw_data[i].pair[1].τ == τ2);
    }
  return n;
}

scalar
frequency (tagged_signal_pair raw_data[RUN_LENGTH],
           signal σ, tag τ1, tag τ2)
{
  return ((scalar) count (raw_data, σ, τ1, τ2)) / RUN_LENGTH;
}

scalar
cosine_sign (scalar φ)
{
  return (cos (φ) < 0.0) ? -1.0 : 1.0;
}

scalar
sine_sign (scalar φ)
{
  return (sin (φ) < 0.0) ? -1.0 : 1.0;
}

scalar
cc_sign (scalar φ1, scalar φ2)
{
  return cosine_sign (φ1) * cosine_sign (φ2);
}

scalar
cs_sign (scalar φ1, scalar φ2)
{
  return cosine_sign (φ1) * sine_sign (φ2);
}

scalar
sc_sign (scalar φ1, scalar φ2)
{
  return sine_sign (φ1) * cosine_sign (φ2);
}

scalar
ss_sign (scalar φ1, scalar φ2)
{
  return sine_sign (φ1) * sine_sign (φ2);
}

scalar
estimate_ρ_from_raw_data (tagged_signal_pair raw_data[RUN_LENGTH],
                          scalar φ1, scalar φ2)
{
  scalar ac2c2, ac2s2, as2c2, as2s2;
  scalar cc2c2, cc2s2, cs2c2, cs2s2;
  scalar c2c2, c2s2, s2c2, s2s2;
  scalar cc, cs, sc, ss, c12, s12;

  ac2c2 = frequency (raw_data, COUNTERCLOCKWISE,
                     CIRCLED_PLUS, CIRCLED_PLUS);
  ac2s2 = frequency (raw_data, COUNTERCLOCKWISE,
                     CIRCLED_PLUS, CIRCLED_MINUS);
  as2c2 = frequency (raw_data, COUNTERCLOCKWISE,
                     CIRCLED_MINUS, CIRCLED_PLUS);
  as2s2 = frequency (raw_data, COUNTERCLOCKWISE,
                     CIRCLED_MINUS, CIRCLED_MINUS);
  cs2s2 = frequency (raw_data, CLOCKWISE,
                     CIRCLED_PLUS, CIRCLED_PLUS);
  cs2c2 = frequency (raw_data, CLOCKWISE,
                     CIRCLED_PLUS, CIRCLED_MINUS);
  cc2s2 = frequency (raw_data, CLOCKWISE,
                     CIRCLED_MINUS, CIRCLED_PLUS);
  cc2c2 = frequency (raw_data, CLOCKWISE,
                     CIRCLED_MINUS, CIRCLED_MINUS);

  c2c2 = ac2c2 + cc2c2;
  c2s2 = ac2s2 + cc2s2;
  s2c2 = as2c2 + cs2c2;
  s2s2 = as2s2 + cs2s2;

  cc = cc_sign (φ1, φ2) * sqrt (c2c2);
  cs = cs_sign (φ1, φ2) * sqrt (c2s2);
  sc = sc_sign (φ1, φ2) * sqrt (s2c2);
  ss = ss_sign (φ1, φ2) * sqrt (s2s2);

  c12 = cc + ss;
  s12 = sc - cs;

  return (c12 * c12) - (s12 * s12);
}

scalar
estimate_ρ (scalar φ1, scalar φ2)
{
  static tagged_signal_pair raw_data[RUN_LENGTH];

  collect_data (φ1, φ2, raw_data);
  return estimate_ρ_from_raw_data (raw_data, φ1, φ2);
}

void
print_bell_tests (scalar delta_φ)
{
  printf ("    φ₂ − φ₁ = %6.2lf°\n", delta_φ / π_180);
  for (size_t i = 0; i != 33; i += 1)
    {
      const scalar φ1 = i * π / 16.0;
      const scalar φ2 = φ1 + delta_φ;
      const scalar φ1_ = φ1 / π_180;
      const scalar φ2_ = φ2 / π_180;
      const scalar ρ_ = estimate_ρ (φ1, φ2);
      printf ("    φ₁ = %6.2lf°  φ₂ = %6.2lf°   ρ est. = %8.5lf\n",
              φ1_, φ2_, ρ_);
    }
}

int
main (void)
{
  printf ("\n");
  print_bell_tests (-π_8);
  printf ("\n");
  print_bell_tests (π_8);
  printf ("\n");
  print_bell_tests (-3 * π_8);
  printf ("\n");
  print_bell_tests (3 * π_8);
  printf ("\n");
  return 0;
}
